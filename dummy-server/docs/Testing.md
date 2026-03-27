# Testing Guide for Go Tutorial Server

This document provides comprehensive testing guidelines and examples for the Go tutorial server application, including database mocking strategies using `go-sqlmock`.

## Table of Contents

- [Overview](#overview)
- [Testing Strategy](#testing-strategy)
- [Setting Up Tests](#setting-up-tests)
- [Database Testing with go-sqlmock](#database-testing-with-go-sqlmock)
- [HTTP Handler Testing](#http-handler-testing)
- [Integration Testing](#integration-testing)
- [Test Examples](#test-examples)
- [Best Practices](#best-practices)
- [Running Tests](#running-tests)

## Overview

The Go tutorial server is a HTTP API with PostgreSQL database integration. Our testing strategy covers:

- **Unit Tests**: Individual functions and handlers
- **Database Mocking**: Using `DATA-DOG/go-sqlmock` for database interactions
- **HTTP Testing**: Using `httptest` for HTTP handlers
- **Integration Tests**: End-to-end testing with real database

## Testing Strategy

### Test Types

1. **Unit Tests**: Test individual functions in isolation
2. **Handler Tests**: Test HTTP handlers with mocked dependencies
3. **Database Tests**: Test database operations with mocked SQL
4. **Integration Tests**: Test complete workflows with real dependencies

### Test Structure

```
dummy-server/
├── main.go
├── main_test.go           # Main function and integration tests
├── handlers_test.go       # HTTP handler tests
├── database_test.go       # Database operation tests
└── testdata/             # Test fixtures and data
```

## Setting Up Tests

### Dependencies

Add the following test dependencies to your `go.mod`:

```bash
go get github.com/DATA-DOG/go-sqlmock
go get github.com/stretchr/testify
```

### Required Imports

```go
import (
    "testing"
    "net/http"
    "net/http/httptest"
    "database/sql"
    "log/slog"
    "os"
    "bytes"
    "encoding/json"

    "github.com/DATA-DOG/go-sqlmock"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)
```

## Database Testing with go-sqlmock

### Why go-sqlmock?

`DATA-DOG/go-sqlmock` is the preferred library for mocking database interactions because:

- **Fast**: No need for real database connections
- **Reliable**: Consistent test results without external dependencies
- **Comprehensive**: Supports all SQL operations and edge cases
- **Isolated**: Each test runs independently

### Basic Setup

```go
func setupMockDB(t *testing.T) (*sql.DB, sqlmock.Sqlmock) {
    db, mock, err := sqlmock.New(sqlmock.QueryMatcherOption(sqlmock.QueryMatcherEqual))
    require.NoError(t, err)
    return db, mock
}

func setupTestLogger() *slog.Logger {
    return slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelError, // Reduce noise during tests
    }))
}
```

### Database Test Examples

#### Testing Database Connection

```go
func TestConnectToPostgreSQL(t *testing.T) {
    tests := []struct {
        name    string
        env     map[string]string
        wantErr bool
    }{
        {
            name: "successful connection with default values",
            env:  map[string]string{},
            wantErr: false, // This would fail in real test, but demonstrates structure
        },
        {
            name: "custom database configuration",
            env: map[string]string{
                "DB_HOST": "testhost",
                "DB_PORT": "5433",
                "DB_USER": "testuser",
                "DB_NAME": "testdb",
            },
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Set environment variables
            for key, value := range tt.env {
                os.Setenv(key, value)
                defer os.Unsetenv(key)
            }

            logger := setupTestLogger()

            // Note: This test requires a real database for full integration
            // For unit testing, we'd mock the sql.Open and db.Ping calls
            _, err := connectToPostgreSQL(logger)

            if tt.wantErr {
                assert.Error(t, err)
            } else {
                // In a real test environment with database
                assert.NoError(t, err)
            }
        })
    }
}
```

#### Testing User Queries

```go
func TestGetUsersQuery(t *testing.T) {
    db, mock := setupMockDB(t)
    defer db.Close()

    tests := []struct {
        name           string
        mockSetup      func(sqlmock.Sqlmock)
        expectedUsers  int
        expectError    bool
    }{
        {
            name: "successful query with users",
            mockSetup: func(mock sqlmock.Sqlmock) {
                rows := sqlmock.NewRows([]string{"id", "name", "email", "created_at"}).
                    AddRow(1, "John Doe", "john@example.com", "2023-01-01 10:00:00").
                    AddRow(2, "Jane Smith", "jane@example.com", "2023-01-02 11:00:00")

                mock.ExpectQuery("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC").
                    WillReturnRows(rows)
            },
            expectedUsers: 2,
            expectError:   false,
        },
        {
            name: "empty result set",
            mockSetup: func(mock sqlmock.Sqlmock) {
                rows := sqlmock.NewRows([]string{"id", "name", "email", "created_at"})
                mock.ExpectQuery("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC").
                    WillReturnRows(rows)
            },
            expectedUsers: 0,
            expectError:   false,
        },
        {
            name: "database error",
            mockSetup: func(mock sqlmock.Sqlmock) {
                mock.ExpectQuery("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC").
                    WillReturnError(sql.ErrConnDone)
            },
            expectedUsers: 0,
            expectError:   true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            tt.mockSetup(mock)

            logger := setupTestLogger()

            // Create a test HTTP request and response recorder
            req := httptest.NewRequest("GET", "/users", nil)
            w := httptest.NewRecorder()

            // Call the handler
            getUsersHandler(db, logger, w, req)

            // Verify mock expectations
            assert.NoError(t, mock.ExpectationsWereMet())

            if tt.expectError {
                assert.Equal(t, http.StatusInternalServerError, w.Code)
            } else {
                assert.Equal(t, http.StatusOK, w.Code)

                var response map[string]interface{}
                err := json.Unmarshal(w.Body.Bytes(), &response)
                assert.NoError(t, err)

                users, exists := response["users"].([]interface{})
                assert.True(t, exists)
                assert.Len(t, users, tt.expectedUsers)

                count, exists := response["count"].(float64)
                assert.True(t, exists)
                assert.Equal(t, float64(tt.expectedUsers), count)
            }
        })
    }
}
```

## HTTP Handler Testing

### Health Check Handler

```go
func TestHealthHandler(t *testing.T) {
    tests := []struct {
        name           string
        mockSetup      func(sqlmock.Sqlmock)
        expectedStatus int
        expectedBody   map[string]string
    }{
        {
            name: "healthy database",
            mockSetup: func(mock sqlmock.Sqlmock) {
                mock.ExpectPing()
            },
            expectedStatus: http.StatusOK,
            expectedBody: map[string]string{
                "status":   "healthy",
                "database": "connected",
            },
        },
        {
            name: "unhealthy database",
            mockSetup: func(mock sqlmock.Sqlmock) {
                mock.ExpectPing().WillReturnError(sql.ErrConnDone)
            },
            expectedStatus: http.StatusServiceUnavailable,
            expectedBody: map[string]string{
                "status": "unhealthy",
                "error":  "database unreachable",
            },
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            db, mock := setupMockDB(t)
            defer db.Close()

            tt.mockSetup(mock)

            logger := setupTestLogger()
            handler := healthHandler(db, logger)

            req := httptest.NewRequest("GET", "/health", nil)
            w := httptest.NewRecorder()

            handler(w, req)

            assert.Equal(t, tt.expectedStatus, w.Code)
            assert.Equal(t, "application/json", w.Header().Get("Content-Type"))

            var response map[string]string
            err := json.Unmarshal(w.Body.Bytes(), &response)
            assert.NoError(t, err)
            assert.Equal(t, tt.expectedBody, response)

            assert.NoError(t, mock.ExpectationsWereMet())
        })
    }
}
```

### Root Handler

```go
func TestRootHandler(t *testing.T) {
    logger := setupTestLogger()
    handler := rootHandler(logger)

    req := httptest.NewRequest("GET", "/", nil)
    w := httptest.NewRecorder()

    handler(w, req)

    assert.Equal(t, http.StatusOK, w.Code)
    assert.Equal(t, "application/json", w.Header().Get("Content-Type"))

    var response map[string]string
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)

    expected := map[string]string{
        "message": "Welcome to Go Tutorial PostgreSQL API",
        "version": "1.0.0",
        "status":  "running",
    }
    assert.Equal(t, expected, response)
}
```

### Users Handler with Method Testing

```go
func TestUsersHandler(t *testing.T) {
    db, mock := setupMockDB(t)
    defer db.Close()

    logger := setupTestLogger()
    handler := usersHandler(db, logger)

    tests := []struct {
        name           string
        method         string
        expectedStatus int
    }{
        {
            name:           "GET method allowed",
            method:         "GET",
            expectedStatus: http.StatusOK,
        },
        {
            name:           "POST method not allowed",
            method:         "POST",
            expectedStatus: http.StatusMethodNotAllowed,
        },
        {
            name:           "PUT method not allowed",
            method:         "PUT",
            expectedStatus: http.StatusMethodNotAllowed,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if tt.method == "GET" {
                // Setup mock for successful GET
                rows := sqlmock.NewRows([]string{"id", "name", "email", "created_at"})
                mock.ExpectQuery("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC").
                    WillReturnRows(rows)
            }

            req := httptest.NewRequest(tt.method, "/users", nil)
            w := httptest.NewRecorder()

            handler(w, req)

            assert.Equal(t, tt.expectedStatus, w.Code)

            if tt.method != "GET" {
                var response map[string]string
                err := json.Unmarshal(w.Body.Bytes(), &response)
                assert.NoError(t, err)
                assert.Equal(t, "Method not allowed", response["error"])
            }
        })
    }
}
```

## Integration Testing

### End-to-End Server Test

```go
func TestServerIntegration(t *testing.T) {
    // This test requires a test database
    if testing.Short() {
        t.Skip("Skipping integration test in short mode")
    }

    // Setup test database connection
    // In a real scenario, you'd use a test database
    db, mock := setupMockDB(t)
    defer db.Close()

    logger := setupTestLogger()

    // Setup routes
    mux := http.NewServeMux()
    mux.HandleFunc("/health", healthHandler(db, logger))
    mux.HandleFunc("/users", usersHandler(db, logger))
    mux.HandleFunc("/", rootHandler(logger))

    server := httptest.NewServer(mux)
    defer server.Close()

    tests := []struct {
        name           string
        endpoint       string
        mockSetup      func(sqlmock.Sqlmock)
        expectedStatus int
    }{
        {
            name:     "root endpoint",
            endpoint: "/",
            mockSetup: func(mock sqlmock.Sqlmock) {
                // No database interaction expected
            },
            expectedStatus: http.StatusOK,
        },
        {
            name:     "health check",
            endpoint: "/health",
            mockSetup: func(mock sqlmock.Sqlmock) {
                mock.ExpectPing()
            },
            expectedStatus: http.StatusOK,
        },
        {
            name:     "users endpoint",
            endpoint: "/users",
            mockSetup: func(mock sqlmock.Sqlmock) {
                rows := sqlmock.NewRows([]string{"id", "name", "email", "created_at"})
                mock.ExpectQuery("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC").
                    WillReturnRows(rows)
            },
            expectedStatus: http.StatusOK,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            tt.mockSetup(mock)

            resp, err := http.Get(server.URL + tt.endpoint)
            assert.NoError(t, err)
            defer resp.Body.Close()

            assert.Equal(t, tt.expectedStatus, resp.StatusCode)
            assert.Equal(t, "application/json", resp.Header.Get("Content-Type"))

            assert.NoError(t, mock.ExpectationsWereMet())
        })
    }
}
```

## Best Practices

### 1. Test Organization

- **Group related tests**: Use subtests with `t.Run()`
- **Clear naming**: Use descriptive test names
- **Setup/teardown**: Use helper functions for common setup

### 2. Mock Management with go-sqlmock

- **Explicit expectations**: Always define what SQL operations you expect
- **Verify expectations**: Use `mock.ExpectationsWereMet()` after each test
- **Reset between tests**: Create new mock for each test to avoid interference

### 3. Error Testing

```go
func TestDatabaseErrorHandling(t *testing.T) {
    db, mock := setupMockDB(t)
    defer db.Close()

    // Test different types of database errors
    errors := []struct {
        name string
        err  error
    }{
        {"connection lost", sql.ErrConnDone},
        {"transaction rolled back", sql.ErrTxDone},
        {"no rows", sql.ErrNoRows},
    }

    for _, e := range errors {
        t.Run(e.name, func(t *testing.T) {
            mock.ExpectQuery("SELECT").WillReturnError(e.err)

            // Test your function here
            // Verify it handles the error appropriately
        })
    }
}
```

### 4. Environment Variable Testing

```go
func TestEnvironmentVariables(t *testing.T) {
    originalEnv := os.Getenv("DB_HOST")
    defer os.Setenv("DB_HOST", originalEnv) // Restore original value

    os.Setenv("DB_HOST", "test-host")

    // Test with modified environment
    result := getEnv("DB_HOST", "default")
    assert.Equal(t, "test-host", result)
}
```

### 5. Test Data Management

```go
// testdata/users.json
{
  "users": [
    {
      "id": 1,
      "name": "Test User",
      "email": "test@example.com",
      "created_at": "2023-01-01T10:00:00Z"
    }
  ]
}

// In your test
func loadTestData(t *testing.T, filename string) []User {
    data, err := os.ReadFile(filepath.Join("testdata", filename))
    require.NoError(t, err)

    var result struct {
        Users []User `json:"users"`
    }

    err = json.Unmarshal(data, &result)
    require.NoError(t, err)

    return result.Users
}
```

## Running Tests

### Basic Test Commands

```bash
# Run all tests
make test

# Run tests with verbose output
go test -v ./...

# Run tests with coverage
go test -cover ./...

# Run tests with detailed coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run only unit tests (skip integration tests)
go test -short ./...

# Run specific test
go test -run TestHealthHandler

# Run tests with race detection
go test -race ./...
```

### Makefile Integration

Add these targets to your `Makefile`:

```makefile
# Run tests with coverage
test-coverage:
	$(GOTEST) -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

# Run tests with race detection
test-race:
	$(GOTEST) -race ./...

# Run integration tests
test-integration:
	$(GOTEST) -tags=integration ./...

# Run unit tests only
test-unit:
	$(GOTEST) -short ./...
```

### Continuous Integration

Example GitHub Actions workflow:

```yaml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: tutorial_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3

    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: 1.21

    - name: Install dependencies
      run: go mod download

    - name: Run unit tests
      run: go test -short -race -coverprofile=coverage.out ./...

    - name: Run integration tests
      run: go test -tags=integration ./...
      env:
        DB_HOST: localhost
        DB_USER: postgres
        DB_PASSWORD: password
        DB_NAME: tutorial_db

    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

## Conclusion

This testing guide provides a comprehensive approach to testing the Go tutorial server:

- **Use go-sqlmock** for database operation testing without real database dependencies
- **Test all HTTP handlers** with proper mocking and error cases
- **Include integration tests** for complete workflow validation
- **Follow Go testing best practices** for maintainable and reliable tests
- **Automate testing** with make targets and CI/CD pipelines

Remember to:
- Write tests as you develop new features
- Maintain high test coverage (aim for >80%)
- Test both success and failure scenarios
- Keep tests fast and independent
- Use mocks appropriately to isolate units under test

For more information about testing in Go, refer to:
- [Go Testing Package Documentation](https://pkg.go.dev/testing)
- [go-sqlmock Documentation](https://github.com/DATA-DOG/go-sqlmock)
- [Testify Documentation](https://github.com/stretchr/testify)