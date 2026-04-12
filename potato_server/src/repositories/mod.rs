use std::sync::Arc;

use crate::{
    AppState,
    state::{ChunkInfos, Room},
};

pub async fn fetch_chunk(state: Arc<AppState>, id: &String) -> Option<Vec<u8>> {
    state.chunk_store.lock().unwrap().get(id).cloned()
}

pub async fn persist_chunk(state: Arc<AppState>, id: String, bytes: Vec<u8>) {
    state.chunk_store.lock().unwrap().insert(id.clone(), bytes);
}

pub async fn create_room(state: Arc<AppState>, room_id: String) {
    state
        .rooms
        .lock()
        .unwrap()
        .insert(room_id.clone(), Room::new());
}

pub async fn add_chunk_to_room(state: Arc<AppState>, room_id: String, chunk_info: ChunkInfos) {
    if let Some(room) = state.rooms.lock().unwrap().get_mut(&room_id) {
        room.chunks_infos.push(chunk_info);
    }
}
