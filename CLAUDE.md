# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple Go tutorial project featuring basic structured logging. The project consists of a single main.go file that demonstrates JSON-formatted logging using Go's standard `log/slog` package.

## Common Commands

### Using Make (Recommended)
```bash
# Run the application
make run

# Build the application
make build

# Run full development workflow (format, vet, test, build)
make dev

# Clean build artifacts
make clean

# Run tests
make test

# Format code and run static analysis
make fmt
make vet

# Download and organize dependencies
make deps

# See all available targets
make help
```

### Direct Go Commands
```bash
# Run the application
go run main.go

# Build the application
go build -o claude-tut main.go

# Run the built binary
./claude-tut
```

### Go Module Management
```bash
# Initialize Go module (already done)
go mod init github.com/ssaurav/go-tut/claude-tut

# Download and organize dependencies
go mod tidy

# Verify dependencies
go mod verify
```

### Development and Testing
```bash
# Format code
go fmt ./...

# Run static analysis
go vet ./...

# Run tests (when test files exist)
go test ./...

# Run tests with verbose output
go test -v ./...

# Run a specific test
go test -run TestFunctionName
```

## Code Architecture

### Current Structure
- **main.go**: Entry point containing a simple structured logger setup using `log/slog`
  - Configures JSON output handler
  - Enables source location logging
  - Sets log level to Info
  - Demonstrates basic logging functionality

### Key Components
- **Logging**: Uses Go's standard `log/slog` package for structured JSON logging
  - JSON format for machine-readable logs
  - Source location tracking enabled
  - Info level logging configured

## Go Version
- Requires Go 1.25.7 or compatible version
- Uses standard library packages only (no external dependencies)