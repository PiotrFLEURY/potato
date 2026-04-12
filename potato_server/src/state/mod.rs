use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};

#[derive(Clone)]
pub struct AppState {
    pub chunk_store: Arc<Mutex<HashMap<String, Vec<u8>>>>,
}

impl AppState {
    pub fn new() -> Self {
        AppState {
            chunk_store: Arc::new(Mutex::new(HashMap::new())),
        }
    }
}
