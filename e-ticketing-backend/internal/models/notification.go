package models

import (
	"time"
)

// NotificationRequest DTO for creating notifications
type NotificationRequest struct {
	UserID  string  `json:"user_id" binding:"required"`
	TicketID *string `json:"ticket_id,omitempty"`
	Title   string  `json:"title" binding:"required"`
	Body    string  `json:"body" binding:"required"`
}

// NotificationResponse DTO for API responses
type NotificationResponse struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	TicketID  *string   `json:"ticket_id,omitempty"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
}

// Note: The core Notification struct is already defined in ticket.go
// This file only contains DTOs for API requests/responses
