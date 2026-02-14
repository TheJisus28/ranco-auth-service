package domain

import (
	"time"

	"github.com/google/uuid"
)

type Account struct {
	ID         uuid.UUID
	RoleCode   Role
	StatusCode Status
	CreatedAt  time.Time
}
