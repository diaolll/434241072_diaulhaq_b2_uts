package main

import (
    "log"
    "e-ticketing-backend/internal/config"
    "e-ticketing-backend/internal/database"
    "e-ticketing-backend/internal/router"
)

func main() {
    config.Load()
    database.Connect()

    r := router.Setup()

    log.Printf("🚀 Server running on port %s", config.AppConfig.AppPort)
    r.Run(":" + config.AppConfig.AppPort)
}