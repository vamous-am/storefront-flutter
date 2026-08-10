import 'package:fake_store_app/features/products/data/product_repository.dart';
import 'package:fake_store_app/features/products/presentation/products_provider.dart';
import 'package:fake_store_app/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late ProviderContainer container;

  final tProducts = [
    const Product(
      id: 1,
      title: 'Fjallraven Backpack',
      price: 109.95,
      description: 'Forest backpack.',
      category: "men's clothing",
      image: 'img1.jpg',
    ),
    const Product(
      id: 2,
      title: 'Slim Fit T-Shirt',
      price: 22.3,
      description: 'Raglan sleeve.',
      category: "men's clothing",
      image: 'img2.jpg',
    ),
    const Product(
      id: 3,
      title: 'Solid Gold Petite Ring',
      price: 168.0,
      description: 'Jewelry ring.',
      category: 'jewelery',
      image: 'img3.jpg',
    ),
  ];

  final tCategories = ["electronics", "jewelery", "men's clothing", "women's clothing"];

  setUp(() {
    mockRepository = MockProductRepository();
    when(() => mockRepository.getProducts()).thenAnswer((_) async => tProducts);
    when(() => mockRepository.getCategories()).thenAnswer((_) async => tCategories);

    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('productsProvider should fetch and expose products', () async {
    // Starts as loading
    expect(container.read(productsProvider), const AsyncValue<List<Product>>.loading());

    // Wait for the future to resolve
    await container.read(productsProvider.future);

    expect(container.read(productsProvider).value, equals(tProducts));
  });

  test('categoriesProvider should fetch and expose categories', () async {
    expect(container.read(categoriesProvider), const AsyncValue<List<String>>.loading());

    await container.read(categoriesProvider.future);

    expect(container.read(categoriesProvider).value, equals(tCategories));
  });

  test('filteredProductsProvider should initially return all products', () async {
    await container.read(productsProvider.future);

    final filtered = container.read(filteredProductsProvider);
    expect(filtered.value, equals(tProducts));
  });

  test('filteredProductsProvider should filter by search query (case-insensitive)', () async {
    await container.read(productsProvider.future);

    // Filter by "backpack"
    container.read(searchQueryProvider.notifier).state = 'backpack';
    expect(container.read(filteredProductsProvider).value, [tProducts[0]]);

    // Filter by "FIT" (case-insensitive)
    container.read(searchQueryProvider.notifier).state = 'FIT';
    expect(container.read(filteredProductsProvider).value, [tProducts[1]]);
  });

  test('filteredProductsProvider should filter by category', () async {
    await container.read(productsProvider.future);

    // Filter by jewelery
    container.read(selectedCategoryProvider.notifier).state = 'jewelery';
    expect(container.read(filteredProductsProvider).value, [tProducts[2]]);

    // Filter by non-existent category
    container.read(selectedCategoryProvider.notifier).state = 'electronics';
    expect(container.read(filteredProductsProvider).value, isEmpty);
  });

  test('filteredProductsProvider should combine search query and category filters', () async {
    await container.read(productsProvider.future);

    // Filter by category: men's clothing AND query: T-Shirt
    container.read(selectedCategoryProvider.notifier).state = "men's clothing";
    container.read(searchQueryProvider.notifier).state = 't-shirt';
    expect(container.read(filteredProductsProvider).value, [tProducts[1]]);

    // If query does not match inside category
    container.read(searchQueryProvider.notifier).state = 'gold';
    expect(container.read(filteredProductsProvider).value, isEmpty);
  });
}
