package config

import (
    "log"
    "os"
    "github.com/joho/godotenv"
)

type Config struct {
    AppPort        string
    JWTSecret      string
    DBHost         string
    DBPort         string
    DBUser         string
    DBPassword     string
    DBName         string
    SupabaseURL    string
    SupabaseKey    string
    SupabaseBucket string
    FirebaseCreds  string
}

var AppConfig *Config

func Load() {
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found, reading from environment")
    }

    AppConfig = &Config{
        AppPort:        getEnv("APP_PORT", "8080"),
        JWTSecret:      getEnv("JWT_SECRET", "secret"),
        DBHost:         getEnv("DB_HOST", "localhost"),
        DBPort:         getEnv("DB_PORT", "3306"),
        DBUser:         getEnv("DB_USER", "root"),
        DBPassword:     getEnv("DB_PASSWORD", ""),
        DBName:         getEnv("DB_NAME", "e_ticketing"),
        SupabaseURL:    getEnv("SUPABASE_URL", ""),
        SupabaseKey:    getEnv("SUPABASE_KEY", ""),
        SupabaseBucket: getEnv("SUPABASE_BUCKET", "ticket-attachments"),
        FirebaseCreds:  getEnv("FIREBASE_CREDENTIALS_FILE", ""),
    }
}

func getEnv(key, fallback string) string {
    if val := os.Getenv(key); val != "" {
        return val
    }
    return fallback
}