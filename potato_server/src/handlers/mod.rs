use std::sync::Arc;

use axum::{
    body::Bytes,
    extract::{Path, State},
    http::StatusCode,
};

use crate::{AppState, repositories};

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
