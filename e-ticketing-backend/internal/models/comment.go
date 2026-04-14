package models

import (
	"time"
)

type Comment struct {
	ID        string    `json:"id" gorm:"type:char(36);primaryKey"`
	TicketID  string    `json:"ticket_id" gorm:"type:char(36);not null"`
	UserID    string    `json:"user_id" gorm:"type:char(36);not null"`
	Content   string    `json:"content" gorm:"type:text;not null"`
	CreatedAt time.Time `json:"created_at"`

	// Relations
	User   User   `json:"user" gorm:"foreignKey:UserID"`
	Ticket Ticket `json:"ticket" gorm:"foreignKey:TicketID"`
}

type CreateCommentRequest struct {
	Content string `json:"content" binding:"required"`
}

type CommentResponse struct {
	ID        string    `json:"id"`
	TicketID  string    `json:"ticket_id"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	User      User      `json:"user"`
}
