package domain

// Account Roles
const (
	RoleAdmin Role = "ADMIN"
	RoleUser  Role = "USER"
)

// Account Statuses
const (
	StatusPending Status = "PENDING"
	StatusActive  Status = "ACTIVE"
	StatusBanned  Status = "BANNED"
	StatusDeleted Status = "DELETED"
)

// Auth Providers
const (
	ProviderEmail  Provider = "EMAIL"
	ProviderGoogle Provider = "GOOGLE"
)
