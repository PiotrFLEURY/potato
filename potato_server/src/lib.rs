pub mod entities;
pub mod handlers;
pub mod hashing;
pub mod repositories;
pub mod state;

use axum::{
    Router,
    routing::{get, post},
};
use sea_orm::{ConnectionTrait, DatabaseConnection, DbBackend, Statement};
use state::AppState;

pub async fn setup_schema(db: &DatabaseConnection) {
    db.execute(Statement::from_string(
        DbBackend::Postgres,
        "CREATE TABLE IF NOT EXISTS rooms (id TEXT PRIMARY KEY, expires_at TIMESTAMPTZ NOT NULL)"
            .to_owned(),
    ))
    .await
    .expect("Failed to create rooms table");

    db.execute(Statement::from_string(
        DbBackend::Postgres,
        "CREATE TABLE IF NOT EXISTS chunks (
            id          TEXT    PRIMARY KEY,
            room_id     TEXT    REFERENCES rooms(id) ON DELETE CASCADE,
            file_name   TEXT,
            chunk_order INTEGER,
            data        BYTEA   NOT NULL
        )"
        .to_owned(),
    ))
    .await
    .expect("Failed to create chunks table");
}

pub fn build_router(state: AppState) -> Router {
    Router::new()
        .route("/chunks/{id}", post(handlers::save_chunk))
        .route("/chunks/{id}", get(handlers::get_chunk))
        .route("/rooms/{id}", post(handlers::create_room))
        .route("/rooms/{id}", get(handlers::get_room_content))
        .route("/rooms/{id}/chunks", post(handlers::add_chunk_to_room))
        .with_state(state)
}
