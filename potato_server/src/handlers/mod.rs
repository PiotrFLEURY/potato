use axum::{
    Json,
    body::Bytes,
    extract::{Path, State},
    http::StatusCode,
};

use crate::{
    repositories,
    state::{AppState, ChunkInfos, Room},
};

pub async fn save_chunk(
    State(state): State<AppState>,
    Path(id): Path<String>,
    bytes: Bytes,
) -> Result<(), StatusCode> {
    println!("Received chunk with id: {} and size: {}", id, bytes.len());
    repositories::persist_chunk(&state.db, id, bytes.to_vec()).await;
    Ok(())
}

pub async fn get_chunk(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Vec<u8>, StatusCode> {
    match repositories::fetch_chunk(&state.db, &id).await {
        Some(data) => {
            println!("Retrieved chunk with id: {} and size: {}", id, data.len());
            Ok(data)
        }
        None => {
            eprintln!("Chunk with id: {} not found", id);
            Err(StatusCode::NOT_FOUND)
        }
    }
}

pub async fn create_room(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<(), StatusCode> {
    match repositories::create_room(&state.db, id).await {
        Ok(_) => Ok(()),
        Err(err) => {
            eprintln!("Error creating room: {}", err);
            Err(StatusCode::BAD_REQUEST)
        }
    }
}

pub async fn get_room_content(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<Room>, StatusCode> {
    println!("Fetching content for room with id: {}", id);
    match repositories::get_room_content(&state.db, &id).await {
        Ok(room) => Ok(Json(room)),
        Err(err) => {
            eprintln!("Error fetching room content: {}", err);
            Err(StatusCode::BAD_REQUEST)
        }
    }
}

pub async fn add_chunk_to_room(
    State(state): State<AppState>,
    Path(room_id): Path<String>,
    Json(chunk_info): Json<ChunkInfos>,
) -> Result<(), StatusCode> {
    println!(
        "Adding chunk with file name: {} to room with id: {}",
        chunk_info.file_name, room_id
    );
    match repositories::add_chunk_to_room(&state.db, room_id, chunk_info).await {
        Ok(_) => Ok(()),
        Err(err) => {
            eprintln!("Error adding chunk to room: {}", err);
            Err(StatusCode::BAD_REQUEST)
        }
    }
}
