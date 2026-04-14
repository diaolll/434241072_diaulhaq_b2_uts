package handlers

import (
    "fmt"
    "net/http"
    "strconv"
    "e-ticketing-backend/internal/usecase"
    "e-ticketing-backend/pkg/supabase"
    "github.com/gin-gonic/gin"
)

type TicketHandler struct {
    ticketUC usecase.TicketUsecase
    storage  *supabase.StorageClient
}

func NewTicketHandler(uc usecase.TicketUsecase, storage *supabase.StorageClient) *TicketHandler {
    return &TicketHandler{ticketUC: uc, storage: storage}
}

func (h *TicketHandler) CreateTicket(c *gin.Context) {
    userID := c.GetString("user_id")
    var req struct {
        Title       string `json:"title" binding:"required"`
        Description string `json:"description" binding:"required"`
        Category    string `json:"category"`
        Priority    string `json:"priority"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if req.Priority == "" {
        req.Priority = "medium"
    }

    ticket, err := h.ticketUC.CreateTicket(userID, req.Title, req.Description, req.Category, req.Priority)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, gin.H{"data": ticket})
}

func (h *TicketHandler) GetTickets(c *gin.Context) {
    userID := c.GetString("user_id")
    role := c.GetString("role")

    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

    tickets, total, err := h.ticketUC.GetTickets(userID, role, page, limit)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "data":  tickets,
        "total": total,
        "page":  page,
        "limit": limit,
    })
}

func (h *TicketHandler) GetTicketByID(c *gin.Context) {
    id := c.Param("id")
    ticket, err := h.ticketUC.GetTicketByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "Tiket tidak ditemukan"})
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": ticket})
}

func (h *TicketHandler) UpdateStatus(c *gin.Context) {
    changedBy := c.GetString("user_id")
    id := c.Param("id")
    var req struct {
        Status string `json:"status" binding:"required"`
        Note   string `json:"note"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if err := h.ticketUC.UpdateStatus(id, changedBy, req.Status, req.Note); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "Status berhasil diupdate"})
}

func (h *TicketHandler) AssignTicket(c *gin.Context) {
    id := c.Param("id")
    var req struct {
        AssignTo string `json:"assign_to" binding:"required"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if err := h.ticketUC.AssignTicket(id, req.AssignTo); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "Tiket berhasil diassign"})
}

func (h *TicketHandler) AddComment(c *gin.Context) {
    userID := c.GetString("user_id")
    ticketID := c.Param("id")
    var req struct {
        Content string `json:"content" binding:"required"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if err := h.ticketUC.AddComment(ticketID, userID, req.Content); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, gin.H{"message": "Komentar ditambahkan"})
}

func (h *TicketHandler) UploadAttachment(c *gin.Context) {
    userID := c.GetString("user_id")
    ticketID := c.Param("id")

    file, header, err := c.Request.FormFile("file")
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "File tidak ditemukan"})
        return
    }
    defer file.Close()

    // Upload ke Supabase Storage
    path := fmt.Sprintf("tickets/%s/%s", ticketID, header.Filename)
    url, err := h.storage.Upload(path, file, header.Header.Get("Content-Type"))
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal upload file"})
        return
    }

    _ = userID
    if err := h.ticketUC.AddAttachment(ticketID, url, header.Filename, header.Header.Get("Content-Type")); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, gin.H{"url": url})
}

func (h *TicketHandler) GetStats(c *gin.Context) {
    userID := c.GetString("user_id")
    role := c.GetString("role")

    stats, err := h.ticketUC.GetStats(userID, role)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"data": stats})
}

func (h *TicketHandler) GetNotifications(c *gin.Context) {
    userID := c.GetString("user_id")
    notifs, err := h.ticketUC.GetNotifications(userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": notifs})
}

func (h *TicketHandler) MarkNotifRead(c *gin.Context) {
    id := c.Param("id")
    if err := h.ticketUC.MarkNotifRead(id); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    c.JSON(http.StatusOK, gin.H{"message": "Notifikasi ditandai sudah dibaca"})
}