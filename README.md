# StoreFront App

A Flutter e-commerce app built against the [FakeStore API](https://fakestoreapi.com). Covers authentication, product browsing, cart management, and user profiles.

## Features

- **Auth** — JWT login via FakeStore API. Token and username persisted in SharedPreferences. Logout clears token, username, and cached profile.
- **Product list** — Product grid with search and category filter. Live cart badge in the app bar.
- **Product detail** — Full product info with an "Add to Cart" button and a snackbar shortcut to the cart screen.
- **Cart** — Add, remove, and update quantities. Totals computed in-memory; state persisted to SharedPreferences fire-and-forget. Clear-all with a confirmation dialog.
- **Profile** — Resolves the logged-in user by filtering `/users` client-side (FakeStore has no username lookup endpoint). Result cached in SharedPreferences and cleared on logout. Refresh button bypasses cache.

## Tech stack

| Concern | Choice |
|---|---|
| State management | `flutter_riverpod` 2.x (`Notifier` / `AsyncNotifier`) |
| Networking | `http` via a thin `ApiClient` wrapper |
| Local storage | `shared_preferences` |
| Image caching | `cached_network_image` |
| Linting | `flutter_lints` |
| Test mocking | `mocktail` |

## Project structure

```
lib/
├── core/
│   ├── constants/   # API base URL
│   ├── errors/      # Exception types
│   ├── network/     # ApiClient (http wrapper)
│   ├── theme/       # AppTheme (Material 3)
│   └── utils/       # Debouncer
├── features/
│   ├── auth/        # Login, AuthRepository, AuthLocalDataSource, AuthNotifier
│   ├── cart/        # CartLocalDataSource, CartRepository, CartNotifier, CartScreen
│   ├── products/    # ProductRepository, ProductsNotifier, ProductListScreen, ProductDetailScreen
│   └── profile/     # ProfileRepository, ProfileNotifier, ProfileScreen
├── models/          # Product, CartItem, User
├── widgets/         # EmptyState, ErrorState, LoadingIndicator, ProductImage
└── main.dart        # ProviderScope, route table, StoreFrontApp
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter SDK `^3.12.2`. No additional setup — the app hits the public FakeStore API with no API key.

## Routes

| Route | Screen |
|---|---|
| `/login` | LoginScreen |
| `/products` | ProductListScreen |
| `/product-detail` | ProductDetailScreen |
| `/cart` | CartScreen |
| `/profile` | ProfileScreen |
