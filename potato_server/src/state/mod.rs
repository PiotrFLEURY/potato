use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};

use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub struct Room {
    pub chunks_infos: Vec<ChunkInfos>,
}

impl Room {
    pub fn new() -> Self {
        Room {
            chunks_infos: Vec::new(),
        }
    }
}

#[derive(Clone, Serialize, Deserialize)]
pub struct ChunkInfos {
    pub file_name: String,
    pub chunks: Vec<String>,
}

#[derive(Clone)]
pub struct AppState {
    pub chunk_store: Arc<Mutex<HashMap<String, Vec<u8>>>>,
    pub rooms: Arc<Mutex<HashMap<String, Room>>>,
}

impl AppState {
    pub fn new() -> Self {
        AppState {
            chunk_store: Arc::new(Mutex::new(HashMap::new())),
            rooms: Arc::new(Mutex::new(HashMap::new())),
        }
    }
}
