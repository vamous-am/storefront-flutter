import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../data/product_repository.dart';

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productRepositoryProvider).getProductById(id);
});
