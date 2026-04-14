package repository

import (
    "e-ticketing-backend/internal/database"
    "e-ticketing-backend/internal/models"
)

type UserRepository interface {
    Create(user *models.User) error
    FindByEmail(email string) (*models.User, error)
    FindByID(id string) (*models.User, error)
    Update(user *models.User) error
    UpdateFCMToken(userID, token string) error
}

type userRepo struct{}

func NewUserRepository() UserRepository { return &userRepo{} }

func (r *userRepo) Create(user *models.User) error {
    return database.DB.Create(user).Error
}

func (r *userRepo) FindByEmail(email string) (*models.User, error) {
    var user models.User
    err := database.DB.Where("email = ?", email).First(&user).Error
    return &user, err
}

func (r *userRepo) FindByID(id string) (*models.User, error) {
    var user models.User
    err := database.DB.First(&user, "id = ?", id).Error
    return &user, err
}

func (r *userRepo) Update(user *models.User) error {
    return database.DB.Save(user).Error
}

func (r *userRepo) UpdateFCMToken(userID, token string) error {
    return database.DB.Model(&models.User{}).
        Where("id = ?", userID).
        Update("fcm_token", token).Error
}