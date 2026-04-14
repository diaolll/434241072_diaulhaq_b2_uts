package models

import "time"

type Priority string
type TicketStatus string

const (
    PriorityLow      Priority = "low"
    PriorityMedium   Priority = "medium"
    PriorityHigh     Priority = "high"
    PriorityCritical Priority = "critical"
)

const (
    StatusOpen       TicketStatus = "open"
    StatusInProgress TicketStatus = "in_progress"
    StatusResolved   TicketStatus = "resolved"
    StatusClosed     TicketStatus = "closed"
)

type Ticket struct {
    ID          string       `json:"id" gorm:"primaryKey;type:char(36)"`
    TicketNo    string       `json:"ticket_no" gorm:"unique"`
    Title       string       `json:"title"`
    Description string       `json:"description"`
    Category    string       `json:"category"`
    Priority    Priority     `json:"priority" gorm:"default:medium"`
    Status      TicketStatus `json:"status" gorm:"default:open"`
    UserID      string       `json:"user_id" gorm:"type:char(36)"`
    AssignedTo  *string      `json:"assigned_to" gorm:"type:char(36)"`
    CreatedAt   time.Time    `json:"created_at"`
    UpdatedAt   time.Time    `json:"updated_at"`

    // Relations
    User        User              `json:"user" gorm:"foreignKey:UserID"`
    Assignee    *User             `json:"assignee,omitempty" gorm:"foreignKey:AssignedTo"`
    Attachments []TicketAttachment `json:"attachments,omitempty"`
    Comments    []Comment         `json:"comments,omitempty"`
    History     []TicketHistory   `json:"history,omitempty"`
}

type TicketAttachment struct {
    ID        string    `json:"id" gorm:"primaryKey;type:char(36)"`
    TicketID  string    `json:"ticket_id"`
    FileURL   string    `json:"file_url"`
    FileName  string    `json:"file_name"`
    FileType  string    `json:"file_type"`
    CreatedAt time.Time `json:"created_at"`
}

type Comment struct {
    ID        string    `json:"id" gorm:"primaryKey;type:char(36)"`
    TicketID  string    `json:"ticket_id"`
    UserID    string    `json:"user_id"`
    Content   string    `json:"content"`
    CreatedAt time.Time `json:"created_at"`
    User      User      `json:"user" gorm:"foreignKey:UserID"`
}

type TicketHistory struct {
    ID        string    `json:"id" gorm:"primaryKey;type:char(36)"`
    TicketID  string    `json:"ticket_id"`
    ChangedBy string    `json:"changed_by"`
    OldStatus string    `json:"old_status"`
    NewStatus string    `json:"new_status"`
    Note      string    `json:"note"`
    CreatedAt time.Time `json:"created_at"`
    User      User      `json:"user" gorm:"foreignKey:ChangedBy"`
}

type Notification struct {
    ID        string    `json:"id" gorm:"primaryKey;type:char(36)"`
    UserID    string    `json:"user_id"`
    TicketID  string    `json:"ticket_id"`
    Title     string    `json:"title"`
    Body      string    `json:"body"`
    IsRead    bool      `json:"is_read" gorm:"default:false"`
    CreatedAt time.Time `json:"created_at"`
}