# Run Application Dependencies Locally

Analyze the docs/README.md file in the current project and follow the setup instructions to run the application locally with all required dependencies. Give preference to Docker for databases and external services when available.

## Instructions

1. **Read and Analyze docs/README.md**
   - Parse the docs/README.md file to understand the project setup requirements
   - Identify all dependencies, databases, and external services needed
   - Extract specific setup and configuration steps

2. **Database and Service Setup (Prefer Docker)**
   - **If Docker is available**: Use Docker or Docker Compose for databases and external services
   - Follow Docker setup instructions from docs/README.md if provided
   - If no Docker instructions exist, suggest Docker alternatives for databases
   - **Do NOT run the main application server in Docker** - it will be run separately

3. **Environment Configuration**
   - Set up required environment variables as specified in docs/README.md
   - Copy example environment files if they exist (.env.example → .env)
   - Configure database connection parameters and other settings

4. **Dependency Installation**
   - Install project dependencies using the package manager specified in docs/README.md
   - This could be npm install, pip install, go mod tidy, bundle install, etc.
   - Verify dependencies are properly installed

5. **Service Verification**
   - Test that databases and external services are running and accessible
   - Verify connections before starting the main application
   - Check service health endpoints or connection tests

6. **Application Startup**
   - **IMPORTANT**: Do NOT run the main application server in Docker
   - Run the server as a separate long-running background job in Claude bash
   - Use the run commands specified in docs/README.md (make run, npm start, go run, etc.)
   - Monitor startup logs to ensure successful initialization

## Key Principles

- **Docker Preference**: Always prefer Docker for databases (PostgreSQL, MongoDB, Redis, etc.) and external services
- **No Code Changes**: DO NOT MAKE ANY CHANGES TO CODE FILES - this command is only for running existing code
- **Suggest Only**: If improvements are needed, suggest them but do not implement changes
- **Background Execution**: Run the main application server in a separate long-running background process
- **Follow README**: Strictly follow the setup instructions provided in the project's docs/README.md

## Expected Behavior

The command will:
1. Read the project's docs/README.md
2. Set up all dependencies using Docker when possible
3. Configure environment variables
4. Start all required services
5. Launch the application server in the background
6. Provide status and connection information

**WARNING: This is a run-only command. Do not modify any source code files during execution.**