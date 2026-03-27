# Run Application Dependencies Locally

Analyze the dummy-server/docs/README.md file in the current project and follow the setup instructions to run the application locally with all required dependencies. The main server application is located in the `dummy-server/` directory. Give preference to Docker for databases and external services when available.

## Instructions

1. **Read and Analyze dummy-server/docs/README.md**
   - Parse the dummy-server/docs/README.md file to understand the project setup requirements
   - Identify all dependencies, databases, and external services needed
   - Extract specific setup and configuration steps

2. **Database and Service Setup (Prefer Docker)**
   - **Navigate to dummy-server directory**: `cd dummy-server/`
   - **If Docker is available**: Use Docker or Docker Compose for databases and external services
   - Follow Docker setup instructions from dummy-server/docs/README.md if provided
   - The `docker-compose.yml` file is located in the `dummy-server/` directory
   - Start PostgreSQL database: `docker-compose up -d postgres`
   - If no Docker instructions exist, suggest Docker alternatives for databases
   - **Do NOT run the main application server in Docker** - it will be run separately

3. **Environment Configuration**
   - **Ensure you're in dummy-server directory**: `cd dummy-server/`
   - Set up required environment variables as specified in dummy-server/docs/README.md
   - Copy example environment files if they exist (.env.example → .env)
   - Configure database connection parameters (DB_HOST, DB_PORT, DB_USER, etc.)
   - The Go application uses environment variables for database configuration

4. **Dependency Installation**
   - **Ensure you're in dummy-server directory**: `cd dummy-server/`
   - Install Go module dependencies: `go mod tidy`
   - The project uses Go modules (go.mod and go.sum files are in dummy-server/)
   - Verify dependencies are properly installed and up to date
   - Check for any missing dependencies or version conflicts

5. **Service Verification**
   - Test that PostgreSQL database is running and accessible
   - Verify Docker containers are healthy: `docker ps`
   - Check PostgreSQL connection: `docker exec tutorial-postgres pg_isready -U postgres`
   - Ensure port 5432 (PostgreSQL) is available for the application
   - Verify connections before starting the main application

6. **Application Startup**
   - **IMPORTANT**: Do NOT run the main application server in Docker
   - **Navigate to the dummy-server directory**: `cd dummy-server/`
   - Run the server as a separate long-running background job in Claude bash
   - Use Make commands: `make run` (preferred) or direct Go command: `go run main.go`
   - Alternatively, use the startup script: `./start.sh`
   - Monitor startup logs to ensure successful database connection and server initialization
   - Verify the server starts on port 8080 (default) or configured PORT environment variable

## Key Principles

- **Docker Preference**: Always prefer Docker for databases (PostgreSQL, MongoDB, Redis, etc.) and external services
- **No Code Changes**: DO NOT MAKE ANY CHANGES TO CODE FILES - this command is only for running existing code
- **Suggest Only**: If improvements are needed, suggest them but do not implement changes
- **Background Execution**: Run the main application server in a separate long-running background process
- **Follow README**: Strictly follow the setup instructions provided in the project's dummy-server/docs/README.md

## Expected Behavior

The command will:
1. Read the project's dummy-server/docs/README.md
2. Navigate to the dummy-server/ directory for all operations
3. Set up PostgreSQL database using Docker Compose
4. Install Go module dependencies with `go mod tidy`
5. Configure environment variables for database connection
6. Start all required services (PostgreSQL via Docker)
7. Launch the Go HTTP server in the background
8. Verify the server is accessible on port 8080
9. Provide status and connection information

**WARNING: This is a run-only command. Do not modify any source code files during execution.**