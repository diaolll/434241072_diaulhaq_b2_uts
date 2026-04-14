package router

import (
    "e-ticketing-backend/internal/handlers"
    "e-ticketing-backend/internal/middleware"
    "e-ticketing-backend/internal/repository"
    "e-ticketing-backend/internal/usecase"
    "e-ticketing-backend/pkg/supabase"
    "github.com/gin-gonic/gin"
)

func Setup() *gin.Engine {
    r := gin.Default()

    // CORS
    r.Use(func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Headers", "Authorization, Content-Type")
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        c.Next()
    })

    // Dependencies
    userRepo := repository.NewUserRepository()
    ticketRepo := repository.NewTicketRepository()
    storage := supabase.NewStorageClient()

    authUC := usecase.NewAuthUsecase(userRepo)
    ticketUC := usecase.NewTicketUsecase(ticketRepo, userRepo)

    authH := handlers.NewAuthHandler(authUC)
    ticketH := handlers.NewTicketHandler(ticketUC, storage)

    api := r.Group("/api/v1")
    {
        // Auth routes (public)
        auth := api.Group("/auth")
        {
            auth.POST("/register", authH.Register)
            auth.POST("/login", authH.Login)
            auth.POST("/reset-password", authH.ResetPassword)
        }

        // Protected routes
        protected := api.Group("/")
        protected.Use(middleware.AuthMiddleware())
        {
            // Tickets
            protected.POST("/tickets", ticketH.CreateTicket)
            protected.GET("/tickets", ticketH.GetTickets)
            protected.GET("/tickets/:id", ticketH.GetTicketByID)
            protected.POST("/tickets/:id/comments", ticketH.AddComment)
            protected.POST("/tickets/:id/attachments", ticketH.UploadAttachment)

            // Dashboard stats
            protected.GET("/dashboard/stats", ticketH.GetStats)

            // Notifications
            protected.GET("/notifications", ticketH.GetNotifications)
            protected.PUT("/notifications/:id/read", ticketH.MarkNotifRead)

            // Admin & Helpdesk only
            adminRoutes := protected.Group("/")
            adminRoutes.Use(middleware.RequireRole("admin", "helpdesk"))
            {
                adminRoutes.PUT("/tickets/:id/status", ticketH.UpdateStatus)
                adminRoutes.PUT("/tickets/:id/assign", ticketH.AssignTicket)
            }
        }
    }

    return r
}