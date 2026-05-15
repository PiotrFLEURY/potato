mod handlers;
mod repositories;
mod state;

use std::sync::Arc;

use axum::{
    Router,
    routing::{get, post},
};

use crate::state::AppState;

#[tokio::main]
async fn main() {
    let shared_state = Arc::new(AppState::new());

    // build our application with a route
    let app = Router::new()
        .route("/chunks/{id}", post(handlers::save_chunk))
        .route("/chunks/{id}", get(handlers::get_chunk))
        .route("/rooms/{id}", post(handlers::create_room))
        .route("/rooms/{id}", get(handlers::get_room_content))
        .route("/rooms/{id}/chunks", post(handlers::add_chunk_to_room))
        .with_state(shared_state);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
