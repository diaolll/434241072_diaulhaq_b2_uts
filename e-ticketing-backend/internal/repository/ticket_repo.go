package repository

import (
    "e-ticketing-backend/internal/database"
    "e-ticketing-backend/internal/models"
)

type TicketRepository interface {
    Create(ticket *models.Ticket) error
    FindAll(userID, role string, page, limit int) ([]models.Ticket, int64, error)
    FindByID(id string) (*models.Ticket, error)
    Update(ticket *models.Ticket) error
    AddComment(comment *models.Comment) error
    AddAttachment(att *models.TicketAttachment) error
    AddHistory(history *models.TicketHistory) error
    GetStats(userID, role string) (map[string]int64, error)
    GetNotifications(userID string) ([]models.Notification, error)
    MarkNotificationRead(id string) error
    AddNotification(notif *models.Notification) error
}

type ticketRepo struct{}

func NewTicketRepository() TicketRepository { return &ticketRepo{} }

func (r *ticketRepo) Create(ticket *models.Ticket) error {
    return database.DB.Create(ticket).Error
}

func (r *ticketRepo) FindAll(userID, role string, page, limit int) ([]models.Ticket, int64, error) {
    var tickets []models.Ticket
    var total int64

    query := database.DB.Model(&models.Ticket{})

    // User hanya lihat tiket miliknya
    if role == "user" {
        query = query.Where("user_id = ?", userID)
    }

    query.Count(&total)

    offset := (page - 1) * limit
    err := query.
        Preload("User").
        Preload("Assignee").
        Preload("Attachments").
        Order("created_at DESC").
        Offset(offset).Limit(limit).
        Find(&tickets).Error

    return tickets, total, err
}

func (r *ticketRepo) FindByID(id string) (*models.Ticket, error) {
    var ticket models.Ticket
    err := database.DB.
        Preload("User").
        Preload("Assignee").
        Preload("Attachments").
        Preload("Comments.User").
        Preload("History.User").
        First(&ticket, "id = ?", id).Error
    return &ticket, err
}

func (r *ticketRepo) Update(ticket *models.Ticket) error {
    return database.DB.Save(ticket).Error
}

func (r *ticketRepo) AddComment(comment *models.Comment) error {
    return database.DB.Create(comment).Error
}

func (r *ticketRepo) AddAttachment(att *models.TicketAttachment) error {
    return database.DB.Create(att).Error
}

func (r *ticketRepo) AddHistory(history *models.TicketHistory) error {
    return database.DB.Create(history).Error
}

func (r *ticketRepo) GetStats(userID, role string) (map[string]int64, error) {
    stats := map[string]int64{}
    statuses := []string{"open", "in_progress", "resolved", "closed"}

    for _, s := range statuses {
        var count int64
        q := database.DB.Model(&models.Ticket{}).Where("status = ?", s)
        if role == "user" {
            q = q.Where("user_id = ?", userID)
        }
        q.Count(&count)
        stats[s] = count
    }

    var total int64
    q := database.DB.Model(&models.Ticket{})
    if role == "user" {
        q = q.Where("user_id = ?", userID)
    }
    q.Count(&total)
    stats["total"] = total

    return stats, nil
}

func (r *ticketRepo) GetNotifications(userID string) ([]models.Notification, error) {
    var notifs []models.Notification
    err := database.DB.Where("user_id = ?", userID).
        Order("created_at DESC").
        Limit(50).
        Find(&notifs).Error
    return notifs, err
}

func (r *ticketRepo) MarkNotificationRead(id string) error {
    return database.DB.Model(&models.Notification{}).
        Where("id = ?", id).
        Update("is_read", true).Error
}

func (r *ticketRepo) AddNotification(notif *models.Notification) error {
    return database.DB.Create(notif).Error
}