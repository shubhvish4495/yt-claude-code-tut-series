# Claude Code Tutorial

A hands-on tutorial designed to help developers master **[Claude Code](https://claude.com/claude-code)** through practical examples. This repository demonstrates how to effectively collaborate with Claude Code to build, maintain, and evolve software projects using real-world scenarios.

## 🎯 What You'll Learn About Claude Code

This repository serves as a practical playground for mastering Claude Code's capabilities:

### 1. **Project Setup & Scaffolding**
- How Claude Code can initialize projects with proper structure
- Setting up development toolchains (Makefiles, Docker, etc.)
- Creating and managing configuration files

### 2. **Code Development & Enhancement**
- Writing clean, maintainable code with Claude Code's assistance
- Implementing features through natural language descriptions
- Adding new functionality to existing projects

### 3. **Code Analysis & Understanding**
- Using Claude Code to understand existing codebases
- Identifying and fixing bugs through conversation
- Code review and optimization suggestions

### 4. **DevOps & Deployment**
- Managing Docker containers and services
- Setting up development and production environments
- Implementing best practices for deployment

## 🚀 Getting Started

### Prerequisites
- A modern development environment
- Docker and Docker Compose (for services)
- Basic familiarity with command line tools

### Quick Start
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd claude-tut
   ```

2. **Start the services** (using Docker)
   ```bash
   docker-compose up -d
   ```

3. **Run the application**
   ```bash
   make run
   ```

4. **Test the endpoints**
   ```bash
   # Health check
   curl http://localhost:8080/health

   # API endpoints
   curl http://localhost:8080/users
   ```

## 📝 Claude Code Learning Examples

Here are practical examples you can try with Claude Code using this project:

### Example 1: Adding a New Feature
**Prompt:** "Add a new API endpoint to create resources"

Claude Code will:
1. Analyze the existing code structure
2. Add the new handler function
3. Update the routing configuration
4. Include proper error handling and validation
5. Test the new functionality

### Example 2: Code Optimization
**Prompt:** "Optimize the database connection handling for better performance"

Claude Code will:
1. Review current database patterns
2. Suggest connection pooling improvements
3. Add proper timeout configurations
4. Implement retry mechanisms

### Example 3: Adding Tests
**Prompt:** "Create comprehensive tests for the API handlers"

Claude Code will:
1. Create test files following best practices
2. Mock external dependencies
3. Test various scenarios (success, error cases)
4. Add comprehensive test coverage

## 📂 Project Structure

```
claude-tut/
├── main.go              # Main application entry point
├── Makefile            # Development commands
├── docker-compose.yml  # Service configuration
├── init.sql            # Database initialization
├── start.sh            # Startup script
├── CLAUDE.md           # Claude Code specific instructions
└── README.md           # This file
```

## 🔧 Available Commands

### Using Make (Recommended)
```bash
make help           # Show all available commands
make run            # Run the application
make build          # Build the application
make dev            # Full development workflow
make test           # Run tests
make deps           # Download dependencies
make clean          # Clean build artifacts
```

### Direct Commands
```bash
# Run the application directly
make run

# Build the application
make build

# Manage dependencies
make deps

# Run tests
make test
```

## 🐳 Service Setup

The project includes containerized services for easy development:

### Start Services
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d database

# Start with additional tools (optional)
docker-compose --profile tools up -d
```

### Configuration
Default connection settings (customizable via environment variables):
- **Host:** localhost
- **Port:** Application-specific
- **Database:** Configured via Docker Compose
- **Other services:** See docker-compose.yml

### Environment Variables
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=password
export DB_NAME=tutorial_db
export PORT=8080
```

## 🎓 Learning Path with Claude Code

### Beginner Level
1. **Code Understanding:** Ask Claude Code to explain existing functions and patterns
2. **Simple Modifications:** Change response messages, add logging, or update configurations
3. **Configuration:** Modify environment variables and settings

### Intermediate Level
1. **Feature Addition:** Add new API endpoints or functionality
2. **Error Handling:** Improve error responses and validation
3. **Testing:** Create unit and integration tests

### Advanced Level
1. **Architecture Changes:** Restructure code for better maintainability
2. **Performance Optimization:** Improve queries, caching, and response times
3. **Production Features:** Add authentication, rate limiting, monitoring

## 💡 Tips for Using Claude Code

1. **Be Specific:** Provide clear requirements for better results
2. **Iterative Development:** Build features incrementally
3. **Ask for Explanations:** Don't hesitate to ask "why" and "how"
4. **Code Review:** Ask Claude Code to review your changes
5. **Best Practices:** Request adherence to coding conventions and patterns

## 📚 What This Tutorial Demonstrates

Through practical examples, you'll learn how Claude Code helps with:

- **Clean Architecture:** Organizing code with proper separation of concerns
- **Error Handling:** Implementing comprehensive error handling patterns
- **Logging:** Setting up structured logging for production applications
- **Database Integration:** Creating safe and efficient database operations
- **API Development:** Building well-structured API endpoints
- **Configuration Management:** Managing environment-based configuration
- **Development Workflow:** Establishing complete development and deployment processes

## 🤝 Contributing

This is a Claude Code learning repository! Feel free to:
- Practice adding new features with Claude Code's help
- Improve existing code through Claude Code collaboration
- Create examples of effective Claude Code prompts
- Add more comprehensive tests using Claude Code
- Enhance documentation with Claude Code assistance

When contributing, try using Claude Code to:
1. Analyze the impact of your changes
2. Ensure code quality and consistency
3. Update related documentation
4. Create appropriate tests

## 📖 Additional Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Docker Documentation](https://docs.docker.com/)
- [Database Documentation](https://www.postgresql.org/docs/)
- [API Design Best Practices](https://restfulapi.net/)

---

**Happy learning with Claude Code!** 🚀

This tutorial grows with you as you explore the powerful collaboration between human creativity and AI assistance in software development.