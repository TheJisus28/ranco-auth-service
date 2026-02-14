-- Drop indexes first (Optional, but clean)
DROP INDEX IF EXISTS idx_refresh_tokens_account_id;
DROP INDEX IF EXISTS idx_verification_codes_auth_method_id;
DROP INDEX IF EXISTS idx_auth_methods_account_id;

-- Drop dynamic tables (Dependants)
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS verification_codes;
DROP TABLE IF EXISTS auth_methods;
DROP TABLE IF EXISTS accounts;

-- Drop master tables (Dependencies)
DROP TABLE IF EXISTS auth_providers;
DROP TABLE IF EXISTS account_statuses;
DROP TABLE IF EXISTS account_roles;

-- Optional: Drop extension if it was created specifically for this schema
-- DROP EXTENSION IF EXISTS "uuid-ossp";