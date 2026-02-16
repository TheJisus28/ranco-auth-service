
# Use Case: Verify Email Confirmation Code

---

# Actors

* **Client**: Mobile or Web application
* **AuthHandler (API Layer)**: Handles HTTP transport and request/response parsing
* **AuthService (Application Layer)**: Orchestrates business logic and domain rules
* **AccountRepository**: Handles persistence for the `accounts` table
* **AuthMethodRepository**: Handles persistence for authentication methods
* **VerificationCodeRepository**: Handles persistence for OTP / verification codes
* **RefreshTokenRepository**: Handles persistence for refresh tokens
* **TokenService**: Generates access and refresh JWT tokens

---

# Data Models

## accounts

* `id` (UUID)
* `status_code` (PENDING, ACTIVE, BANNED, DELETED)
* `role_code` (String)
* `created_at` (Timestamp)

---

## auth_methods

* `id` (UUID)
* `account_id` (UUID)
* `provider_code` (EMAIL, GOOGLE, etc.)
* `provider_id` (String — email)
* `is_verified` (Boolean)
* `last_login_at` (Timestamp, nullable)

---

## verification_codes

* `id` (UUID)
* `auth_method_id` (UUID)
* `code_hash` (String)
* `attempts` (Integer — incremented on invalid submission)
* `expires_at` (Timestamp)
* `consumed_at` (Timestamp, nullable)
* `created_at` (Timestamp)

---

## refresh_tokens

* `id` (UUID)
* `account_id` (UUID)
* `token_hash` (String)
* `expires_at` (Timestamp)
* `created_at` (Timestamp)

---

# Sequence Diagram

```mermaid
sequenceDiagram

participant Client
participant AuthHandler
participant AuthService
participant AuthMethodRepo
participant AccountRepo
participant VerificationRepo
participant RefreshTokenRepo
participant TokenService

Client->>AuthHandler: POST /auth/verify-email
AuthHandler->>AuthService: VerifyEmail(ctx, email, code)

AuthService->>AuthMethodRepo: FindByProvider(provider_code, provider_id)
AuthMethodRepo-->>AuthService: AuthMethod

AuthService->>AccountRepo: FindByID(account_id)
AccountRepo-->>AuthService: Account

AuthService->>AuthService: ValidateAccountStatus(account.status_code)

AuthService->>VerificationRepo: FindLatestByAuthMethod(auth_method_id)
VerificationRepo-->>AuthService: VerificationCode


AuthService->>AuthService: ValidateCodeExpiration(code.expires_at)
AuthService->>AuthService: ValidateCodeNotConsumed(code.consumed_at)
AuthService->>AuthService: CompareCodeHash(input_code, code.code_hash)

Note over AuthService: Begin Database Transaction

AuthService->>VerificationRepo: UpdateConsumedAt(code_id, now)
VerificationRepo-->>AuthService: OK

AuthService->>AuthMethodRepo: UpdateVerified(auth_method_id, true)
AuthMethodRepo-->>AuthService: OK

AuthService->>AccountRepo: UpdateStatus(account_id, ACTIVE)
AccountRepo-->>AuthService: OK

AuthService->>TokenService: GenerateRefreshToken(account_id)
TokenService-->>AuthService: refreshToken

AuthService->>RefreshTokenRepo: Insert(account_id, token_hash, expires_at)
RefreshTokenRepo-->>AuthService: OK

AuthService->>TokenService: GenerateAccessToken(account_id, role, status)
TokenService-->>AuthService: accessToken

Note over AuthService: Commit Transaction

AuthService-->>AuthHandler: VerifyEmailResult(accessToken, refreshToken, account)
AuthHandler-->>Client: 200 OK

````

---

# Success Response

When the verification process completes successfully:

| Field           | Type         | Description                                           |
| --------------- | ------------ | ----------------------------------------------------- |
| `access_token`  | String (JWT) | Short-lived token used for authenticated API requests |
| `refresh_token` | String (JWT) | Long-lived token used to obtain new access tokens     |
| `account`       | Object       | Authenticated account information                     |

---

### Response Body (200 OK)

```json
{
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token",
  "account": {
    "id": "uuid",
    "status_code": "ACTIVE",
    "role_code": "USER"
  }
}
```

---




# Error Handling

| Error Code                       | Trigger Condition                       | State Consequence      | HTTP Status | Response                                        |
| -------------------------------- | --------------------------------------- | ---------------------- | ----------- | ----------------------------------------------- |
| `invalid_or_expired_code`        | Auth method not found                   | No state mutation      | 400         | `{ "error": "invalid_or_expired_code" }`        |
| `invalid_account_state`          | Account status ≠ `PENDING`              | No state mutation      | 409         | `{ "error": "invalid_account_state" }`          |
| `invalid_or_expired_code`        | Verification code not found             | No state mutation      | 400         | `{ "error": "invalid_or_expired_code" }`        |
| `invalid_or_expired_code`        | Code expired                            | No state mutation      | 400         | `{ "error": "invalid_or_expired_code" }`        |
| `invalid_or_expired_code`        | Code already consumed                   | No state mutation      | 400         | `{ "error": "invalid_or_expired_code" }`        |
| `invalid_or_expired_code`        | Hash mismatch                           | `attempts` incremented | 400         | `{ "error": "invalid_or_expired_code" }`        |
| `verification_attempts_exceeded` | Attempts exceed maximum after increment | Code marked unusable   | 400         | `{ "error": "verification_attempts_exceeded" }` |
| `internal_error`                 | Any failure inside transaction          | Full rollback          | 500         | `{ "error": "internal_error" }`                 |

---

# Operational Rules

* All state mutations and token generation occur inside a single database transaction
* All business validation is executed inside `AuthService`
* Repositories only perform persistence operations
* No token is returned if the transaction fails
* Verification codes cannot be reused
* Public error messages do not expose internal validation details

