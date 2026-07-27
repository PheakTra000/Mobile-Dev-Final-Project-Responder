# Responder — Project Code Flow

## 1. STARTUP

```
main.dart → _AuthGate
  ├─ reads JWT from FlutterSecureStorage
  ├─ JWT exists → DashboardScreen
  └─ no JWT → LoginScreen
```

- `main.dart:78-108` — `_AuthGate` checks for stored JWT on app launch
- If `_token == null` → shows loading spinner
- If `_token.isNotEmpty` → navigates directly to `DashboardScreen`
- If `_token.isEmpty` → shows `LoginScreen`

---

## 2. AUTH FLOW

### Login

```
LoginScreen → ApiClient.login() → POST /auth/login
  → stores JWT + uid in FlutterSecureStorage → /dashboard
```

- `login_screen.dart:31` — calls `ApiClient.instance.login(email, password)`
- `api_client.dart:13-31` — `POST https://backend.sybau-ctf.space/auth/login`, returns `{token, uid}`
- Stores `jwt` and `uid` in FlutterSecureStorage
- Navigates to `/dashboard`

### Register

```
SignupScreen → ApiClient.register() → POST /auth/register
  → stores JWT + uid → /dashboard
```

- `signup_screen.dart:32` — local validation, then `ApiClient.instance.register()`
- `api_client.dart:33-51` — `POST /auth/register`, returns `{token, uid}`
- Stores credentials → `/dashboard`

### Guest

```
login_screen.dart:53 — writes 'guest=true' → /dashboard (no API auth)
```

### Backend Auth

| Endpoint | File | Description |
|----------|------|-------------|
| `POST /auth/register` | `auth_routes.js:16-49` | Validates, bcrypt hash, create user, sign JWT |
| `POST /auth/login` | `auth_routes.js:52-82` | Validates, bcrypt compare, sign JWT |

- JWT: `jwt.sign({uid, email}, JWT_SECRET, {expiresIn: '7d'})`
- Firestore `users` collection: `{email, password(bcrypt), createdAt}`

---

## 3. SCAN FLOW

```
Dashboard → FormScreen → ScanningScreen
```

### Step 1: Configure Scan

- `dashboard_screen.dart:180` — "Start New Scan" → `/form`
- `form_screen.dart:76-88` — user enters profile name + selects scan type (quick/deep)
- Navigates to `/scanning` with arguments `{profileName, scanType}`

### Step 2: Execute Scan

- `scanning_screen.dart:42-57` — `initState` → `_init()`
  - If `sessionId != null` → `_loadSessionDetail()` (view past scan)
  - Else → `_startScan()` (new scan)

#### New Scan (`scanning_screen.dart:86-160`)

```
ScanningScreen._startScan()
  │
  ├─ ScanRepositoryImpl().detectSubnet()
  │    └─ scan_repository.dart:212-222
  │         ├─ NetworkInfo().getWifiIP()
  │         ├─ reads /proc/net/route for subnet mask
  │         └─ computes "192.168.x.x/24"
  │
  ├─ ScanRepositoryImpl().discoverDevices(subnet)
  │    └─ scan_repository.dart:225-254
  │         ├─ parses CIDR, max 256 hosts
  │         ├─ batches of 20 hosts
  │         └─ _pingHost(ip) per host
  │              ├─ Process.run('ping', ['-c','1','-W','2', ip])
  │              ├─ fallback: Socket.connect(ip, 80)
  │              ├─ DNS lookup for hostname
  │              └─ returns NetworkDevice(ip, mac, hostname)
  │
  ├─ For each device (batches of 10):
  │    └─ ScanRepositoryImpl().checkPorts(device, scanType)
  │         └─ scan_repository.dart:289-318
  │              ├─ quick: 13 common ports | deep: 200+ ports
  │              ├─ Socket.connect(device.ip, port, timeout: 2s)
  │              ├─ maps port → service name
  │              ├─ assigns RiskLevel (low/medium/high)
  │              └─ returns List<ExposedPort>
  │
  └─ _saveSession(results)
```

### Step 3: Save Session

```
scanning_screen.dart:162-181  _saveSession()
  │
  ├─ Creates AuditSession model
  │    └─ id = DateTime.now().toIso8601String()
  │
  ├─ LocalStorage.saveSession(session)
  │    └─ local_storage.dart:24-28
  │         ├─ getApplicationDocumentsDirectory()
  │         ├─ path: {dir}/sessions/{userId}/{id}.json
  │         └─ writes AuditSessionDto.toJson(session)
  │
  └─ ApiClient.backupSession(session)  [if JWT exists]
       └─ api_client.dart:62-72
            ├─ reads JWT → Authorization: Bearer
            ├─ POST https://backend.sybau-ctf.space/scans
            └─ body: AuditSessionDto.toJson(session)
```

### Backend: Save Scan

```
scan_routes.js:7-33  POST /scans
  ├─ auth_middleware verifies JWT → req.user = {uid, email}
  ├─ validates profileName + scanType
  ├─ scansRef.add({userId, profileName, scanType, deviceCount, devices, date})
  └─ returns {id, ...session}
```

---

## 4. VIEW HISTORY (DASHBOARD)

```
dashboard_screen.dart:42-59  _loadHistory()
  │
  └─ ApiClient.instance.fetchSessions()
       └─ api_client.dart:74-85
            ├─ reads JWT from FlutterSecureStorage
            ├─ GET https://backend.sybau-ctf.space/scans
            ├─ jsonDecode → List
            └─ AuditSessionDto.fromJson() per item

Backend: scan_routes.js:36-51
  └─ db.collection('scans').where('userId', '==', req.user.uid)
       .orderBy('date', 'desc').get()

Dashboard renders HistoryCard list
  ├─ onTap → /scanning with sessionId (view detail)
  ├─ onRename → LocalStorage.renameSession(id, name)
  └─ onDelete → LocalStorage.deleteSession(id)
```

---

## 5. VIEW PAST SCAN DETAIL

```
scanning_screen.dart:61-84  _loadSessionDetail()
  │
  └─ ApiClient.instance.fetchSessions()
       ├─ GET /scans (returns all user sessions)
       ├─ finds session by sessionId
       └─ renders device + port results
```

---

## 6. BACKEND ARCHITECTURE

```
server.js
  ├─ initFirebase() → firebase_config.js
  │    └─ admin.initializeApp({credential: serviceAccountKey.json})
  │
  ├─ middleware: cors(), express.json()
  │
  ├─ /auth → auth_routes.js  (public)
  │    ├─ POST /register → create user + sign JWT
  │    └─ POST /login → verify + sign JWT
  │
  └─ /scans → verifyToken → scan_routes.js  (JWT required)
       ├─ POST / → create scan session
       ├─ GET / → list user's scans
       ├─ GET /:id → single scan detail
       ├─ PUT /:id → rename session
       └─ DELETE /:id → delete session
```

### Auth Middleware

```
auth_middleware.js:3-19
  Authorization: Bearer <token>
    → jwt.verify(token, JWT_SECRET)
    → req.user = {uid, email}
```

---

## 7. DATA MODELS & DTOs

| Model | DTO | Fields |
|-------|-----|--------|
| `AuditSession` | `AuditSessionDto` | id, profileName, date, deviceCount, scanType, devices? |
| `NetworkDevice` | `NetworkDeviceDto` | ip, mac, hostname, deviceType |
| `ExposedPort` | `ExposedPortDto` | port, serviceType, riskLevel |
| `DeviceWithPorts` | `DeviceWithPortsDto` | device, ports |

**Enums:** `ScanType {quick, deep}`, `RiskLevel {low, medium, high}`

**Serialization:** `AuditSession → AuditSessionDto.toJson() → DeviceWithPortsDto.toJson() → NetworkDeviceDto.toJson() + ExposedPortDto.toJson()`

---

## 8. DATA FLOW DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT                            │
│                                                                  │
│  main.dart → _AuthGate → DashboardScreen → FormScreen            │
│       │            │          │                                   │
│       ▼            ▼          ▼                                   │
│  LoginScreen   SignupScreen  ScanningScreen                      │
│       │            │          │                                   │
│       └─────┬──────┘          │                                   │
│             ▼                 ▼                                   │
│  ┌─────────────────────────────────────┐                         │
│  │ ApiClient (singleton)               │                         │
│  │  .login()    → POST /auth           │                         │
│  │  .register() → POST /auth           │                         │
│  │  .backupSession() → POST /scans     │                         │
│  │  .fetchSessions() → GET /scans      │                         │
│  └──────────────┬──────────────────────┘                         │
│                 │                                                │
│  ┌──────────────┴──────────────────────┐                         │
│  │ FlutterSecureStorage                │                         │
│  │  jwt, uid, guest                    │                         │
│  └─────────────────────────────────────┘                         │
│                                                                  │
│  ┌─────────────────────────────────────┐                         │
│  │ LocalStorage                        │                         │
│  │  sessions/{uid}/{id}.json           │                         │
│  │  save / load / rename / delete      │                         │
│  └─────────────────────────────────────┘                         │
└──────────────────┬───────────────────────────────────────────────┘
                   │ HTTPS
                   ▼
┌──────────────────────────────────────────────────────────────────┐
│                     NODE.JS BACKEND                              │
│                                                                  │
│  server.js                                                       │
│    ├─ /auth → auth_routes.js (bcrypt + JWT)                      │
│    └─ /scans → auth_middleware → scan_routes.js (CRUD)           │
│                          │                                       │
│                          ▼                                       │
│                ┌──────────────────┐                              │
│                │ Firebase Firestore│                              │
│                │  users: {email,   │                              │
│                │    password(hash)}│                              │
│                │  scans: {userId,  │                              │
│                │    profileName,   │                              │
│                │    devices[],     │                              │
│                │    date}          │                              │
│                └──────────────────┘                              │
└──────────────────────────────────────────────────────────────────┘
```

---

## 9. KEY FILE INDEX

| File | Lines | Role |
|------|-------|------|
| `lib/main.dart` | 109 | App entry, routing, auth gate |
| `lib/ui/screens/login_screen.dart` | 132 | Login UI + guest mode |
| `lib/ui/screens/signup_screen.dart` | 141 | Registration UI |
| `lib/ui/screens/form_screen.dart` | 187 | Scan config (name + type) |
| `lib/ui/screens/scanning_screen.dart` | 320 | Scan orchestration + results |
| `lib/ui/screens/dashboard_screen.dart` | 402 | History list + network info |
| `lib/data/api_client.dart` | 90 | HTTP client (auth + scans) |
| `lib/data/local_storage.dart` | 74 | File-based session persistence |
| `lib/repositories/scan_repository.dart` | 350 | Network scan logic (ping, port scan) |
| `lib/models/audit_session.dart` | 21 | Core session model |
| `lib/models/network_device.dart` | 16 | Device model |
| `lib/models/exposed_port.dart` | 16 | Port + risk model |
| `lib/models/device_with_ports.dart` | 9 | Composite model |
| `lib/data/dto/audit_session_dto.dart` | 30 | JSON serialization |
| `lib/data/dto/network_device_dto.dart` | — | JSON serialization |
| `lib/data/dto/exposed_port_dto.dart` | — | JSON serialization |
| `lib/data/dto/device_with_ports_dto.dart` | — | JSON serialization |
| `lib/data/async_data.dart` | 20 | State wrapper (notstarted/loading/success/error) |
| `backend/server.js` | 29 | Express bootstrap |
| `backend/routes/auth_routes.js` | 84 | Auth endpoints |
| `backend/routes/scan_routes.js` | 123 | Scan CRUD endpoints |
| `backend/middleware/auth_middleware.js` | 21 | JWT verification |
| `backend/firebase/firebase_config.js` | 28 | Firebase Admin SDK init |
