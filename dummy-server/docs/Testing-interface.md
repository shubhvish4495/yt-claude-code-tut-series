# Testing Interface Guide for Go Tutorial Server

**IMPORTANT: DO NOT USE ANY EXTERNAL PACKAGES FOR TESTING**

This document provides comprehensive guidelines for testing the Go tutorial server using Go's standard library only. We emphasize database interface mocking using Go's built-in capabilities without any third-party dependencies.

## Table of Contents

- [Overview](#overview)
- [Testing Philosophy](#testing-philosophy)
- [Database Interface Mocking](#database-interface-mocking)
- [Test Structure](#test-structure)
- [Handler Testing](#handler-testing)
- [Database Testing](#database-testing)
- [Best Practices](#best-practices)
- [Examples](#examples)

## Overview

This testing approach uses **only Go standard library** packages:
- `testing` - Core testing framework
- `net/http/httptest` - HTTP testing utilities
- `database/sql/driver` - Database driver interfaces for mocking

**NO EXTERNAL PACKAGES** such as:
- ❌ `github.com/DATA-DOG/go-sqlmock`
- ❌ `github.com/stretchr/testify`
- ❌ Any other third-party testing libraries

## Testing Philosophy

### Core Principles

1. **Zero External Dependencies**: Use only Go standard library
2. **Interface-Based Mocking**: Create interfaces for testability
3. **Dependency Injection**: Inject dependencies to enable mocking
4. **Clear Test Structure**: Organized, readable test cases
5. **Standard Go Conventions**: Follow Go testing best practices

### Test Organization

```
dummy-server/
├── main.go
├── interfaces.go          # Database and service interfaces
├── main_test.go          # Integration tests
├── handlers_test.go      # HTTP handler tests
├── database_test.go      # Database operation tests
└── mocks_test.go        # Mock implementations
```

## Database Interface Mocking

### Step 1: Define Database Interface

Create interfaces for all database operations:

```go
// interfaces.go
package main

import (
    "database/sql"
)

// DatabaseInterface defines database operations
type DatabaseInterface interface {
    Query(query string, args ...interface{}) (RowsInterface, error)
    QueryRow(query string, args ...interface{}) RowInterface
    Exec(query string, args ...interface{}) (sql.Result, error)
    Ping() error
    Close() error
}

// RowsInterface defines result set operations
type RowsInterface interface {
    Next() bool
    Scan(dest ...interface{}) error
    Close() error
    Err() error
}

// RowInterface defines single row operations
type RowInterface interface {
    Scan(dest ...interface{}) error
}

// DatabaseWrapper wraps sql.DB to implement DatabaseInterface
type DatabaseWrapper struct {
    DB *sql.DB
}

func (dw *DatabaseWrapper) Query(query string, args ...interface{}) (RowsInterface, error) {
    rows, err := dw.DB.Query(query, args...)
    if err != nil {
        return nil, err
    }
    return &RowsWrapper{Rows: rows}, nil
}

func (dw *DatabaseWrapper) QueryRow(query string, args ...interface{}) RowInterface {
    row := dw.DB.QueryRow(query, args...)
    return &RowWrapper{Row: row}
}

func (dw *DatabaseWrapper) Exec(query string, args ...interface{}) (sql.Result, error) {
    return dw.DB.Exec(query, args...)
}

func (dw *DatabaseWrapper) Ping() error {
    return dw.DB.Ping()
}

func (dw *DatabaseWrapper) Close() error {
    return dw.DB.Close()
}

// RowsWrapper wraps sql.Rows to implement RowsInterface
type RowsWrapper struct {
    Rows *sql.Rows
}

func (rw *RowsWrapper) Next() bool {
    return rw.Rows.Next()
}

func (rw *RowsWrapper) Scan(dest ...interface{}) error {
    return rw.Rows.Scan(dest...)
}

func (rw *RowsWrapper) Close() error {
    return rw.Rows.Close()
}

func (rw *RowsWrapper) Err() error {
    return rw.Rows.Err()
}

// RowWrapper wraps sql.Row to implement RowInterface
type RowWrapper struct {
    Row *sql.Row
}

func (rw *RowWrapper) Scan(dest ...interface{}) error {
    return rw.Row.Scan(dest...)
}
```

### Step 2: Update Handlers to Use Interface

Modify handlers to accept the interface instead of concrete types:

```go
// Updated handler signature
func getUsersHandler(db DatabaseInterface, logger *slog.Logger, w http.ResponseWriter, r *http.Request) {
    logger.Info("Fetching users from database")

    rows, err := db.Query("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC")
    if err != nil {
        logger.Error("Failed to query users", "error", err)
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusInternalServerError)
        json.NewEncoder(w).Encode(map[string]string{
            "error": "Failed to retrieve users",
        })
        return
    }
    defer rows.Close()

    // Rest of the handler implementation remains the same...
}
```

### Step 3: Create Mock Implementations

```go
// mocks_test.go
package main

import (
    "database/sql"
    "errors"
)

// MockDatabase implements DatabaseInterface for testing
type MockDatabase struct {
    QueryFunc    func(query string, args ...interface{}) (RowsInterface, error)
    QueryRowFunc func(query string, args ...interface{}) RowInterface
    ExecFunc     func(query string, args ...interface{}) (sql.Result, error)
    PingFunc     func() error
    CloseFunc    func() error
}

func (m *MockDatabase) Query(query string, args ...interface{}) (RowsInterface, error) {
    if m.QueryFunc != nil {
        return m.QueryFunc(query, args...)
    }
    return nil, errors.New("not implemented")
}

func (m *MockDatabase) QueryRow(query string, args ...interface{}) RowInterface {
    if m.QueryRowFunc != nil {
        return m.QueryRowFunc(query, args...)
    }
    return &MockRow{ScanFunc: func(dest ...interface{}) error { return sql.ErrNoRows }}
}

func (m *MockDatabase) Exec(query string, args ...interface{}) (sql.Result, error) {
    if m.ExecFunc != nil {
        return m.ExecFunc(query, args...)
    }
    return nil, errors.New("not implemented")
}

func (m *MockDatabase) Ping() error {
    if m.PingFunc != nil {
        return m.PingFunc()
    }
    return nil
}

func (m *MockDatabase) Close() error {
    if m.CloseFunc != nil {
        return m.CloseFunc()
    }
    return nil
}

// MockRows implements RowsInterface for testing
type MockRows struct {
    Rows    [][]interface{}
    Current int
    ScanErr error
    NextErr error
}

func (mr *MockRows) Next() bool {
    mr.Current++
    return mr.Current <= len(mr.Rows)
}

func (mr *MockRows) Scan(dest ...interface{}) error {
    if mr.ScanErr != nil {
        return mr.ScanErr
    }

    if mr.Current > len(mr.Rows) || mr.Current <= 0 {
        return errors.New("no rows")
    }

    row := mr.Rows[mr.Current-1]
    for i, v := range row {
        if i < len(dest) {
            switch d := dest[i].(type) {
            case *int:
                if val, ok := v.(int); ok {
                    *d = val
                }
            case *string:
                if val, ok := v.(string); ok {
                    *d = val
                }
            }
        }
    }
    return nil
}

func (mr *MockRows) Close() error {
    return nil
}

func (mr *MockRows) Err() error {
    return mr.NextErr
}

// MockRow implements RowInterface for testing
type MockRow struct {
    ScanFunc func(dest ...interface{}) error
}

func (mr *MockRow) Scan(dest ...interface{}) error {
    if mr.ScanFunc != nil {
        return mr.ScanFunc(dest...)
    }
    return sql.ErrNoRows
}

// MockResult implements sql.Result for testing
type MockResult struct {
    LastInsertIdFunc func() (int64, error)
    RowsAffectedFunc func() (int64, error)
}

func (mr *MockResult) LastInsertId() (int64, error) {
    if mr.LastInsertIdFunc != nil {
        return mr.LastInsertIdFunc()
    }
    return 0, nil
}

func (mr *MockResult) RowsAffected() (int64, error) {
    if mr.RowsAffectedFunc != nil {
        return mr.RowsAffectedFunc()
    }
    return 0, nil
}
```

## Test Structure

### Basic Test Setup

```go
// handlers_test.go
package main

import (
    "encoding/json"
    "log/slog"
    "net/http"
    "net/http/httptest"
    "os"
    "testing"
)

// setupTestLogger creates a logger for testing
func setupTestLogger() *slog.Logger {
    return slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelError, // Reduce noise during tests
    }))
}

// assertEqual is a simple assertion helper
func assertEqual(t *testing.T, expected, actual interface{}, message string) {
    t.Helper()
    if expected != actual {
        t.Errorf("%s: expected %v, got %v", message, expected, actual)
    }
}

// assertNoError is a simple error assertion helper
func assertNoError(t *testing.T, err error, message string) {
    t.Helper()
    if err != nil {
        t.Errorf("%s: unexpected error: %v", message, err)
    }
}
```

## Handler Testing

### Testing getUsersHandler

```go
func TestGetUsersHandler(t *testing.T) {
    tests := []struct {
        name           string
        setupMock      func() *MockDatabase
        expectedStatus int
        expectedUsers  int
        expectError    bool
    }{
        {
            name: "successful query with users",
            setupMock: func() *MockDatabase {
                return &MockDatabase{
                    QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
                        return &MockRows{
                            Rows: [][]interface{}{
                                {1, "John Doe", "john@example.com", "2023-01-01 10:00:00"},
                                {2, "Jane Smith", "jane@example.com", "2023-01-02 11:00:00"},
                            },
                        }, nil
                    },
                }
            },
            expectedStatus: http.StatusOK,
            expectedUsers:  2,
            expectError:    false,
        },
        {
            name: "empty result set",
            setupMock: func() *MockDatabase {
                return &MockDatabase{
                    QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
                        return &MockRows{Rows: [][]interface{}{}}, nil
                    },
                }
            },
            expectedStatus: http.StatusOK,
            expectedUsers:  0,
            expectError:    false,
        },
        {
            name: "database error",
            setupMock: func() *MockDatabase {
                return &MockDatabase{
                    QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
                        return nil, errors.New("database connection failed")
                    },
                }
            },
            expectedStatus: http.StatusInternalServerError,
            expectedUsers:  0,
            expectError:    true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Setup
            mockDB := tt.setupMock()
            logger := setupTestLogger()

            req := httptest.NewRequest("GET", "/users", nil)
            w := httptest.NewRecorder()

            // Execute
            getUsersHandler(mockDB, logger, w, req)

            // Assert
            assertEqual(t, tt.expectedStatus, w.Code, "HTTP status code")
            assertEqual(t, "application/json", w.Header().Get("Content-Type"), "Content-Type header")

            if !tt.expectError {
                var response map[string]interface{}
                err := json.Unmarshal(w.Body.Bytes(), &response)
                assertNoError(t, err, "JSON unmarshal")

                users, ok := response["users"].([]interface{})
                if !ok {
                    t.Errorf("users field should be an array")
                    return
                }

                assertEqual(t, tt.expectedUsers, len(users), "number of users")

                count, ok := response["count"].(float64)
                if !ok {
                    t.Errorf("count field should be a number")
                    return
                }

                assertEqual(t, float64(tt.expectedUsers), count, "user count")
            } else {
                var response map[string]interface{}
                err := json.Unmarshal(w.Body.Bytes(), &response)
                assertNoError(t, err, "JSON unmarshal")

                if _, exists := response["error"]; !exists {
                    t.Errorf("error response should contain error field")
                }
            }
        })
    }
}
```

### Testing Health Handler

```go
func TestHealthHandler(t *testing.T) {
    tests := []struct {
        name           string
        setupMock      func() *MockDatabase
        expectedStatus int
        expectError    bool
    }{
        {
            name: "healthy database",
            setupMock: func() *MockDatabase {
                return &MockDatabase{
                    PingFunc: func() error {
                        return nil
                    },
                }
            },
            expectedStatus: http.StatusOK,
            expectError:    false,
        },
        {
            name: "unhealthy database",
            setupMock: func() *MockDatabase {
                return &MockDatabase{
                    PingFunc: func() error {
                        return errors.New("connection failed")
                    },
                }
            },
            expectedStatus: http.StatusServiceUnavailable,
            expectError:    true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Setup
            mockDB := tt.setupMock()
            logger := setupTestLogger()

            req := httptest.NewRequest("GET", "/health", nil)
            w := httptest.NewRecorder()

            // Execute
            healthHandler(mockDB, logger)(w, req)

            // Assert
            assertEqual(t, tt.expectedStatus, w.Code, "HTTP status code")

            var response map[string]interface{}
            err := json.Unmarshal(w.Body.Bytes(), &response)
            assertNoError(t, err, "JSON unmarshal")

            if tt.expectError {
                assertEqual(t, "unhealthy", response["status"], "status should be unhealthy")
                if _, exists := response["error"]; !exists {
                    t.Errorf("error response should contain error field")
                }
            } else {
                assertEqual(t, "healthy", response["status"], "status should be healthy")
                assertEqual(t, "connected", response["database"], "database should be connected")
            }
        })
    }
}
```

## Database Testing

### Testing Database Operations

```go
func TestDatabaseOperations(t *testing.T) {
    t.Run("query execution", func(t *testing.T) {
        mockDB := &MockDatabase{
            QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
                expectedQuery := "SELECT id, name, email, created_at FROM users ORDER BY created_at DESC"
                if query != expectedQuery {
                    t.Errorf("unexpected query: expected %s, got %s", expectedQuery, query)
                }
                return &MockRows{
                    Rows: [][]interface{}{
                        {1, "Test User", "test@example.com", "2023-01-01 10:00:00"},
                    },
                }, nil
            },
        }

        rows, err := mockDB.Query("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC")
        assertNoError(t, err, "database query")

        if !rows.Next() {
            t.Error("expected at least one row")
        }

        var id int
        var name, email, createdAt string
        err = rows.Scan(&id, &name, &email, &createdAt)
        assertNoError(t, err, "row scan")

        assertEqual(t, 1, id, "user ID")
        assertEqual(t, "Test User", name, "user name")
        assertEqual(t, "test@example.com", email, "user email")
    })
}
```

## Best Practices

### 1. Test Organization

- **Group related tests**: Use subtests with `t.Run()`
- **Descriptive names**: Use clear, descriptive test names
- **Setup helpers**: Create reusable setup functions
- **Clean isolation**: Each test should be independent

### 2. Mock Management

- **Single responsibility**: Each mock should test one specific behavior
- **Clear expectations**: Make mock behavior explicit and predictable
- **Error testing**: Test both success and failure scenarios
- **Edge cases**: Include boundary conditions and edge cases

### 3. Assertion Patterns

```go
// Use helper functions for common assertions
func assertEqual(t *testing.T, expected, actual interface{}, message string) {
    t.Helper()
    if expected != actual {
        t.Errorf("%s: expected %v, got %v", message, expected, actual)
    }
}

func assertContains(t *testing.T, haystack, needle string, message string) {
    t.Helper()
    if !strings.Contains(haystack, needle) {
        t.Errorf("%s: expected %s to contain %s", message, haystack, needle)
    }
}

func assertJSONField(t *testing.T, jsonData []byte, field string, expected interface{}) {
    t.Helper()
    var data map[string]interface{}
    err := json.Unmarshal(jsonData, &data)
    assertNoError(t, err, "JSON unmarshal")

    actual, exists := data[field]
    if !exists {
        t.Errorf("JSON field %s does not exist", field)
        return
    }

    assertEqual(t, expected, actual, fmt.Sprintf("JSON field %s", field))
}
```

### 4. Test Data Management

```go
// Create helper functions for test data
func createTestUser(id int, name, email string) []interface{} {
    return []interface{}{id, name, email, "2023-01-01 10:00:00"}
}

func createMockUsersRows(users ...[]interface{}) *MockRows {
    return &MockRows{Rows: users}
}

// Usage in tests
func TestMultipleUsers(t *testing.T) {
    users := [][]interface{}{
        createTestUser(1, "John Doe", "john@example.com"),
        createTestUser(2, "Jane Smith", "jane@example.com"),
    }

    mockDB := &MockDatabase{
        QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
            return createMockUsersRows(users...), nil
        },
    }

    // Test implementation...
}
```

### 5. Error Handling Tests

```go
func TestErrorHandling(t *testing.T) {
    errorTypes := []struct {
        name string
        err  error
    }{
        {"connection error", errors.New("connection failed")},
        {"timeout error", errors.New("query timeout")},
        {"permission error", errors.New("access denied")},
    }

    for _, et := range errorTypes {
        t.Run(et.name, func(t *testing.T) {
            mockDB := &MockDatabase{
                QueryFunc: func(query string, args ...interface{}) (RowsInterface, error) {
                    return nil, et.err
                },
            }

            // Test error handling...
        })
    }
}
```

## Running Tests

### Standard Go Testing Commands

```bash
# Run all tests
go test ./...

# Run tests with verbose output
go test -v ./...

# Run tests with coverage
go test -cover ./...

# Run specific test
go test -run TestGetUsersHandler

# Run tests with race detection
go test -race ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run benchmarks
go test -bench=. ./...
```

### Makefile Integration

```makefile
.PHONY: test test-coverage test-race test-verbose

test:
	go test ./...

test-coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

test-race:
	go test -race ./...

test-verbose:
	go test -v ./...
```

## Conclusion

This testing approach provides:

- **Zero external dependencies**: Uses only Go standard library
- **Complete test coverage**: Covers all handler and database operations
- **Interface-based mocking**: Clean separation of concerns
- **Maintainable tests**: Clear structure and reusable components
- **Go best practices**: Follows standard Go testing conventions

### Key Benefits

1. **No external dependencies** - Reduces complexity and security concerns
2. **Standard library only** - Portable and consistent across environments
3. **Interface-driven design** - Improves code testability and maintainability
4. **Comprehensive coverage** - Tests all critical paths and edge cases
5. **Clear patterns** - Established patterns for consistent testing

### Remember

- Always test both success and failure scenarios
- Use descriptive test names and clear assertions
- Keep tests independent and isolated
- Test edge cases and boundary conditions
- Maintain high test coverage (aim for >80%)
- Write tests as you develop new features

For more information about testing in Go, refer to:
- [Go Testing Package Documentation](https://pkg.go.dev/testing)
- [Go Blog: Using Subtests and Sub-benchmarks](https://go.dev/blog/subtests)
- [Effective Go: Testing](https://golang.org/doc/effective_go#testing)