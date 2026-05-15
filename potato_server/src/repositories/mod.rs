use std::collections::BTreeMap;

use sea_orm::{
    ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, QueryOrder, Set,
};
use sea_orm::sea_query::{Expr, OnConflict};

use crate::entities::{chunks, rooms};
use crate::state::{ChunkInfos, Room};

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

pub async fn create_room(db: &DatabaseConnection, id: String) {
    let model = rooms::ActiveModel { id: Set(id) };
    let _ = rooms::Entity::insert(model)
        .on_conflict(
            OnConflict::column(rooms::Column::Id)
                .do_nothing()
                .to_owned(),
        )
        .exec(db)
        .await;
}

pub async fn add_chunk_to_room(
    db: &DatabaseConnection,
    room_id: String,
    chunk_info: ChunkInfos,
) {
    create_room(db, room_id.clone()).await;

    for (order, chunk_id) in chunk_info.chunks.iter().enumerate() {
        let _ = chunks::Entity::update_many()
            .col_expr(chunks::Column::RoomId, Expr::value(room_id.clone()))
            .col_expr(
                chunks::Column::FileName,
                Expr::value(chunk_info.file_name.clone()),
            )
            .col_expr(chunks::Column::ChunkOrder, Expr::value(order as i32))
            .filter(chunks::Column::Id.eq(chunk_id.clone()))
            .exec(db)
            .await;
    }
}

pub async fn get_room_content(db: &DatabaseConnection, room_id: &str) -> Room {
    let rows = chunks::Entity::find()
        .filter(chunks::Column::RoomId.eq(room_id))
        .order_by_asc(chunks::Column::ChunkOrder)
        .all(db)
        .await
        .unwrap_or_default();

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

    Room { chunks_infos }
}
