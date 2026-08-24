import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/data/auth_repository.dart';
import '../../../models/cart_item.dart';
import '../data/cart_local_datasource.dart';
import '../data/cart_repository.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartLocalDataSourceProvider));
});

/// Synchronous cart state backed by SharedPreferences.
///
/// Loads from local storage in [build], then keeps an in-memory list as the
/// canonical state. Every mutation writes to prefs via a fire-and-forget
/// [_persist] call — the UI never awaits persistence and sees instant updates.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return ref.watch(cartRepositoryProvider).getCart();
  }

  /// Adds one unit of [item] to the cart. If the product already exists, its
  /// quantity is incremented; otherwise the item is appended.
  Future<void> addItem(CartItem item) async {
    final current = state;
    final existingIndex =
        current.indexWhere((e) => e.productId == item.productId);

    if (existingIndex >= 0) {
      final existing = current[existingIndex];
      state = [
        ...current.sublist(0, existingIndex),
        existing.copyWith(quantity: existing.quantity + item.quantity),
        ...current.sublist(existingIndex + 1),
      ];
    } else {
      state = [...current, item];
    }
    _persist();
  }

  /// Removes the item identified by [productId] entirely from the cart.
  Future<void> removeItem(int productId) async {
    state = state.where((e) => e.productId != productId).toList();
    _persist();
  }

  /// Sets the quantity of [productId] to [quantity].
  /// Quantity of zero or below removes the item.
  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(productId);
    }
    state = state.map((e) {
      return e.productId == productId ? e.copyWith(quantity: quantity) : e;
    }).toList();
    _persist();
  }

  /// Removes all items from the cart and clears SharedPreferences.
  Future<void> clearCart() async {
    state = [];
    await ref.read(cartRepositoryProvider).clearCart();
  }

  /// Returns the total price of all items in the cart.
  double get total => state.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Returns the total number of individual units across all cart items.
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);

  // Writes the current in-memory state to SharedPreferences.
  // Fire-and-forget: the UI does not await this.
  void _persist() {
    ref
        .read(cartLocalDataSourceProvider)
        .saveCartItems(state)
        .ignore(); // intentional fire-and-forget
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
