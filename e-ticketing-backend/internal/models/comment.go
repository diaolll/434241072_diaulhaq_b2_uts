package models

import (
	"time"
)

// CreateCommentRequest DTO for creating comments
type CreateCommentRequest struct {
	Content string `json:"content" binding:"required"`
}

// CommentResponse DTO for API responses (includes user data)
type CommentResponse struct {
	ID        string    `json:"id"`
	TicketID  string    `json:"ticket_id"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	User      User      `json:"user"`
}

// Note: The Comment struct is already defined in ticket.go
// This file only contains DTOs for API requests/responses
