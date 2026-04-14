package models

import (
	"time"
)

type Notification struct {
	ID        string    `json:"id" gorm:"type:char(36);primaryKey"`
	UserID    string    `json:"user_id" gorm:"type:char(36);not null"`
	TicketID  *string   `json:"ticket_id" gorm:"type:char(36)"`
	Title     string    `json:"title" gorm:"type:varchar(200)"`
	Body      string    `json:"body" gorm:"type:text"`
	IsRead    bool      `json:"is_read" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`
}
