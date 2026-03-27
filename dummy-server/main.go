package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		AddSource: true,
		Level:     slog.LevelInfo,
	}))

	// Initialize database connection
	db, err := connectToPostgreSQL(logger)
	if err != nil {
		logger.Error("Failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer db.Close()

	logger.Info("Application started successfully with database connection")

	// Set up HTTP routes
	http.HandleFunc("/health", healthHandler(db, logger))
	http.HandleFunc("/users", usersHandler(db, logger))
	http.HandleFunc("/", rootHandler(logger))

	// Start HTTP server
	port := getEnv("PORT", "8080")
	logger.Info("Starting HTTP server", "port", port)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		logger.Error("Failed to start HTTP server", "error", err)
		os.Exit(1)
	}
}

func connectToPostgreSQL(logger *slog.Logger) (*sql.DB, error) {
	// Database connection parameters
	// You can modify these or use environment variables
	dbConfig := map[string]string{
		"host":     getEnv("DB_HOST", "localhost"),
		"port":     getEnv("DB_PORT", "5432"),
		"user":     getEnv("DB_USER", "postgres"),
		"password": getEnv("DB_PASSWORD", "password"),
		"dbname":   getEnv("DB_NAME", "tutorial_db"),
		"sslmode":  getEnv("DB_SSLMODE", "disable"),
	}

	// Build connection string
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbConfig["host"],
		dbConfig["port"],
		dbConfig["user"],
		dbConfig["password"],
		dbConfig["dbname"],
		dbConfig["sslmode"],
	)

	logger.Info("Attempting to connect to PostgreSQL",
		"host", dbConfig["host"],
		"port", dbConfig["port"],
		"user", dbConfig["user"],
		"dbname", dbConfig["dbname"],
		"sslmode", dbConfig["sslmode"],
	)

	// Open database connection
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to open database connection: %w", err)
	}

	// Test the connection
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	// Configure connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)

	logger.Info("Successfully connected to PostgreSQL database")
	return db, nil
}

// getEnv gets an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// rootHandler handles requests to the root endpoint
func rootHandler(logger *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		logger.Info("Root endpoint accessed", "method", r.Method, "path", r.URL.Path)

		response := map[string]string{
			"message": "Welcome to Go Tutorial PostgreSQL API",
			"version": "1.0.0",
			"status":  "running",
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

// healthHandler handles health check requests
func healthHandler(db *sql.DB, logger *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Test database connectivity
		if err := db.Ping(); err != nil {
			logger.Error("Health check failed - database unreachable", "error", err)

			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusServiceUnavailable)
			json.NewEncoder(w).Encode(map[string]string{
				"status": "unhealthy",
				"error":  "database unreachable",
			})
			return
		}

		logger.Info("Health check passed")

		response := map[string]string{
			"status":   "healthy",
			"database": "connected",
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

// usersHandler handles requests to the users endpoint
func usersHandler(db *sql.DB, logger *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":
			getUsersHandler(db, logger, w, r)
		default:
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusMethodNotAllowed)
			json.NewEncoder(w).Encode(map[string]string{
				"error": "Method not allowed",
			})
		}
	}
}

// getUsersHandler retrieves users from the database
func getUsersHandler(db *sql.DB, logger *slog.Logger, w http.ResponseWriter, r *http.Request) {
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

	type User struct {
		ID        int    `json:"id"`
		Name      string `json:"name"`
		Email     string `json:"email"`
		CreatedAt string `json:"created_at"`
	}

	var users []User
	for rows.Next() {
		var user User
		if err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt); err != nil {
			logger.Error("Failed to scan user row", "error", err)
			continue
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		logger.Error("Error iterating through user rows", "error", err)
	}

	logger.Info("Successfully retrieved users", "count", len(users))

	response := map[string]interface{}{
		"users": users,
		"count": len(users),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
