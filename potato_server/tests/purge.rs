use std::time::Duration;

use potato_server::{entities::rooms, purge_expired_rooms, setup_schema};
use sea_orm::sqlx::types::chrono::Utc;
use sea_orm::{Database, DatabaseConnection, EntityTrait, Set};
use testcontainers_modules::{
    postgres::Postgres,
    testcontainers::{ContainerAsync, runners::AsyncRunner},
};

async fn setup_db() -> (DatabaseConnection, ContainerAsync<Postgres>) {
    let container = Postgres::default().start().await.unwrap();
    let port = container.get_host_port_ipv4(5432).await.unwrap();
    let db_url = format!("postgres://postgres:postgres@localhost:{}/postgres", port);
    let db = Database::connect(&db_url).await.unwrap();
    setup_schema(&db).await;
    (db, container)
}

#[tokio::test]
async fn test_purge_removes_expired_rooms_and_keeps_active_ones() {
    let (db, _container) = setup_db().await;

    rooms::Entity::insert(rooms::ActiveModel {
        id: Set("expired-room".to_string()),
        expires_at: Set(Utc::now() - Duration::from_secs(1)),
    })
    .exec(&db)
    .await
    .unwrap();

    rooms::Entity::insert(rooms::ActiveModel {
        id: Set("active-room".to_string()),
        expires_at: Set(Utc::now() + Duration::from_hours(1)),
    })
    .exec(&db)
    .await
    .unwrap();

    let count = purge_expired_rooms(&db).await.unwrap();

    assert_eq!(count, 1);
    assert!(
        rooms::Entity::find_by_id("expired-room")
            .one(&db)
            .await
            .unwrap()
            .is_none()
    );
    assert!(
        rooms::Entity::find_by_id("active-room")
            .one(&db)
            .await
            .unwrap()
            .is_some()
    );
}

#[tokio::test]
async fn test_purge_returns_zero_when_no_expired_rooms() {
    let (db, _container) = setup_db().await;

    rooms::Entity::insert(rooms::ActiveModel {
        id: Set("active-room".to_string()),
        expires_at: Set(Utc::now() + Duration::from_hours(1)),
    })
    .exec(&db)
    .await
    .unwrap();

    let count = purge_expired_rooms(&db).await.unwrap();

    assert_eq!(count, 0);
}
