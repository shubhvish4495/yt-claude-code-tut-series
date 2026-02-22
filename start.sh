#!/bin/bash

# Go Tutorial - Quick Start Script
# This script helps you quickly set up and run the PostgreSQL Go application

set -e

echo "🚀 Go Tutorial - PostgreSQL Setup"
echo "=================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Function to start PostgreSQL
start_postgres() {
    echo "🐘 Starting PostgreSQL database..."

    # Use docker compose if available, fallback to docker-compose
    if docker compose version &> /dev/null; then
        docker compose up -d postgres
    else
        docker-compose up -d postgres
    fi

    echo "⏳ Waiting for PostgreSQL to be ready..."

    # Wait for PostgreSQL to be healthy
    timeout=60
    counter=0
    while [ $counter -lt $timeout ]; do
        if docker exec tutorial-postgres pg_isready -U postgres &> /dev/null; then
            echo "✅ PostgreSQL is ready!"
            break
        fi

        sleep 2
        counter=$((counter + 2))

        if [ $counter -ge $timeout ]; then
            echo "❌ Timeout waiting for PostgreSQL to start"
            exit 1
        fi
    done
}

# Function to setup environment
setup_env() {
    if [ ! -f .env ]; then
        echo "📝 Creating .env file from template..."
        cp .env.example .env
        echo "✅ Created .env file. You can modify it if needed."
    else
        echo "✅ .env file already exists"
    fi
}

# Function to build and run the Go application
run_app() {
    echo "🔨 Building Go application..."
    go mod tidy
    go build -o claude-tut main.go

    echo "🏃 Running Go application..."
    echo "   Press Ctrl+C to stop"
    echo ""
    ./claude-tut
}

# Main execution
echo "1. Setting up environment variables..."
setup_env

echo ""
echo "2. Starting PostgreSQL database..."
start_postgres

echo ""
echo "3. Building and running the application..."
echo ""
run_app