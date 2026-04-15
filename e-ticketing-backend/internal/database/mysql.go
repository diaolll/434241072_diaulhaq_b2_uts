package database

import (
    "fmt"
    "log"
    "e-ticketing-backend/internal/config"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

var DB *gorm.DB

func Connect() {
    cfg := config.AppConfig

    // Supabase PostgreSQL connection string
    dsn := fmt.Sprintf(
        "host=%s port=%s user=%s password=%s dbname=%s sslmode=require",
        cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBPassword, cfg.DBName,
    )

    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
    })
    if err != nil {
        log.Fatalf("Failed to connect to Supabase: %v", err)
    }

    log.Println("✅ Supabase connected successfully")
    DB = db
}