use std::sync::Arc;

use crate::AppState;

pub async fn fetch_chunk(state: Arc<AppState>, id: &String) -> Option<Vec<u8>> {
    state.chunk_store.lock().unwrap().get(id).cloned()
}

pub async fn persist_chunk(state: Arc<AppState>, id: String, bytes: Vec<u8>) {
    state.chunk_store.lock().unwrap().insert(id.clone(), bytes);
}
