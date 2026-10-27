# Merchant App Build Plan

## Goal
Build a merchant-side experience that reuses the existing architecture (Provider + go_router + http service layer). When a user with `role: merchant` logs in (or is already logged in via splash), route them to a dedicated merchant navigation instead of the customer one.

## 1. Role-based routing
- `AppRoute`: add `merchantNav`, `merchantDashboard` (optional), `merchantProducts`, `merchantCategory`, `merchantOrders`, `merchantRestaurant`.
- `app_router.dart`: register merchant routes (most as a shell via `MerchantMainNav` with IndexedStack; detail/product/category forms as sub-routes).
- `login_screen.dart`: after successful login, branch on `authProvider.user?.role` -> `merchant` -> `AppRoute.merchantNav`, else `AppRoute.mianNav`.
- `splash_screen.dart`: same branch on `role` when token exists.

## 2. Models (`lib/models/merchant/`)
- `merchant_restaurant.dart` — id, name, address, logo, deliveryTime, rating, owner.
- `merchant_category.dart` — id, name, image, restaurantId.
- `merchant_product.dart` — id, name, price, description, image, isAvailable, categoryId, restaurantId.
- `merchant_order.dart` — id, customer, items, total, status, createdAt.

## 3. Service (`lib/services/merchant_service.dart`)
- `getRestaurant(token)`, `getCategories(token)`, `getProducts(token)`, `getOrders(token)`.
- `create/update/delete` for category, product, restaurant.
- `updateOrderStatus(token, id, status)`.
- All use `Bearer $token`, `${ApiUrl.baseUrl}/merchant/...`, parse `body['data']`.

## 4. Provider (`lib/providers/merchant_provider.dart`)
- Loads restaurant + categories + products + orders; CRUD methods; loading/message state.

## 5. Screens (`lib/screens/merchant/`)
- `merchant_main_nav.dart` — bottom nav: Dashboard, Products, Categories, Orders (IndexedStack).
- `dashboard_screen.dart` — greeting, restaurant summary, quick stats (products count, orders count, pending), quick actions.
- `restaurant_screen.dart` — view/edit own restaurant (name, address, logo, delivery time).
- `products_screen.dart` — list products with availability toggle + add/edit/delete (Form dialog/screen).
- `categories_screen.dart` — list categories (add/edit/delete).
- `orders_screen.dart` — list orders with status filter + update status (pending/accepted/completed/cancelled).
- `product_form_screen.dart` / `category_form_screen.dart` — reusable create/edit forms.

## 6. Reused assets
- `AppColors.primary` (#FF6B00), `AppButton`, `AppTextField`, `CachedImage`, `CustomAppBar`.

## Verification
- `flutter analyze` (if allowed) on new files; manual review against existing patterns.
