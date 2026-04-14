package models

import "time"

type Role string
const (
    RoleUser     Role = "user"
    RoleHelpdesk Role = "helpdesk"
    RoleAdmin    Role = "admin"
)

type User struct {
    ID        string    `json:"id" gorm:"primaryKey;type:char(36)"`
    Name      string    `json:"name" gorm:"not null"`
    Email     string    `json:"email" gorm:"unique;not null"`
    Password  string    `json:"-" gorm:"not null"`
    Role      Role      `json:"role" gorm:"default:user"`
    AvatarURL string    `json:"avatar_url"`
    IsActive  bool      `json:"is_active" gorm:"default:true"`
    FCMToken  string    `json:"fcm_token,omitempty"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}