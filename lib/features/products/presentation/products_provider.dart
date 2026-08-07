import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../data/product_repository.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  FutureOr<List<Product>> build() {
    return ref.watch(productRepositoryProvider).getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(productRepositoryProvider).getProducts();
    });
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);
