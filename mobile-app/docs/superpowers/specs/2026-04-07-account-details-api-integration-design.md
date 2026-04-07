# Account Details API Integration

## Summary

Integrate the `/v1/user/account-details` API to fetch fresh user account data. The API is called after login, after registration, on app resume (session validation), and when the profile tab is opened. All data flows through `AuthProvider` and updates the existing `UserModel`.

## API Response

```
GET /v1/user/account-details
Authorization: Bearer <token>

Response:
{
  "statusCode": 200,
  "message": "Success",
  "message_ar": "...",
  "data": {
    "phone": "+917003718069",
    "email": null,
    "wallets": [],
    "walletsAvailable": false,
    "isVerified": false
  }
}
```

## Changes

### 1. `lib/core/constants/endpoints.dart`

Add endpoint:
```dart
static String get accountDetails => '$apiVersion/user/account-details';
```

### 2. `lib/core/models/user_model/user_model.dart`

Add three fields to the Freezed model:
```dart
@Default('') String email,
@Default([]) List<String> wallets,
@Default(false) bool walletsAvailable,
```

Run `./scripts/gen_models.sh` after modification.

### 3. `lib/providers/auth_provider.dart`

Add `fetchAccountDetails()` method:
- Calls `ApiHelper.get(Endpoints.accountDetails)`
- Extracts `data` map from response
- Updates the current `UserModel` via `copyWith` with: `email`, `isVerified`, `wallets`, `walletsAvailable`
- Persists updated user JSON to storage (`AppConstants.userKey`)
- Calls `notifyListeners()`
- Wrapped in try/catch — fails silently (best-effort refresh, no UI error state)
- Early-returns if user is not authenticated

### 4. `lib/providers/global_provider.dart`

- Accept `AuthProvider` reference so `fetchAccountDetails()` can be called
- In `onAuthChanged(true)`, call `authProvider.fetchAccountDetails()` alongside the existing currency fetch
- The `AuthProvider` reference comes from updating the `ChangeNotifierProxyProvider` wiring in `main.dart`

### 5. `lib/main.dart`

Update the `GlobalProvider` proxy provider to pass `AuthProvider`:
```dart
ChangeNotifierProxyProvider<AuthProvider, GlobalProvider>(
  create: (_) => GlobalProvider(),
  update: (_, auth, global) => (global ?? GlobalProvider())
    ..updateAuthProvider(auth)
    ..onAuthChanged(auth.state.isAuthenticated),
),
```

### 6. `lib/modules/splash/splash_view.dart`

After `validateSession()` returns true, call `authProvider.fetchAccountDetails()` to refresh user data on app resume.

### 7. `lib/modules/dashboard/profile/profile_view.dart`

Trigger `fetchAccountDetails()` when the profile tab is shown. Use a `StatefulWidget` wrapper or `addPostFrameCallback` to call it once per visit. Convert to `StatefulWidget` only for this lifecycle need (consistent with project rules — StatefulWidget allowed for unavoidable local widget lifecycle needs).

## Trigger Matrix

| Trigger                  | Where                        | How                                              |
|--------------------------|------------------------------|--------------------------------------------------|
| Login                    | `GlobalProvider.onAuthChanged` | Called automatically when AuthProvider notifies  |
| Registration (then login)| Same as login                | Registration ends with login call                |
| App open / resume        | `splash_view.dart`           | After `validateSession()` succeeds               |
| Profile tab opened       | `profile_view.dart`          | `addPostFrameCallback` on build                  |

## Not Changing

- No new provider, service, or model class
- No UI changes (the fetched data updates existing watched state)
- Account details screen (`account_details_view.dart`) is not modified — it already reads from `AuthProvider.state.user`
