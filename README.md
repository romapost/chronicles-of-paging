# Chronicles of paging
## docker: two services/containers:
1. PostgreSQL database, version 12.3, with sample CSV data and initialize scripts.
2. Web PGAdmin, version 4.24, with default server configuration and sample CSV data.

Command: `docker-compose up -d`

Usage: `http://localhost:5050`. Login: `cop`, password: `postgres`. Database password: `postgres`.
Schema: `cop`.

## sql: sql tests for offset and cursor pagings
