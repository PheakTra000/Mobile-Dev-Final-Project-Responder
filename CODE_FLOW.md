# Responder — Function Call Flow

## Entry Point

### `main()` — `lib/main.dart:12`
- Calls `runApp(ResponderApp())`
- **Calls:** `ResponderApp.build()`

---

## `ResponderApp.build()` — `lib/main.dart:20`
- Creates `MaterialApp` with routes
- Sets `home: _AuthGate()`
- **Calls:** `_AuthGate()` constructor

---

## `_AuthGate` — `lib/main.dart:78`

### `_AuthGateState.initState()` — `lib/main.dart:90`
- **Calls:** `_checkSession()`

### `_AuthGateState._checkSession()` — `lib/main.dart:95`
- Reads JWT from `FlutterSecureStorage`
- **Calls:** `FlutterSecureStorage().read(key: 'jwt')`
- **Calls:** `setState()` → triggers `build()`

### `_AuthGateState.build()` — `lib/main.dart:104`
- If `!_checked` → returns `CircularProgressIndicator`
- If `_token.isNotEmpty` → **returns:** `DashboardScreen()`
- Else → **returns:** `LoginScreen()`

---

## Login Screen — `lib/ui/screens/login_screen.dart`

### `_LoginScreenState._login()` — `login_screen.dart:31`
- Validates input, authenticates user
- **Calls:** `ApiClient.instance.login(email, password)` → `api_client.dart:13`
- **Calls:** `FlutterSecureStorage().write(key: 'jwt', value: token)`
- **Calls:** `FlutterSecureStorage().write(key: 'uid', value: uid)`
- **Calls:** `Navigator.pushReplacementNamed('/dashboard')`

### `_LoginScreenState._guestLogin()` — `login_screen.dart:53`
- **Calls:** `FlutterSecureStorage().write(key: 'guest', value: 'true')`
- **Calls:** `Navigator.pushReplacementNamed('/dashboard')`

### `_LoginScreenState._buildTextField()` — `login_screen.dart:111`
- Returns `TextField` widget (no external calls)

### `_LoginScreenState._buildButton()` — `login_screen.dart:122`
- Returns `ElevatedButton` widget (no external calls)

---

## Signup Screen — `lib/ui/screens/signup_screen.dart`

### `_SignupScreenState._register()` — `signup_screen.dart:32`
- Validates: empty fields, password length ≥6, passwords match
- **Calls:** `ApiClient.instance.register(email, password)` → `api_client.dart:33`
- **Calls:** `FlutterSecureStorage().write(key: 'jwt', value: token)`
- **Calls:** `FlutterSecureStorage().write(key: 'uid', value: uid)`
- **Calls:** `Navigator.pushReplacementNamed('/dashboard')`

---

## Form Screen — `lib/ui/screens/form_screen.dart`

### `_FormScreenState.build()` — `form_screen.dart:27`
- Renders scan configuration UI
- **Calls:** `_ScanOptionTile` constructor (lines 100-154)
- **Calls:** `_Radio` constructor (lines 156-186)

### "Start New Scan" button — `form_screen.dart:76`
- Validates name not empty
- **Calls:** `Navigator.pushNamed('/scanning', arguments: {...})`

---

## Dashboard Screen — `lib/ui/screens/dashboard_screen.dart`

### `_DashboardScreenState._init()` — `dashboard_screen.dart:32`
- **Calls:** `FlutterSecureStorage().read(key: 'uid')`
- **Calls:** `_loadHistory()`

### `_DashboardScreenState._loadHistory()` — `dashboard_screen.dart:42`
- Sets state to `AsyncData.loading()`
- **Calls:** `ApiClient.instance.fetchSessions()` → `api_client.dart:74`
- On success → `setState(AsyncData.success(sessions))`
- On error → `setState(AsyncData.error(e))`

### `_DashboardScreenState._showRenameDialog()` — `dashboard_screen.dart:61`
- Shows dialog with text field
- On confirm → **Calls:** `_ls.renameSession(id, name)` → `local_storage.dart:51`
- **Calls:** `_loadHistory()` (refresh)

### `_DashboardScreenState._showDeleteDialog()` — `dashboard_screen.dart:98`
- Shows confirmation dialog
- On confirm → **Calls:** `_ls.deleteSession(id)` → `local_storage.dart:46`
- **Calls:** `_loadHistory()` (refresh)

### `_DashboardScreenState._buildHistoryList()` — `dashboard_screen.dart:202`
- Switches on `_sessions.status`:
  - `notstarted` → "Tap to refresh"
  - `loading` → `CircularProgressIndicator`
  - `error` → error text
  - `success` → **Calls:** `_buildSessionList()`

### `_DashboardScreenState._buildSessionList()` — `dashboard_screen.dart:226`
- Renders `ListView.builder` with `HistoryCard` per session
- **Calls:** `HistoryCard` constructor (from `widgets/history_card.dart`)

### `_NetworkInfoCardState._loadNetworkInfo()` — `dashboard_screen.dart:283`
- **Calls:** `Permission.location.request()`
- **Calls:** `NetworkInfo().getWifiName()`
- **Calls:** `NetworkInfo().getWifiGatewayIP()`
- **Calls:** `NetworkInfo().getWifiIP()`
- **Calls:** `File('/proc/net/route').readAsLines()` (for subnet mask)
- **Calls:** `_ipToInt()` (static helper, line 272)

### Logout — `dashboard_screen.dart:137`
- **Calls:** `FlutterSecureStorage().deleteAll()`
- **Calls:** `Navigator.pushNamedAndRemoveUntil('/login')`

---

## Scanning Screen — `lib/ui/screens/scanning_screen.dart`

### `_ScanningScreenState._init()` — `scanning_screen.dart:47`
- **Calls:** `FlutterSecureStorage().read(key: 'uid')`
- If `sessionId != null` → **Calls:** `_loadSessionDetail()`
- Else → **Calls:** `_startScan()`

### `_ScanningScreenState._loadSessionDetail()` — `scanning_screen.dart:61`
- **Calls:** `ApiClient.instance.fetchSessions()` → `api_client.dart:74`
- Finds session by `sessionId`
- Sets `_results = session.devices ?? []`

### `_ScanningScreenState._startScan()` — `scanning_screen.dart:86`
- **Calls:** `ScanRepositoryImpl()` constructor
- **Calls:** `repo.detectSubnet()` → `scan_repository.dart:212`
- **Calls:** `repo.discoverDevices(subnet, onProgress)` → `scan_repository.dart:225`
- For each device batch:
  - **Calls:** `repo.checkPorts(device, scanType)` → `scan_repository.dart:289`
- **Calls:** `_saveSession(results)`

### `_ScanningScreenState._saveSession()` — `scanning_screen.dart:162`
- Creates `AuditSession` model
- **Calls:** `_ls.saveSession(session)` → `local_storage.dart:24`
- If JWT exists → **Calls:** `ApiClient.instance.backupSession(session)` → `api_client.dart:62`

### `_ScanningScreenState._onExportReportPressed()` — `scanning_screen.dart:183`
- Builds report string
- **Calls:** `Share.share(buffer.toString())`

---

## ApiClient — `lib/data/api_client.dart`

### `ApiClient.login()` — `api_client.dart:13`
- **Calls:** `http.post('$baseUrl/auth/login')`
- Returns `{token, uid}`

### `ApiClient.register()` — `api_client.dart:33`
- **Calls:** `http.post('$baseUrl/auth/register')`
- Returns `{token, uid}`

### `ApiClient._authHeaders()` — `api_client.dart:53`
- **Calls:** `FlutterSecureStorage().read(key: 'jwt')`
- Returns headers with `Authorization: Bearer $token`

### `ApiClient.backupSession()` — `api_client.dart:62`
- **Calls:** `_authHeaders()`
- **Calls:** `AuditSessionDto.toJson(session)`
- **Calls:** `http.post('$baseUrl/scans')`

### `ApiClient.fetchSessions()` — `api_client.dart:74`
- **Calls:** `_authHeaders()`
- **Calls:** `http.get('$baseUrl/scans')`
- **Calls:** `AuditSessionDto.fromJson()` per item
- Returns `List<AuditSession>`

---

## LocalStorage — `lib/data/local_storage.dart`

### `LocalStorage.saveSession()` — `local_storage.dart:24`
- **Calls:** `getApplicationDocumentsDirectory()`
- **Calls:** `AuditSessionDto.toJson(session)`
- **Calls:** `File.writeAsString(json)`

### `LocalStorage.loadSessions()` — `local_storage.dart:30`
- **Calls:** `getApplicationDocumentsDirectory()`
- **Calls:** `Directory.list()`
- **Calls:** `File.readAsString()` per file
- **Calls:** `AuditSessionDto.fromJson()` per file
- Returns sorted `List<AuditSession>`

### `LocalStorage.deleteSession()` — `local_storage.dart:46`
- **Calls:** `File.delete()`

### `LocalStorage.renameSession()` — `local_storage.dart:51`
- **Calls:** `File.readAsString()`
- **Calls:** `AuditSessionDto.fromJson()`
- **Calls:** `File.writeAsString()` (updated name)

### `LocalStorage.deleteAll()` — `local_storage.dart:67`
- **Calls:** `Directory.delete(recursive: true)`

---

## ScanRepository — `lib/repositories/scan_repository.dart`

### `ScanRepositoryImpl.detectSubnet()` — `scan_repository.dart:212`
- **Calls:** `NetworkInfo().getWifiIP()`
- **Calls:** `_readSubnetMask(wifiIp)` → line 163
- **Calls:** `_computeNetwork(ip, prefix)` → line 190
- Returns CIDR string (e.g., "192.168.1.0/24")

### `ScanRepositoryImpl.discoverDevices()` — `scan_repository.dart:225`
- Parses CIDR, computes host count (max 256)
- Batches of 20 hosts
- **Calls:** `_pingHost(ip)` per host → line 256
- **Calls:** `onProgress()` callback
- Returns `List<NetworkDevice>`

### `ScanRepositoryImpl._pingHost()` — `scan_repository.dart:256`
- **Calls:** `Process.run('ping', ['-c', '1', '-W', '2', ip])`
- Fallback: **Calls:** `Socket.connect(ip, 80, timeout: 500ms)`
- **Calls:** `InternetAddress.lookup(ip)` (DNS for hostname)
- Returns `NetworkDevice?`

### `ScanRepositoryImpl.checkPorts()` — `scan_repository.dart:289`
- Selects port list: `_quickPorts` (13) or `_deepPorts` (200+)
- For each port:
  - **Calls:** `Socket.connect(device.ip, port, timeout: 2s)`
  - Maps port → service name via `_serviceMap`
  - Assigns `RiskLevel` via `_highRisk` / `_mediumRisk` sets
- Returns `List<ExposedPort>`

### `ScanRepositoryImpl.runScan()` — `scan_repository.dart:321`
- **Calls:** `detectSubnet()`
- **Calls:** `discoverDevices(subnet)`
- **Calls:** `checkPorts(device, type)` per device
- Returns `AuditSession`

---

## AsyncData — `lib/data/async_data.dart`

State wrapper with 4 states:
- `AsyncData.notstarted()` — initial
- `AsyncData.loading()` — in progress
- `AsyncData.success(value)` — completed
- `AsyncData.error(message)` — failed

Used by `DashboardScreen._sessions` to render UI based on state.

---

## Complete Call Graph

```
main()
 └─ ResponderApp.build()
     └─ _AuthGate()
         ├─ initState() → _checkSession()
         │   └─ FlutterSecureStorage.read('jwt')
         └─ build()
             ├─ LoginScreen
             │   ├─ _login()
             │   │   ├─ ApiClient.login() → http POST /auth/login
             │   │   ├─ FlutterSecureStorage.write('jwt')
             │   │   ├─ FlutterSecureStorage.write('uid')
             │   │   └─ Navigator → /dashboard
             │   ├─ _guestLogin()
             │   │   ├─ FlutterSecureStorage.write('guest')
             │   │   └─ Navigator → /dashboard
             │   └─ Navigator → /signup
             │       └─ SignupScreen
             │           └─ _register()
             │               ├─ ApiClient.register() → http POST /auth/register
             │               ├─ FlutterSecureStorage.write('jwt')
             │               ├─ FlutterSecureStorage.write('uid')
             │               └─ Navigator → /dashboard
             │
             └─ DashboardScreen
                 ├─ _init()
                 │   ├─ FlutterSecureStorage.read('uid')
                 │   └─ _loadHistory()
                 │       └─ ApiClient.fetchSessions() → http GET /scans
                 ├─ _showRenameDialog()
                 │   ├─ LocalStorage.renameSession()
                 │   └─ _loadHistory()
                 ├─ _showDeleteDialog()
                 │   ├─ LocalStorage.deleteSession()
                 │   └─ _loadHistory()
                 ├─ _NetworkInfoCard._loadNetworkInfo()
                 │   ├─ Permission.location.request()
                 │   ├─ NetworkInfo.getWifiName()
                 │   ├─ NetworkInfo.getWifiGatewayIP()
                 │   ├─ NetworkInfo.getWifiIP()
                 │   └─ File('/proc/net/route').readAsLines()
                 ├─ Navigator → /form
                 │   └─ FormScreen
                 │       └─ Navigator → /scanning
                 │           └─ ScanningScreen
                 │               ├─ _init()
                 │               │   ├─ FlutterSecureStorage.read('uid')
                 │               │   ├─ _loadSessionDetail()
                 │               │   │   └─ ApiClient.fetchSessions()
                 │               │   └─ _startScan()
                 │               │       ├─ ScanRepositoryImpl.detectSubnet()
                 │               │       │   ├─ NetworkInfo.getWifiIP()
                 │               │       │   ├─ _readSubnetMask()
                 │               │       │   └─ _computeNetwork()
                 │               │       ├─ ScanRepositoryImpl.discoverDevices()
                 │               │       │   └─ _pingHost() per IP
                 │               │       │       ├─ Process.run('ping')
                 │               │       │       ├─ Socket.connect() fallback
                 │               │       │       └─ InternetAddress.lookup()
                 │               │       ├─ ScanRepositoryImpl.checkPorts() per device
                 │               │       │   ├─ Socket.connect() per port
                 │               │       │   ├─ _serviceMap lookup
                 │               │       │   └─ RiskLevel assignment
                 │               │       └─ _saveSession()
                 │               │           ├─ LocalStorage.saveSession()
                 │               │           └─ ApiClient.backupSession() → http POST /scans
                 │               └─ _onExportReportPressed()
                 │                   └─ Share.share()
                 └─ Logout
                     ├─ FlutterSecureStorage.deleteAll()
                     └─ Navigator → /login
```
