package domain

import (
	"time"

	"github.com/google/uuid"
)

type RefreshToken struct {
	ID        uuid.UUID
	AccountID uuid.UUID
	TokenHash string
	IPAddress *string
	UserAgent *string
	RevokedAt *time.Time
	ExpiresAt time.Time
	CreatedAt time.Time
}
