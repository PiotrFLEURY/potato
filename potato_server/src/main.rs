mod entities;
mod handlers;
mod repositories;
mod state;

use axum::{
    Router,
    routing::{get, post},
};
use sea_orm::{ConnectionTrait, Database, DatabaseConnection, DbBackend, Statement};
use state::AppState;

async fn setup_schema(db: &DatabaseConnection) {
    db.execute(Statement::from_string(
        DbBackend::Postgres,
        "CREATE TABLE IF NOT EXISTS rooms (id TEXT PRIMARY KEY)".to_owned(),
    ))
    .await
    .expect("Failed to create rooms table");

    db.execute(Statement::from_string(
        DbBackend::Postgres,
        "CREATE TABLE IF NOT EXISTS chunks (
            id          TEXT    PRIMARY KEY,
            room_id     TEXT    REFERENCES rooms(id),
            file_name   TEXT,
            chunk_order INTEGER,
            data        BYTEA   NOT NULL
        )"
        .to_owned(),
    ))
    .await
    .expect("Failed to create chunks table");
}

#[tokio::main]
async fn main() {
    let db_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:postgres@localhost/postgres".to_string());

    let db = Database::connect(&db_url)
        .await
        .expect("Failed to connect to database");

    setup_schema(&db).await;

    let state = AppState { db };

    let app = Router::new()
        .route("/chunks/{id}", post(handlers::save_chunk))
        .route("/chunks/{id}", get(handlers::get_chunk))
        .route("/rooms/{id}", post(handlers::create_room))
        .route("/rooms/{id}", get(handlers::get_room_content))
        .route("/rooms/{id}/chunks", post(handlers::add_chunk_to_room))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
