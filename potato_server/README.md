# Potato Server

A lightweight HTTP server for chunked binary storage, built with Rust, Axum, and PostgreSQL.

Potato lets clients upload files as ordered binary chunks and group them into **rooms** — shared namespaces that keep track of which chunks belong to which file, in which order.

## Architecture overview

```
Client
  │
  ▼
Axum Router (port 3000)
  │
  ├── handlers/   — HTTP request/response logic
  ├── repositories/ — database queries (SeaORM)
  ├── entities/   — ORM models (chunks, rooms)
  └── state/      — shared app state + domain types
```

### Data model

```
rooms
  └─ id  TEXT  PRIMARY KEY

chunks
  └─ id           TEXT    PRIMARY KEY
  └─ room_id      TEXT    → rooms(id)
  └─ file_name    TEXT
  └─ chunk_order  INTEGER
  └─ data         BYTEA
```

A **room** is a named container. A **chunk** is a raw binary blob. Chunks are associated to a room with an ordering index and a file name, so a large file can be uploaded in pieces and reassembled in order.

## API

### Chunks

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/chunks/{id}` | Upload a raw binary chunk. Body is the raw bytes. Upserts on conflict. |
| `GET`  | `/chunks/{id}` | Download a chunk's raw bytes. Returns `404` if not found. |

### Rooms

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/rooms/{id}` | Create a room. No-op if it already exists. |
| `GET`  | `/rooms/{id}` | Get all chunks in the room, grouped by file and sorted by order. |
| `POST` | `/rooms/{id}/chunks` | Associate uploaded chunks to a room and file name. |

#### `POST /rooms/{id}/chunks` — body

```json
{
  "file_name": "example.mp4",
  "chunks": ["chunk-id-1", "chunk-id-2", "chunk-id-3"]
}
```

The `chunks` array defines the ordered list of chunk IDs that make up `file_name`.

#### `GET /rooms/{id}` — response

```json
{
  "chunks_infos": [
    {
      "file_name": "example.mp4",
      "chunks": ["chunk-id-1", "chunk-id-2", "chunk-id-3"]
    }
  ]
}
```

## Tech stack

| Crate | Role |
|-------|------|
| [axum](https://github.com/tokio-rs/axum) | HTTP framework |
| [tokio](https://tokio.rs) | Async runtime |
| [sea-orm](https://www.sea-ql.org/SeaORM/) | Async ORM (PostgreSQL) |
| [serde](https://serde.rs) | JSON serialization |

## Getting started

### Prerequisites

- Rust (edition 2024)
- A running PostgreSQL instance

### Run

```bash
# Default: postgres://postgres:postgres@localhost/postgres
DATABASE_URL=postgres://user:password@host/dbname cargo run
```

The server creates the `rooms` and `chunks` tables automatically on startup if they do not exist.

The server listens on **`0.0.0.0:3000`**.

### Example workflow

```bash
# 1. Upload two chunks
curl -X POST http://localhost:3000/chunks/chunk-1 --data-binary @part1.bin
curl -X POST http://localhost:3000/chunks/chunk-2 --data-binary @part2.bin

# 2. Create a room and associate the chunks
curl -X POST http://localhost:3000/rooms/my-room
curl -X POST http://localhost:3000/rooms/my-room/chunks \
  -H "Content-Type: application/json" \
  -d '{"file_name":"file.bin","chunks":["chunk-1","chunk-2"]}'

# 3. Retrieve the room manifest
curl http://localhost:3000/rooms/my-room

# 4. Download a chunk
curl http://localhost:3000/chunks/chunk-1 -o part1.bin
```
