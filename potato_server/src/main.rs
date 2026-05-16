mod entities;
mod handlers;
mod repositories;
mod state;

use std::time::Duration;

use axum::{
    Router,
    routing::{get, post},
};
use logs::Logs;
use sea_orm::{ConnectionTrait, Database, DatabaseConnection, DbBackend, Statement};
use state::AppState;
use tokio::time::interval;

async fn setup_schema(db: &DatabaseConnection) {
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

fn setup_purge_task(db: DatabaseConnection) {
    tokio::spawn(async move {
        loop {
            run_purge_task(db.clone()).await;
        }
    });
}

async fn run_purge_task(db: DatabaseConnection) {
    let mut ticker = interval(Duration::from_mins(30));

    loop {
        ticker.tick().await;

        match purge_expired_rooms(&db).await {
            Ok(count) if count > 0 => {
                logs::info!("Purged {} expired rooms", count);
            }
            Err(e) => {
                logs::error!("Cleanup job failed: {}", e);
            }
            _ => {}
        }
    }
}

async fn purge_expired_rooms(db: &DatabaseConnection) -> Result<u64, sea_orm::DbErr> {
    // Les chunks sont supprimés en CASCADE si ta FK est bien configurée
    let output = db
        .execute(Statement::from_string(
            DbBackend::Postgres,
            "DELETE FROM rooms WHERE expires_at < NOW()".to_owned(),
        ))
        .await
        .expect("Failed delete expired rooms");

    Ok(output.rows_affected())
}

#[tokio::main]
async fn main() {
    Logs::new().init();

    let db_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://postgres:postgres@localhost/postgres".to_string());

    let db = Database::connect(&db_url)
        .await
        .expect("Failed to connect to database");

    setup_schema(&db).await;

    setup_purge_task(db.clone());

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
