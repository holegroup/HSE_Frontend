# API Configuration Guide

## 🚀 Quick Setup

Your Flutter app is now configured to use the live backend URL: **https://hsebackend.myhsebuddy.com/**

## 🔧 How to Switch Between Local and Live Backend

### Method 1: Simple Toggle (Recommended)

In `lib/config/env.dart`, change this line:

```dart
static const bool useProductionServer = true; // Set to false for local development
```

- **`true`** = Use live backend (https://hsebackend.myhsebuddy.com/)
- **`false`** = Use local backend (http://localhost:5000)

### Method 2: Advanced Configuration

Use `lib/config/app_config.dart` for more control:

```dart
// Change this line to switch environments
static Environment _environment = Environment.production;
```

Available environments:
- `Environment.development` - Local development server
- `Environment.staging` - Staging server  
- `Environment.production` - Live production server

## 📱 Platform-Specific URLs

When using local development (`useProductionServer = false`):

- **Web**: `http://localhost:5000`
- **Android Emulator**: `http://10.0.2.2:5000`
- **Android Physical Device**: Update IP in code to your computer's IP
- **iOS Simulator**: `http://localhost:5000`
- **Desktop**: `http://localhost:5000`

## 🔍 Testing API Connection

### Option 1: Use Built-in API Test
```dart
import 'package:hole_hse_inspection/config/api_test.dart';

// In your widget
ApiConnectionTest.showTestResults(context);
```

### Option 2: Use Environment Switcher Widget
```dart
import 'package:hole_hse_inspection/widgets/environment_switcher.dart';

// Add to your debug screen
EnvironmentSwitcher()
```

## 📡 Available API Endpoints

Base URL: `https://hsebackend.myhsebuddy.com`

### Health & Info
- `GET /` - Server status
- `GET /api/health` - Health check
- `GET /api` - API information

### Authentication
- `POST /api/users/login` - User login
- `GET /api/users/validate-super-admin` - Validate admin

### Core Features  
- `GET /api/tasks/*` - Task management
- `GET /api/sites/*` - Site management
- `GET /api/products/*` - Product management
- `GET /api/forms/*` - Form management
- `GET /api/sse/*` - Real-time updates

## 🛠️ Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if backend server is running
   - Verify URL is correct
   - Check network connectivity

2. **CORS Errors (Web)**
   - Backend should allow your domain
   - Check browser console for details

3. **Android Emulator Issues**
   - Use `10.0.2.2:5000` instead of `localhost:5000`
   - For physical device, use your computer's IP address

4. **Timeout Errors**
   - Increase timeout in `app_config.dart`
   - Check server response time

### Debug Steps

1. **Test Health Endpoint**
   ```
   GET https://hsebackend.myhsebuddy.com/api/health
   ```

2. **Check Current Configuration**
   ```dart
   print('Base URL: ${Constants.baseUrl}');
   print('Environment: ${AppConfig.environment}');
   ```

3. **Use API Test Tool**
   - Run the built-in API connection test
   - Check which endpoints are failing

## 🔄 Fallback URLs

The app automatically tries these URLs in order:
1. `https://hsebackend.myhsebuddy.com` (Primary)
2. `https://inspection-app-backend.onrender.com` (Fallback)
3. `https://hse-api.onrender.com` (Secondary fallback)

## 📝 Configuration Files

- `lib/config/env.dart` - Simple environment configuration
- `lib/config/app_config.dart` - Advanced configuration system
- `lib/config/api_test.dart` - API testing utilities
- `lib/widgets/environment_switcher.dart` - Debug environment switcher

## 🚨 Important Notes

1. **Always test both local and live environments** before deploying
2. **Set `useProductionServer = true`** for production builds
3. **Update IP addresses** for physical device testing
4. **Check CORS settings** on the backend for web deployment
5. **Monitor API response times** and adjust timeouts as needed
