# Go Tutorial - PostgreSQL Database Connection

A simple Go application that demonstrates connecting to PostgreSQL database with structured logging and configurable environment variables.

## Features

- PostgreSQL database connection using `lib/pq` driver
- Configurable database connection parameters via environment variables
- Structured JSON logging using Go's standard `log/slog` package
- Connection pooling with optimized settings
- Comprehensive error handling and logging
- Health check with database ping

## Prerequisites

- Go 1.25.7 or later
- PostgreSQL database (local installation or Docker)

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to project directory
cd go-tut/claude-tut

# Download dependencies
go mod tidy
```

### 2. Database Setup Options

#### Option A: Using Docker (Recommended for Development)

Create and run a PostgreSQL container:

```bash
# Run PostgreSQL in Docker
docker run --name tutorial-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=tutorial_db \
  -p 5432:5432 \
  -d postgres:15-alpine

# Verify container is running
docker ps
```

#### Option B: Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    container_name: tutorial-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: tutorial_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

Run with Docker Compose:

```bash
# Start PostgreSQL
docker-compose up -d

# Stop PostgreSQL
docker-compose down
```

#### Option C: Local PostgreSQL Installation

If you have PostgreSQL installed locally:

```bash
# Start PostgreSQL service (varies by OS)
# macOS with Homebrew:
brew services start postgresql

# Ubuntu/Debian:
sudo systemctl start postgresql

# Create database
psql -U postgres -c "CREATE DATABASE tutorial_db;"
```

### 3. Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` file with your database credentials:

```bash
# PostgreSQL Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=tutorial_db
DB_SSLMODE=disable
```

### 4. Run the Application

#### Using Make (Recommended)

```bash
# Run the application
make run

# Build the application
make build

# Run development workflow (format, vet, build)
make dev

# Clean build artifacts
make clean

# See all available targets
make help
```

#### Using Go Commands Directly

```bash
# Run directly
go run main.go

# Build and run
go build -o claude-tut main.go
./claude-tut

# Run with custom environment variables
DB_HOST=localhost DB_PORT=5432 go run main.go
```

#### Using Environment Variables

You can override any configuration using environment variables:

```bash
# Run with custom database settings
DB_HOST=192.168.1.100 \
DB_PORT=5433 \
DB_USER=myuser \
DB_PASSWORD=mypassword \
DB_NAME=mydb \
go run main.go
```

## Configuration

The application uses the following environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL server hostname |
| `DB_PORT` | `5432` | PostgreSQL server port |
| `DB_USER` | `postgres` | Database username |
| `DB_PASSWORD` | `password` | Database password |
| `DB_NAME` | `tutorial_db` | Database name |
| `DB_SSLMODE` | `disable` | SSL mode (disable, require, verify-ca, verify-full) |

## Project Structure

```
claude-tut/
├── main.go              # Main application file
├── go.mod              # Go module definition
├── go.sum              # Go module checksums
├── .env.example        # Environment variables template
├── README.md           # This file
├── Makefile           # Build and development commands
└── CLAUDE.md          # Claude Code instructions
```

## Code Overview

### Database Connection (`main.go:32-80`)

- Configurable PostgreSQL connection with environment variables
- Connection pooling (25 max open/idle connections)
- Connection health checking with `db.Ping()`
- Comprehensive error handling and logging

### Logging

The application uses structured JSON logging:

```json
{
  "time": "2026-02-21T13:34:04.980896+05:30",
  "level": "INFO",
  "source": {
    "function": "main.main",
    "file": "/path/to/main.go",
    "line": 51
  },
  "msg": "Successfully connected to PostgreSQL database"
}
```

## Development

### Available Make Targets

```bash
make run      # Run the application
make build    # Build the application binary
make dev      # Full development workflow
make test     # Run tests (when available)
make fmt      # Format code
make vet      # Run static analysis
make deps     # Download and organize dependencies
make clean    # Clean build artifacts
make help     # Show all available targets
```

### Adding New Features

This application provides a foundation with database connectivity. You can extend it by:

1. Adding HTTP handlers for web API endpoints
2. Implementing database models and operations
3. Adding authentication and middleware
4. Creating business logic services

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

```
ERROR Failed to connect to database error="failed to ping database: ..."
```

**Solutions:**
- Verify PostgreSQL is running: `docker ps` or `pg_isready`
- Check connection parameters in `.env` file
- Ensure database exists: `psql -U postgres -l`
- Verify network connectivity: `telnet localhost 5432`

#### 2. Permission Denied

```
ERROR Failed to connect to database error="pq: password authentication failed"
```

**Solutions:**
- Verify username and password in `.env` file
- Check PostgreSQL user permissions
- Ensure database user has access to the specified database

#### 3. Database Does Not Exist

```
ERROR Failed to connect to database error="pq: database \"tutorial_db\" does not exist"
```

**Solutions:**
- Create the database: `psql -U postgres -c "CREATE DATABASE tutorial_db;"`
- Or update `DB_NAME` in `.env` to an existing database

#### 4. Port Already in Use

If using Docker and port 5432 is occupied:

```bash
# Use a different port
docker run --name tutorial-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=tutorial_db \
  -p 5433:5432 \
  -d postgres:15-alpine

# Update .env file
DB_PORT=5433
```

### Docker Commands

```bash
# View PostgreSQL logs
docker logs tutorial-postgres

# Connect to PostgreSQL container
docker exec -it tutorial-postgres psql -U postgres -d tutorial_db

# Stop and remove container
docker stop tutorial-postgres
docker rm tutorial-postgres

# Remove PostgreSQL data volume
docker volume rm tutorial-postgres-data
```

### Database Operations

```bash
# Connect to database
psql -h localhost -U postgres -d tutorial_db

# List databases
\l

# List tables
\dt

# Exit psql
\q
```

## Next Steps

This application provides a solid foundation for building Go applications with PostgreSQL. Consider adding:

- HTTP server with REST API endpoints
- Database migrations
- User authentication
- Business logic and services
- Unit and integration tests
- Docker containerization for the Go application
- CI/CD pipeline

## License

This project is part of a Go tutorial and is intended for educational purposes.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Verify your PostgreSQL setup
3. Review the logs for detailed error messages
4. Ensure all environment variables are correctly set