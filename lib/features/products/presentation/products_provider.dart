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

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).getCategories();
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsState = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return productsState.whenData((products) {
    return products.where((p) {
      final matchesCategory = category == null || p.category.toLowerCase() == category.toLowerCase();
      final matchesQuery = query.isEmpty || p.title.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});

