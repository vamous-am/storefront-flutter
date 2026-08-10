import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../auth/presentation/auth_provider.dart';
import 'category_filter.dart';
import 'product_card.dart';
import 'products_provider.dart';
import 'search_field.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsState = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isFiltered = searchQuery.isNotEmpty || selectedCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Front'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchField(),
          ),
          const CategoryFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: filteredProductsState.when(
              loading: () => const LoadingIndicator(message: 'Loading products...'),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.read(productsProvider.notifier).refresh(),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return EmptyState(
                    message: isFiltered
                        ? 'No products match your search or filter criteria.'
                        : 'No products available.',
                    actionLabel: isFiltered ? 'Clear Filters' : null,
                    onAction: isFiltered
                        ? () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          }
                        : null,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/product-detail',
                              arguments: product.id,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

