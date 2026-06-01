use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use potato_server::{build_router, hashing::hash_room_code, setup_schema, state::AppState};
use sea_orm::Database;
use serde_json::{Value, json};
use testcontainers_modules::{
    postgres::Postgres,
    testcontainers::{ContainerAsync, runners::AsyncRunner},
};
use tower::ServiceExt;
use uuid::Uuid;

async fn setup() -> (axum::Router, ContainerAsync<Postgres>) {
    let container = Postgres::default().start().await.unwrap();
    let port = container.get_host_port_ipv4(5432).await.unwrap();
    let db_url = format!("postgres://postgres:postgres@localhost:{}/postgres", port);
    let db = Database::connect(&db_url).await.unwrap();
    setup_schema(&db).await;
    let app = build_router(AppState { db });
    (app, container)
}

async fn body_json(body: axum::body::Body) -> Value {
    let bytes = body.collect().await.unwrap().to_bytes();
    serde_json::from_slice(&bytes).unwrap()
}

#[tokio::test]
async fn test_save_and_get_chunk() {
    let (app, _container) = setup().await;

    let chunk_id = Uuid::new_v4().to_string();

    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"hello world".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    assert_eq!(&bytes[..], b"hello world");
}

#[tokio::test]
async fn test_get_chunk_not_found() {
    let (app, _container) = setup().await;

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri("/chunks/nonexistent")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn test_save_chunk_is_idempotent() {
    let (app, _container) = setup().await;

    let chunk_id = Uuid::new_v4().to_string();

    for data in [b"v1".as_ref(), b"v2".as_ref()] {
        let res = app
            .clone()
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri(&format!("/chunks/{}", chunk_id))
                    .body(Body::from(data.to_vec()))
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(res.status(), StatusCode::OK);
    }

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    let bytes = res.into_body().collect().await.unwrap().to_bytes();
    assert_eq!(&bytes[..], b"v2");
}

#[tokio::test]
async fn test_create_room_wrong_id() {
    let (app, _container) = setup().await;

    let room_id = "invalid-id!";

    let res = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn test_create_room_and_get_content() {
    let (app, _container) = setup().await;

    let room_id = "ROOM1234";

    // create room
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // save chunk
    let chunk_id = Uuid::new_v4().to_string();
    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"data".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();

    // add chunk to room
    let payload =
        serde_json::to_string(&json!({ "file_name": "test.txt", "chunks": [chunk_id] })).unwrap();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_id))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // get room content
    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_json(res.into_body()).await;
    assert_eq!(body["chunks_infos"][0]["file_name"], "test.txt");
    assert_eq!(body["chunks_infos"][0]["chunks"][0], chunk_id);
}

#[tokio::test]
async fn test_create_room_and_get_content_from_hash() {
    let (app, _container) = setup().await;

    let room_id = "ABCD1234";
    let room_hash = hash_room_code(room_id);

    // create room
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // save chunk
    let chunk_id = Uuid::new_v4().to_string();
    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"data".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();

    // add chunk to room
    let payload =
        serde_json::to_string(&json!({ "file_name": "test.txt", "chunks": [&chunk_id] })).unwrap();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_id))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // get room content
    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_hash))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_json(res.into_body()).await;
    assert_eq!(body["chunks_infos"][0]["file_name"], "test.txt");
    assert_eq!(body["chunks_infos"][0]["chunks"][0], chunk_id);
}

#[tokio::test]
async fn test_create_room_hash_and_get_content_from_hash() {
    let (app, _container) = setup().await;

    let room_id = "ABCD1234";
    let room_hash = hash_room_code(room_id);

    // create room
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}", room_hash))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // save chunk
    let chunk_id = Uuid::new_v4().to_string();
    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"data".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();

    // add chunk to room
    let payload =
        serde_json::to_string(&json!({ "file_name": "test.txt", "chunks": [&chunk_id] })).unwrap();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_hash))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // get room content
    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_hash))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_json(res.into_body()).await;
    assert_eq!(body["chunks_infos"][0]["file_name"], "test.txt");
    assert_eq!(body["chunks_infos"][0]["chunks"][0], chunk_id);
}

#[tokio::test]
async fn test_create_room_hash_and_get_content_from_room_id() {
    let (app, _container) = setup().await;

    let room_id = "ABCD1234";
    let room_hash = hash_room_code(room_id);

    // create room
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}", room_hash))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // save chunk
    let chunk_id = Uuid::new_v4().to_string();
    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"data".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();

    // add chunk to room
    let payload =
        serde_json::to_string(&json!({ "file_name": "test.txt", "chunks": [&chunk_id] })).unwrap();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_hash))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    // get room content
    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);
    let body = body_json(res.into_body()).await;
    assert_eq!(body["chunks_infos"][0]["file_name"], "test.txt");
    assert_eq!(body["chunks_infos"][0]["chunks"][0], chunk_id);
}

#[tokio::test]
async fn test_get_room_with_invalid_id() {
    let (app, _container) = setup().await;

    let room_id = "invalid-id!";

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn test_add_chunk_to_room_creates_room_implicitly() {
    let (app, _container) = setup().await;

    let room_id = "1234ABCD";
    let chunk_id = Uuid::new_v4().to_string();

    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/chunks/{}", chunk_id))
                .body(Body::from(b"bytes".to_vec()))
                .unwrap(),
        )
        .await
        .unwrap();

    let payload =
        serde_json::to_string(&json!({ "file_name": "file.bin", "chunks": [&chunk_id] })).unwrap();
    let res = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_id))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(res.status(), StatusCode::OK);

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    let body = body_json(res.into_body()).await;
    assert_eq!(body["chunks_infos"][0]["file_name"], "file.bin");
    assert_eq!(body["chunks_infos"][0]["chunks"][0], chunk_id);
}

#[tokio::test]
async fn test_room_preserves_chunk_order() {
    let (app, _container) = setup().await;

    let room_id = "A1B2C3D4";

    let chunk_id_1 = Uuid::new_v4().to_string();
    let chunk_id_2 = Uuid::new_v4().to_string();
    let chunk_id_3 = Uuid::new_v4().to_string();

    for id in [&chunk_id_1, &chunk_id_2, &chunk_id_3] {
        app.clone()
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri(format!("/chunks/{id}"))
                    .body(Body::from(id.as_bytes().to_vec()))
                    .unwrap(),
            )
            .await
            .unwrap();
    }

    let payload = serde_json::to_string(
        &json!({ "file_name": "multi.bin", "chunks": [&chunk_id_1, &chunk_id_2, &chunk_id_3] }),
    )
    .unwrap();
    app.clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri(&format!("/rooms/{}/chunks", room_id))
                .header("content-type", "application/json")
                .body(Body::from(payload))
                .unwrap(),
        )
        .await
        .unwrap();

    let res = app
        .oneshot(
            Request::builder()
                .method("GET")
                .uri(&format!("/rooms/{}", room_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    let body = body_json(res.into_body()).await;
    let chunks = &body["chunks_infos"][0]["chunks"];
    assert_eq!(chunks[0], chunk_id_1);
    assert_eq!(chunks[1], chunk_id_2);
    assert_eq!(chunks[2], chunk_id_3);
}
