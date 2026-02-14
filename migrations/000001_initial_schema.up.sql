-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. MASTER TABLES (Catalogs)
CREATE TABLE account_roles (
    code VARCHAR(32) PRIMARY KEY,
    description TEXT
);

CREATE TABLE account_statuses (
    code VARCHAR(32) PRIMARY KEY,
    description TEXT
);

CREATE TABLE auth_providers (
    code VARCHAR(32) PRIMARY KEY,
    description TEXT
);

-- Seed initial data
INSERT INTO account_roles (code) VALUES ('ADMIN'), ('USER');
INSERT INTO account_statuses (code) VALUES ('PENDING'), ('ACTIVE'), ('BANNED'), ('DELETED');
INSERT INTO auth_providers (code) VALUES ('EMAIL'), ('GOOGLE');

-- 2. DYNAMIC TABLES
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_code VARCHAR(32) NOT NULL REFERENCES account_roles(code),
    status_code VARCHAR(32) NOT NULL DEFAULT 'PENDING' REFERENCES account_statuses(code),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE auth_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    provider_code VARCHAR(32) NOT NULL REFERENCES auth_providers(code),
    provider_id VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    last_login_at TIMESTAMPTZ,
    UNIQUE (provider_code, provider_id)
);

CREATE TABLE verification_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_method_id UUID NOT NULL REFERENCES auth_methods(id) ON DELETE CASCADE,
    code_hash VARCHAR(255) NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    revoked_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. INDEXES
CREATE INDEX idx_auth_methods_account_id ON auth_methods (account_id);
CREATE INDEX idx_verification_codes_auth_method_id ON verification_codes (auth_method_id);
CREATE INDEX idx_refresh_tokens_account_id ON refresh_tokens (account_id);

-- Comments for documentation
COMMENT ON TABLE account_roles IS 'Master table for user roles';
COMMENT ON TABLE account_statuses IS 'Master table for account life cycle states';
COMMENT ON TABLE auth_providers IS 'Master table for supported authentication providers';
COMMENT ON TABLE accounts IS 'Core user account table';
COMMENT ON TABLE auth_methods IS 'Stores various ways a user can authenticate';
COMMENT ON TABLE verification_codes IS 'Stores OTP and verification hashes';
COMMENT ON TABLE refresh_tokens IS 'Manages long-lived sessions';