# Makefile for Go tutorial project

# Binary name
BINARY_NAME=claude-tut

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt
GOVET=$(GOCMD) vet

.PHONY: all build clean test run deps fmt vet help

# Default target
all: deps fmt vet build

# Build the binary
build:
	$(GOBUILD) -o $(BINARY_NAME) -v

# Run the application
run:
	$(GOCMD) run main.go

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)

# Run tests
test:
	$(GOTEST) -v ./...

# Download dependencies
deps:
	$(GOMOD) tidy
	$(GOMOD) verify

# Format Go code
fmt:
	$(GOFMT) ./...

# Run go vet
vet:
	$(GOVET) ./...

# Development workflow - format, vet, test, and build
dev: fmt vet test build

# Install the binary to GOPATH/bin
install:
	$(GOCMD) install

# Help target
help:
	@echo "Available targets:"
	@echo "  all      - Download deps, format, vet, and build"
	@echo "  build    - Build the binary"
	@echo "  run      - Run the application directly"
	@echo "  clean    - Clean build artifacts"
	@echo "  test     - Run tests"
	@echo "  deps     - Download and verify dependencies"
	@echo "  fmt      - Format Go code"
	@echo "  vet      - Run go vet"
	@echo "  dev      - Full development workflow (fmt, vet, test, build)"
	@echo "  install  - Install binary to GOPATH/bin"
	@echo "  help     - Show this help message"