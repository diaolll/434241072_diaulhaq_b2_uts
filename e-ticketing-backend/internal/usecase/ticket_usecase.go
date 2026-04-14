package usecase

import (
    "fmt"
    "time"
    "e-ticketing-backend/internal/models"
    "e-ticketing-backend/internal/repository"
    "github.com/google/uuid"
)

type TicketUsecase interface {
    CreateTicket(userID, title, desc, category, priority string) (*models.Ticket, error)
    GetTickets(userID, role string, page, limit int) ([]models.Ticket, int64, error)
    GetTicketByID(id string) (*models.Ticket, error)
    UpdateStatus(ticketID, changedBy, newStatus, note string) error
    AssignTicket(ticketID, assignTo string) error
    AddComment(ticketID, userID, content string) error
    AddAttachment(ticketID, fileURL, fileName, fileType string) error
    GetStats(userID, role string) (map[string]int64, error)
    GetNotifications(userID string) ([]models.Notification, error)
    MarkNotifRead(notifID string) error
}

type ticketUsecase struct {
    ticketRepo repository.TicketRepository
    userRepo   repository.UserRepository
}

func NewTicketUsecase(tr repository.TicketRepository, ur repository.UserRepository) TicketUsecase {
    return &ticketUsecase{ticketRepo: tr, userRepo: ur}
}

func generateTicketNo() string {
    now := time.Now()
    return fmt.Sprintf("TKT-%d%02d%02d-%s", now.Year(), now.Month(), now.Day(), uuid.New().String()[:6])
}

func (u *ticketUsecase) CreateTicket(userID, title, desc, category, priority string) (*models.Ticket, error) {
    ticket := &models.Ticket{
        ID:          uuid.New().String(),
        TicketNo:    generateTicketNo(),
        Title:       title,
        Description: desc,
        Category:    category,
        Priority:    models.Priority(priority),
        Status:      models.StatusOpen,
        UserID:      userID,
    }
    if err := u.ticketRepo.Create(ticket); err != nil {
        return nil, err
    }

    // Tambah history
    u.ticketRepo.AddHistory(&models.TicketHistory{
        ID:        uuid.New().String(),
        TicketID:  ticket.ID,
        ChangedBy: userID,
        OldStatus: "",
        NewStatus: string(models.StatusOpen),
        Note:      "Tiket dibuat",
    })

    return ticket, nil
}

func (u *ticketUsecase) GetTickets(userID, role string, page, limit int) ([]models.Ticket, int64, error) {
    return u.ticketRepo.FindAll(userID, role, page, limit)
}

func (u *ticketUsecase) GetTicketByID(id string) (*models.Ticket, error) {
    return u.ticketRepo.FindByID(id)
}

func (u *ticketUsecase) UpdateStatus(ticketID, changedBy, newStatus, note string) error {
    ticket, err := u.ticketRepo.FindByID(ticketID)
    if err != nil {
        return err
    }

    oldStatus := string(ticket.Status)
    ticket.Status = models.TicketStatus(newStatus)

    if err := u.ticketRepo.Update(ticket); err != nil {
        return err
    }

    // Tambah history
    u.ticketRepo.AddHistory(&models.TicketHistory{
        ID:        uuid.New().String(),
        TicketID:  ticketID,
        ChangedBy: changedBy,
        OldStatus: oldStatus,
        NewStatus: newStatus,
        Note:      note,
    })

    // Kirim notifikasi ke user pembuat tiket
    u.ticketRepo.AddNotification(&models.Notification{
        ID:       uuid.New().String(),
        UserID:   ticket.UserID,
        TicketID: ticketID,
        Title:    "Status Tiket Diperbarui",
        Body:     fmt.Sprintf("Tiket %s status berubah dari %s ke %s", ticket.TicketNo, oldStatus, newStatus),
    })

    return nil
}

func (u *ticketUsecase) AssignTicket(ticketID, assignTo string) error {
    ticket, err := u.ticketRepo.FindByID(ticketID)
    if err != nil {
        return err
    }
    ticket.AssignedTo = &assignTo
    return u.ticketRepo.Update(ticket)
}

func (u *ticketUsecase) AddComment(ticketID, userID, content string) error {
    comment := &models.Comment{
        ID:       uuid.New().String(),
        TicketID: ticketID,
        UserID:   userID,
        Content:  content,
    }
    return u.ticketRepo.AddComment(comment)
}

func (u *ticketUsecase) AddAttachment(ticketID, fileURL, fileName, fileType string) error {
    att := &models.TicketAttachment{
        ID:       uuid.New().String(),
        TicketID: ticketID,
        FileURL:  fileURL,
        FileName: fileName,
        FileType: fileType,
    }
    return u.ticketRepo.AddAttachment(att)
}

func (u *ticketUsecase) GetStats(userID, role string) (map[string]int64, error) {
    return u.ticketRepo.GetStats(userID, role)
}

func (u *ticketUsecase) GetNotifications(userID string) ([]models.Notification, error) {
    return u.ticketRepo.GetNotifications(userID)
}

func (u *ticketUsecase) MarkNotifRead(notifID string) error {
    return u.ticketRepo.MarkNotificationRead(notifID)
}