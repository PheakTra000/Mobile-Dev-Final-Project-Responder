# Responder — System Flow

## App Lifecycle

```mermaid
flowchart TD
    Start([App Launch]) --> AuthGate{_AuthGate<br/>check JWT}
    AuthGate -->|loading| Spin[Spinner]
    AuthGate -->|JWT exists| Dashboard[DashboardScreen]
    AuthGate -->|no JWT| Login[LoginScreen]

    Login -->|submit| API_Auth[POST /auth/login]
    API_Auth -->|token + uid| Storage[(FlutterSecureStorage)]
    API_Auth -->|token + uid| Storage[(FlutterSecureStorage)]
    Storage --> Dashboard

    Login -->|guest| Dashboard

    Dashboard -->|logout| Clear[deleteAll storage]
    Clear --> Login
```

## Authentication

```mermaid
sequenceDiagram
    participant U as User
    participant C as Flutter Client
    participant B as Node.js Backend
    participant F as Firestore

    U->>C: Enter email + password
    C->>B: POST /auth/login {email, password}
    B->>F: Query users by email
    F-->>B: User doc
    B->>B: bcrypt.compare(password, hash)
    B->>B: jwt.sign({uid, email}, SECRET)
    B-->>C: {token, uid}
    C->>C: Store jwt + uid in SecureStorage
    C->>C: Navigate → Dashboard
```

## Scan Execution

```mermaid
flowchart TD
    D[Dashboard] -->|Start New Scan| F[FormScreen]
    F -->|name + type| S[ScanningScreen]

    S --> R1[detectSubnet]
    R1 -->|IP from WiFi| R2[discoverDevices]
    R2 -->|ping sweep| R3[checkPorts]
    R3 -->|TCP connect| Save

    subgraph Save
        direction TB
        L[LocalStorage<br/>.json file] 
        P[ApiClient<br/>POST /scans]
    end

    Save --> L
    Save --> P
```

## Scan Detail (Cross-Device)

```mermaid
sequenceDiagram
    participant C as Device B
    participant B as Backend
    participant F as Firestore

    C->>C: Tap history card
    C->>B: GET /scans (Bearer JWT)
    B->>F: where userId == uid
    F-->>B: [{session}, ...]
    B-->>C: [AuditSession + devices[]]
    C->>C: Render device + port results
```

## Backend Routes

```mermaid
flowchart LR
    subgraph Express
        A["/auth"] --> AR[auth_routes.js]
        --> AR[auth_routes.js]
        S["/scans"] --> MW[verifyToken]
        MW --> SR[scan_routes.js]
    end

    subgraph Firestore
        U["users<br/>{email, pwd}"]
        SC["scans<br/>{userId, devices[], date}"]
    end

    AR --> U
    SR --> SC
```

## Data Layer

```mermaid
flowchart TB
    subgraph Client Storage
        SS["FlutterSecureStorage<br/>jwt, uid"]
        LS["Local Filesystem<br/>sessions/{uid}/{id}.json"]
    end

    subgraph Server Storage
        FB["Firestore<br/>users / scans"]
    end

    SS <--auth--> FB
    LS <--offline cache--- FB
```

## Full Request Flow

```mermaid
flowchart TD
    subgraph Flutter
        Screen[Screen]
        AC[ApiClient]
    end

    subgraph Backend
        Expr[Express]
        AuthMW[auth_middleware]
        Routes[Routes]
        FB[Firebase Admin]
    end

    Screen -->|HTTP| AC
    AC -->|HTTPS| Expr
    Expr -->|public| Routes
    Expr -->|JWT required| AuthMW
    AuthMW --> Routes
    Routes --> FB
```

## File Map

| Layer | File | Purpose |
|-------|------|---------|
| Entry | `lib/main.dart` | _AuthGate, routing |
| UI | `login_screen.dart` | Login form |
| UI | `signup_screen.dart` | Register form |
| UI | `form_screen.dart` | Scan config |
| UI | `scanning_screen.dart` | Scan execution + results |
| UI | `dashboard_screen.dart` | History list |
| Data | `api_client.dart` | HTTP to backend |
| Data | `local_storage.dart` | File persistence |
| Data | `dto/*.dart` | JSON serialize |
| Logic | `scan_repository.dart` | Ping, port scan |
| Backend | `server.js` | Express init |
| Backend | `auth_routes.js` | /auth endpoints |
| Backend | `scan_routes.js` | /scans CRUD |
| Backend | `auth_middleware.js` | JWT verify |
