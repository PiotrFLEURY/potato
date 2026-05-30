use std::collections::BTreeMap;
use std::time::Duration;

use sea_orm::sea_query::{Expr, OnConflict};
use sea_orm::sqlx::types::chrono::Utc;
use sea_orm::{ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, QueryOrder, Set};

use crate::entities::{chunks, rooms};
use crate::hashing::{hash_room_code, is_classic_room_code, is_hashed_room_id};
use crate::state::{ChunkInfos, Room};

fn validate_room_id(room_id: &str) -> Result<(), String> {
    if is_classic_room_code(room_id) || is_hashed_room_id(room_id) {
        Ok(())
    } else {
        Err("Invalid room ID".to_string())
    }
}

pub async fn persist_chunk(db: &DatabaseConnection, id: String, data: Vec<u8>) {
    let model = chunks::ActiveModel {
        id: Set(id),
        data: Set(data),
        room_id: Set(None),
        file_name: Set(None),
        chunk_order: Set(None),
    };
    let _ = chunks::Entity::insert(model)
        .on_conflict(
            OnConflict::column(chunks::Column::Id)
                .update_column(chunks::Column::Data)
                .to_owned(),
        )
        .exec(db)
        .await;
}

pub async fn fetch_chunk(db: &DatabaseConnection, id: &str) -> Option<Vec<u8>> {
    chunks::Entity::find_by_id(id)
        .one(db)
        .await
        .ok()
        .flatten()
        .map(|c| c.data)
}

pub async fn create_room(db: &DatabaseConnection, id: String) -> Result<(), String> {
    validate_room_id(&id)?;
    let hashed_code = hash_room_code(&id);
    let expires_at = Utc::now() + Duration::from_hours(1);
    let model = rooms::ActiveModel {
        id: Set(hashed_code),
        expires_at: Set(expires_at),
    };
    let _ = rooms::Entity::insert(model)
        .on_conflict(
            OnConflict::column(rooms::Column::Id)
                .do_nothing()
                .to_owned(),
        )
        .exec(db)
        .await;
    Ok(())
}

pub async fn add_chunk_to_room(
    db: &DatabaseConnection,
    room_id: String,
    chunk_info: ChunkInfos,
) -> Result<(), String> {
    create_room(db, room_id.clone()).await?;

    let hashed_room_id = hash_room_code(&room_id);

    for (order, chunk_id) in chunk_info.chunks.iter().enumerate() {
        let _ = chunks::Entity::update_many()
            .col_expr(chunks::Column::RoomId, Expr::value(hashed_room_id.clone()))
            .col_expr(
                chunks::Column::FileName,
                Expr::value(chunk_info.file_name.clone()),
            )
            .col_expr(chunks::Column::ChunkOrder, Expr::value(order as i32))
            .filter(chunks::Column::Id.eq(chunk_id.clone()))
            .exec(db)
            .await;
    }
    Ok(())
}

pub async fn get_room_content(db: &DatabaseConnection, room_id: &str) -> Result<Room, String> {
    validate_room_id(room_id)?;
    let hashed_room_id = hash_room_code(room_id);
    let mut rows = chunks::Entity::find()
        .filter(chunks::Column::RoomId.eq(hashed_room_id))
        .order_by_asc(chunks::Column::ChunkOrder)
        .all(db)
        .await
        .unwrap_or_default();

    // TODO: Remove when no more rooms with unhashed IDs exist. This is to support existing rooms created before the hashing was implemented.
    if rows.is_empty() {
        rows = chunks::Entity::find()
            .filter(chunks::Column::RoomId.eq(room_id.to_string()))
            .order_by_asc(chunks::Column::ChunkOrder)
            .all(db)
            .await
            .unwrap_or_default();
    }

    // Group chunk IDs by file name, preserving chunk_order via the query ordering above.
    let mut file_map: BTreeMap<String, Vec<String>> = BTreeMap::new();
    for row in rows {
        if let Some(file_name) = row.file_name {
            file_map.entry(file_name).or_default().push(row.id);
        }
    }

    let chunks_infos = file_map
        .into_iter()
        .map(|(file_name, chunks)| ChunkInfos { file_name, chunks })
        .collect();

    Ok(Room { chunks_infos })
}
