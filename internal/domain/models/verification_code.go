package models

import (
	"time"

	"github.com/google/uuid"
)

type VerificationCode struct {
	ID           uuid.UUID
	AuthMethodID uuid.UUID
	CodeHash     string
	Attempts     int
	ExpiresAt    time.Time
	ConsumedAt   *time.Time
	CreatedAt    time.Time
}
