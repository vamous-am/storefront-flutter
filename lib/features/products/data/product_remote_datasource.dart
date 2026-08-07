import '../../../core/network/api_client.dart';
import '../../../models/product.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> getProducts() async {
    final data = await _apiClient.getJsonList('/products');
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getCategories() async {
    final data = await _apiClient.getJsonList('/products/categories');
    return data.map((item) => item.toString()).toList();
  }

  Future<Product> getProductById(int id) async {
    final data = await _apiClient.getJsonMap('/products/$id');
    return Product.fromJson(data);
  }
}
