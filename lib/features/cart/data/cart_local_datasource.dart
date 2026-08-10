import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/cart_item.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const _cartKey = 'cart_items';

  List<CartItem> getCartItems() {
    final jsonString = _preferences.getString(_cartKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await _preferences.setString(_cartKey, jsonString);
  }

  Future<void> clearCart() async {
    await _preferences.remove(_cartKey);
  }
}

