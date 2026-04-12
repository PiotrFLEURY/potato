# Curl queries for testing the potato server

## Save a chunk

```bash
curl -X POST http://localhost:3000/chunks/123 --data-binary "@./tools/potato_mascot.png"
```

## Get a chunk

```bash
curl http://localhost:3000/chunks/123 -o "/tmp/potato_chunk.png"
```

## Create a room

```bash
curl -X POST http://localhost:3000/room/1
```

## Add a chunk to a room

```bash
curl -X POST http://localhost:3000/room/1/chunk -H "Content-Type: application/json" -d '{"file_name": "potato_mascot.png", "chunks": ["123"]}'
```

## Get room content

```bash
curl http://localhost:3000/room/1
```