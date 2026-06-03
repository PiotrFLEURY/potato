use std::time::Duration;

use logs::Logs;
use potato_server::{build_router, purge_expired_rooms, setup_schema, state::AppState};
use sea_orm::{Database, DatabaseConnection};
use tokio::time::interval;

fn setup_purge_task(db: DatabaseConnection) {
    tokio::spawn(async move {
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
    });
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

    let app = build_router(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
