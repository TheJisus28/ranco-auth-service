package models

import (
	"time"

	"github.com/TheJisus28/ranco-auth-service/internal/domain"

	"github.com/google/uuid"
)

type Account struct {
	ID         uuid.UUID
	RoleCode   domain.Role
	StatusCode domain.Status
	CreatedAt  time.Time
}
