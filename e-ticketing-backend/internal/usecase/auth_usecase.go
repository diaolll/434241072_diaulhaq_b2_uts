package usecase

import (
    "errors"
    "time"
    "e-ticketing-backend/internal/config"
    "e-ticketing-backend/internal/models"
    "e-ticketing-backend/internal/repository"
    "github.com/golang-jwt/jwt/v5"
    "github.com/google/uuid"
    "golang.org/x/crypto/bcrypt"
)

type AuthUsecase interface {
    Register(name, email, password string) (*models.User, error)
    Login(email, password string) (string, *models.User, error)
    ResetPassword(email, newPassword string) error
}

type authUsecase struct {
    userRepo repository.UserRepository
}

func NewAuthUsecase(r repository.UserRepository) AuthUsecase {
    return &authUsecase{userRepo: r}
}

func (u *authUsecase) Register(name, email, password string) (*models.User, error) {
    hashed, _ := bcrypt.GenerateFromPassword([]byte(password), 12)
    user := &models.User{
        ID:       uuid.New().String(),
        Name:     name,
        Email:    email,
        Password: string(hashed),
        Role:     models.RoleUser,
    }
    if err := u.userRepo.Create(user); err != nil {
        return nil, errors.New("email already exists")
    }
    return user, nil
}

func (u *authUsecase) Login(email, password string) (string, *models.User, error) {
    user, err := u.userRepo.FindByEmail(email)
    if err != nil {
        return "", nil, errors.New("invalid email or password")
    }

    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
        return "", nil, errors.New("invalid email or password")
    }

    claims := &Claims{
        UserID: user.ID,
        Role:   string(user.Role),
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)),
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    tokenStr, _ := token.SignedString([]byte(config.AppConfig.JWTSecret))

    return tokenStr, user, nil
}

func (u *authUsecase) ResetPassword(email, newPassword string) error {
    user, err := u.userRepo.FindByEmail(email)
    if err != nil {
        return errors.New("user not found")
    }
    hashed, _ := bcrypt.GenerateFromPassword([]byte(newPassword), 12)
    user.Password = string(hashed)
    return u.userRepo.Update(user)
}

type Claims struct {
    UserID string `json:"user_id"`
    Role   string `json:"role"`
    jwt.RegisteredClaims
}