# Responder Backend

Express + Firestore backend for the Responder app. Handles user auth (JWT)
and CRUD on scan history.

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Get a Firebase service account key:
   Firebase Console > Project Settings > Service Accounts > Generate new
   private key. Save the downloaded file as:
   ```
   firebase/serviceAccountKey.json
   ```

3. Copy `.env.example` to `.env` and fill in `JWT_SECRET` (any long random
   string works, e.g. generate one with `openssl rand -hex 32`):
   ```
   cp .env.example .env
   ```

4. In Firestore, create a composite index for the scans query if prompted
   (Firestore will give you a direct link the first time you call
   `GET /scans` — just click it and wait ~1 min for it to build). This is
   needed because the query filters by `userId` and orders by `date`.

5. Run it:
   ```
   npm start
   ```
   Server starts on `http://localhost:3000` (or whatever `PORT` you set).

## Endpoints

| Method | Route          | Auth required | Body                                  |
|--------|----------------|:--------------:|----------------------------------------|
| POST   | /auth/register | No             | `{ email, password }`                  |
| POST   | /auth/login    | No             | `{ email, password }`                  |
| POST   | /scans         | Yes            | `{ profileName, scanType, deviceCount, devices }` |
| GET    | /scans         | Yes            | —                                       |
| GET    | /scans/:id     | Yes            | —                                       |
| PUT    | /scans/:id     | Yes            | `{ profileName }`                      |
| DELETE | /scans/:id     | Yes            | —                                       |

Protected routes need the header:
```
Authorization: Bearer <token from register/login>
```

## Quick test with curl

```bash
# Register
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Save the returned token, then:
curl -X POST http://localhost:3000/scans \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"profileName":"Home WiFi","scanType":"Quick","devices":[{"ip":"192.168.1.5","mac":"AA:BB:CC:DD:EE:FF","hostname":"router","ports":[{"port":80,"serviceType":"http","riskLevel":"low"}]}]}'

# List history
curl http://localhost:3000/scans -H "Authorization: Bearer <TOKEN>"
```

## Notes

- `users` and `scans` are separate Firestore collections, both created
  automatically on first write — no manual schema setup needed.
- Passwords are hashed with bcrypt before being stored; the plaintext
  password is never saved or returned.
- `GET/PUT/DELETE /scans/:id` check that the session's `userId` matches the
  requester's token before allowing access, so one user can't read or modify
  another user's scan history.
