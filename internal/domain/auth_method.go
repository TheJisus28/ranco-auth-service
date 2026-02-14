package domain

import (
	"time"

	"github.com/google/uuid"
)

type AuthMethod struct {
	ID           uuid.UUID
	AccountID    uuid.UUID
	ProviderCode Provider
	ProviderID   string
	IsVerified   bool
	LastLoginAt  *time.Time
}
