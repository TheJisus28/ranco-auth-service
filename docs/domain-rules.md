# Auth Service – Domain Rules

This document defines the business rules governing the authentication system.

---

# 1. Account

## Roles

* Every account must have a valid `role_code`.
* The role is defined at the time of creation.
* The role does not change during the registration process.

## Status

Possible statuses:

* `PENDING`
* `ACTIVE`
* `BANNED`
* `DELETED`

**Rules:**

* A new account created via **EMAIL** starts as `PENDING`.
* A new account created via **OAUTH** starts as `ACTIVE`.
* Only accounts in `ACTIVE` status can authenticate.
* `BANNED` and `DELETED` accounts cannot authenticate.
* A `PENDING` account cannot log in until it has been verified.

---

# 2. Auth Method

* An account can only have **one single auth_method**.
* Combining multiple providers is not permitted.
* The combination of `(provider_code, provider_id)` must be unique system-wide.
* If the provider is `EMAIL`, `is_verified` starts as `false`.
* If the provider is **OAuth**, `is_verified` starts as `true`.
* Only verified methods allow login.
* `last_login_at` is updated only after a successful login.

---

# 3. Verification Codes

* These apply strictly to `EMAIL` methods.
* Each code:
* Must have a mandatory expiration.
* Can be consumed only once.


* Expired codes cannot be validated.
* Already consumed codes cannot be validated.
* Failed attempts increment the `attempts` counter.
* There can be at most one active code per `auth_method`.
* Generating a new code invalidates any previous unconsumed code.

---

# 4. Refresh Tokens (Sessions)

* An account can only have **one active refresh token**.
* Concurrent sessions are not allowed.
* A successful login must:
1. Revoke any existing active token.
2. Generate a new refresh token.


* A revoked token cannot be reused.
* An expired token cannot be reused.
* **Logout** revokes the current token.
* **Global Logout** revokes all tokens associated with the account.

---

# 5. Registration

## Registration via EMAIL

1. Create account (`PENDING`)
2. Create auth_method (`EMAIL`, `is_verified=false`)
3. Create verification_code

The account is activated only after successful verification.

## Registration via OAuth

1. Create account (`ACTIVE`)
2. Create auth_method (`OAUTH`, `is_verified=true`)
3. Verification codes are not generated.

---

# 6. Login

To allow login, all of the following conditions must be met:

* The account exists.
* The account status is `ACTIVE`.
* The auth_method exists.
* The auth_method is verified.
* The credentials provided are valid.

**Upon authentication:**

* `last_login_at` is updated.
* Previous active tokens are revoked.
* A new refresh token is generated.

---

# 7. Security

* Plaintext codes are never stored; only `code_hash` is persisted.
* Plaintext refresh tokens are never stored; only `token_hash` is persisted.
* All status validations must be executed before issuing tokens.
* Registration and login operations must be executed within a transaction.

---

This document defines the expected behavior of the system.
Implementations must adhere to these rules without exception.
