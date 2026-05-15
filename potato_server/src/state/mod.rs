use sea_orm::DatabaseConnection;
use serde::{Deserialize, Serialize};

#[derive(Clone)]
pub struct AppState {
    pub db: DatabaseConnection,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Room {
    pub chunks_infos: Vec<ChunkInfos>,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct ChunkInfos {
    pub file_name: String,
    pub chunks: Vec<String>,
}
