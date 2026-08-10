import '../../../models/cart_item.dart';
import 'cart_local_datasource.dart';

abstract class CartRepository {
  List<CartItem> getCart();
  Future<void> addItem(CartItem item);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  @override
  List<CartItem> getCart() => _localDataSource.getCartItems();

  @override
  Future<void> addItem(CartItem item) async {
    final current = _localDataSource.getCartItems();
    final existing = current.firstWhere(
      (e) => e.productId == item.productId,
      orElse: () => CartItem(productId: -1, title: '', price: 0, image: '', quantity: 0),
    );
    if (existing.productId != -1) {
      // increment quantity
      final updated = existing.copyWith(quantity: existing.quantity + item.quantity);
      final newList = current.map((e) => e.productId == existing.productId ? updated : e).toList();
      await _localDataSource.saveCartItems(newList);
    } else {
      final newList = List<CartItem>.from(current)..add(item);
      await _localDataSource.saveCartItems(newList);
    }
  }

  @override
  Future<void> removeItem(int productId) async {
    final newList = _localDataSource.getCartItems().where((e) => e.productId != productId).toList();
    await _localDataSource.saveCartItems(newList);
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(productId);
    }
    final current = _localDataSource.getCartItems();
    final newList = current.map((e) {
      if (e.productId == productId) {
        return e.copyWith(quantity: quantity);
      }
      return e;
    }).toList();
    await _localDataSource.saveCartItems(newList);
  }

  @override
  Future<void> clearCart() async => _localDataSource.clearCart();
}

