package models

import (
	"time"

	"github.com/TheJisus28/ranco-auth-service/internal/domain"
	"github.com/google/uuid"
)

type AuthMethod struct {
	ID           uuid.UUID
	AccountID    uuid.UUID
	ProviderCode domain.Provider
	ProviderID   string
	IsVerified   bool
	LastLoginAt  *time.Time
}
