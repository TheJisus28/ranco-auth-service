# 🗄️ Database Schema Versioning Strategy

This microservice implements **golang-migrate** to facilitate systematic schema evolution. By utilizing versioned migration files, we ensure idempotency and structural consistency across distributed environments.

## 🛠️ Tooling and Installation

The migration lifecycle is managed via the `migrate` CLI. It can be initialized using the Go toolchain:

```bash
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

## ⌨️ Core Operations

### 1. Schema Upgrading (Up)

Execute all pending `.up.sql` scripts to transition the database schema to the most recent state.

```bash
migrate -path migrations -database "postgres://user:password@localhost:port/dbname?sslmode=disable" up
```

### 2. Schema Regression (Down)

Revert the current schema to a previous state by executing the corresponding `.down.sql` script. It is standard practice to regress by a single increment to ensure data integrity.

```bash
migrate -path migrations -database "postgres://user:password@localhost:port/dbname?sslmode=disable" down 1
```

### 3. Migration Artifact Generation

Generate a synchronized pair of sequential SQL files. Use concise, descriptive identifiers to document the purpose of the structural change.

```bash
migrate create -ext sql -dir migrations -seq <migration_identifier>
```

### 4. Dirty State Reconciliation

In the event of an unrecoverable failure during execution, the database metadata may be flagged as "dirty," preventing further operations. Once the underlying SQL conflict is resolved manually, use the `force` command to synchronize the schema version (e.g., version 1).

```bash
migrate -path migrations -database "postgres://user:password@localhost:port/dbname?sslmode=disable" force 1
```

## 📖 Reference Material
For comprehensive configuration details regarding connection parameters and driver-specific syntax, refer to the  **[official documentation](https://github.com/golang-migrate/migrate/blob/master/database/postgres/TUTORIAL.md)**.