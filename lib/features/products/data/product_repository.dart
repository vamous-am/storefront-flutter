import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/product.dart';
import 'product_remote_datasource.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<List<String>> getCategories();

  Future<Product> getProductById(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts() {
    return _remoteDataSource.getProducts();
  }

  @override
  Future<List<String>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<Product> getProductById(int id) {
    return _remoteDataSource.getProductById(id);
  }
}

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSource(ref.read(apiClientProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.read(productRemoteDataSourceProvider));
});
