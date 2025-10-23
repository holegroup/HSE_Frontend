# Automatic Server Detection - HSE Application

## Overview
Your HSE app now automatically detects which backend server is available and uses it intelligently!

## How It Works

### 🔍 Smart Detection Process

When you try to login, the app:

1. **Checks Production Server First** (`https://hsebackend.myhsebuddy.com`)
   - Timeout: 3 seconds
   - If available ✅ → Uses production server
   - If not available ⚠️ → Continues to step 2

2. **Checks Local Server** (`http://localhost:5000`)
   - Timeout: 2 seconds  
   - If available ✅ → Uses local server
   - If not available ⚠️ → Defaults to production

3. **Caches the Result**
   - Remembers which server worked
   - Uses cached server for subsequent requests
   - No need to check again until app restart

### 📊 Decision Logic

```
┌─────────────────────────────────────┐
│   User Clicks "Login"               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Try Production Server             │
│   https://hsebackend.myhsebuddy.com │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────┐
        │             │
    Success ✅     Failed ❌
        │             │
        │             ▼
        │   ┌─────────────────────┐
        │   │  Try Local Server   │
        │   │  http://localhost   │
        │   └─────────┬───────────┘
        │             │
        │      ┌──────┴──────┐
        │      │             │
        │  Success ✅     Failed ❌
        │      │             │
        └──────┴─────────────┴──────►
                     │
                     ▼
            ┌────────────────┐
            │  Use Server    │
            │  & Cache It    │
            └────────────────┘
```

## Usage Scenarios

### Scenario 1: Production Server is Live ✅
```
🔍 Detecting available server...
✅ Production server is available: https://hsebackend.myhsebuddy.com
📡 Using server: https://hsebackend.myhsebuddy.com
✅ Login successful!
```
**Result:** Uses production server (fastest)

### Scenario 2: Only Local Server Running 💻
```
🔍 Detecting available server...
⚠️ Production server not available: Connection timeout
✅ Local server is available: http://localhost:5000
📡 Using server: http://localhost:5000
✅ Login successful!
```
**Result:** Uses local server (for development)

### Scenario 3: Both Servers Available 🌐
```
🔍 Detecting available server...
✅ Production server is available: https://hsebackend.myhsebuddy.com
📡 Using server: https://hsebackend.myhsebuddy.com
✅ Login successful!
```
**Result:** Prefers production (checked first)

### Scenario 4: No Server Available ❌
```
🔍 Detecting available server...
⚠️ Production server not available: Connection timeout
⚠️ Local server not available: Connection refused
⚠️ No server detected, defaulting to production
❌ Connection Failed: Cannot connect to any server
```
**Result:** Shows error message

## Benefits

### ✅ For You (Developer)
- **No manual configuration needed**
- Work with local backend when developing
- Automatically uses production when local isn't running
- No need to change code between environments

### ✅ For Users
- **Always connects to the best available server**
- Faster connection (tries production first)
- Seamless experience
- No configuration required

### ✅ For Testing
- **Test locally** → Just start local backend
- **Test production** → Don't start local backend
- **Test both** → App automatically picks the best one

## Console Output

When you login, check the browser console (F12) to see which server is being used:

```javascript
🔍 Detecting available server...
✅ Production server is available: https://hsebackend.myhsebuddy.com
📡 Using server: https://hsebackend.myhsebuddy.com
Response status: 200
Response body: {"success":true,"user":{...},"token":"..."}
```

## Manual Server Reset

If you want to force re-detection (e.g., you just started local server):

```dart
// In your Dart code or debug console
Constants.resetServerDetection();
```

Then try logging in again - it will re-detect available servers.

## Configuration

### Production Server
- **URL:** `https://hsebackend.myhsebuddy.com`
- **Priority:** First (checked first)
- **Timeout:** 3 seconds

### Local Server
- **URL:** `http://localhost:5000` (web/desktop/iOS)
- **URL:** `http://10.0.2.2:5000` (Android emulator)
- **Priority:** Second (fallback)
- **Timeout:** 2 seconds

## Development Workflow

### Working with Local Backend
```bash
# Terminal 1: Start local backend
cd c:\Users\imran\Documents\GitHub\HSE_Backend
node index.js

# Terminal 2: Run Flutter app
cd c:\Users\imran\Documents\GitHub\HSE_Frontend
flutter run -d chrome
```

**Result:** App detects local server is available and uses it

### Working with Production Backend
```bash
# Just run Flutter app (don't start local backend)
cd c:\Users\imran\Documents\GitHub\HSE_Frontend
flutter run -d chrome
```

**Result:** App detects production server and uses it

## Release Builds (APK)

For release builds, the app **always uses production server** regardless of detection:

```bash
flutter build apk --release
```

**Result:** APK always connects to `https://hsebackend.myhsebuddy.com`

## Troubleshooting

### App keeps using wrong server?

**Solution:** Clear the detection cache
```dart
Constants.resetServerDetection();
```

### Want to force local server?

**Option 1:** Stop production server (not practical)

**Option 2:** Modify detection order in `lib/config/env.dart`:
```dart
// Try local server first instead of production
// Swap the order in detectAvailableServer() method
```

### Want to force production server?

**Option 3:** Don't start local backend - app will automatically use production

## Files Modified

- ✅ `lib/config/env.dart` - Added auto-detection logic
- ✅ `lib/controllers/login_controller.dart` - Uses auto-detection

## Summary

🎯 **The app is now smart!**
- Tries production first (fastest for most users)
- Falls back to localhost if production unavailable
- Caches the result for better performance
- No manual configuration needed
- Works seamlessly in all scenarios

Just start whichever backend you want to use, and the app will find it automatically! 🚀
