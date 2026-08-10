import 'package:fake_store_app/features/products/data/product_remote_datasource.dart';
import 'package:fake_store_app/features/products/data/product_repository.dart';
import 'package:fake_store_app/models/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}

void main() {
  late MockProductRemoteDataSource mockRemoteDataSource;
  late ProductRepositoryImpl productRepository;

  final tProducts = [
    const Product(
      id: 1,
      title: 'Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops',
      price: 109.95,
      description: 'Your perfect pack for everyday use and walks in the forest.',
      category: "men's clothing",
      image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
    ),
    const Product(
      id: 2,
      title: 'Mens Casual Premium Slim Fit T-Shirts',
      price: 22.3,
      description: 'Slim-fitting style, contrast raglan long sleeve.',
      category: "men's clothing",
      image: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
    ),
  ];

  final tCategories = ["electronics", "jewelery", "men's clothing", "women's clothing"];

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    productRepository = ProductRepositoryImpl(mockRemoteDataSource);
  });

  group('getProducts', () {
    test('should return list of products from remote data source', () async {
      when(() => mockRemoteDataSource.getProducts()).thenAnswer((_) async => tProducts);

      final result = await productRepository.getProducts();

      expect(result, equals(tProducts));
      verify(() => mockRemoteDataSource.getProducts()).called(1);
    });
  });

  group('getCategories', () {
    test('should return list of categories from remote data source', () async {
      when(() => mockRemoteDataSource.getCategories()).thenAnswer((_) async => tCategories);

      final result = await productRepository.getCategories();

      expect(result, equals(tCategories));
      verify(() => mockRemoteDataSource.getCategories()).called(1);
    });
  });

  group('getProductById', () {
    test('should return a specific product by ID from remote data source', () async {
      final tProduct = tProducts.first;
      when(() => mockRemoteDataSource.getProductById(1)).thenAnswer((_) async => tProduct);

      final result = await productRepository.getProductById(1);

      expect(result, equals(tProduct));
      verify(() => mockRemoteDataSource.getProductById(1)).called(1);
    });
  });
}
