# Curl queries for testing the potato server

## Save a chunk

```bash
curl -X POST http://localhost:3000/chunks/123 --data-binary "@./tools/potato_mascot.png"
```

## Get a chunk

```bash
curl http://localhost:3000/chunks/123 -o "/tmp/potato_chunk.png"
```