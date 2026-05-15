use std::sync::Arc;

use axum::{
    Json,
    body::Bytes,
    extract::{Path, State},
    http::StatusCode,
};

use crate::{
    AppState, repositories,
    state::{ChunkInfos, Room},
};

pub async fn save_chunk(
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
    bytes: Bytes,
) -> Result<(), StatusCode> {
    println!("Received chunk with id: {} and size: {}", id, bytes.len());

    repositories::persist_chunk(state, id, bytes.to_vec()).await;

    Ok(())
}

pub async fn get_chunk(
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<Vec<u8>, StatusCode> {
    if let Some(chunk) = repositories::fetch_chunk(state, &id).await {
        println!("Retrieved chunk with id: {} and size: {}", id, chunk.len());
        Ok(chunk.clone())
    } else {
        eprintln!("Chunk with id: {} not found", id);
        Err(StatusCode::NOT_FOUND)
    }
}

pub async fn add_chunk_to_room(
    State(state): State<Arc<AppState>>,
    Path(room_id): Path<String>,
    Json(chunk_info): Json<ChunkInfos>,
) {
    println!(
        "Adding chunk with file name: {} to room with id: {}",
        chunk_info.file_name, room_id
    );
    repositories::add_chunk_to_room(state, room_id, chunk_info).await;
}

pub async fn create_room(State(state): State<Arc<AppState>>, Path(id): Path<String>) {
    repositories::create_room(state, id).await;
}

#[axum::debug_handler]
pub async fn get_room_content(
    State(state): State<Arc<AppState>>,
    Path(id): Path<String>,
) -> Result<Json<Room>, StatusCode> {
    print!("Fetching content for room with id: {}", id);
    let mut rooms = state.rooms.lock().unwrap();
    let room = rooms.entry(id).or_insert(Room::new());
    Ok(Json(room.clone()))
}
