import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'products_provider.dart';

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesState.when(
      data: (categories) {
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final categoryName = isAll ? 'All' : categories[index - 1];
              // Capitalize first letter of each word/category name for premium presentation
              final displayTitle = categoryName.split(' ').map((word) {
                if (word.isEmpty) return '';
                return word[0].toUpperCase() + word.substring(1);
              }).join(' ');

              final isSelected = isAll 
                  ? selectedCategory == null 
                  : selectedCategory?.toLowerCase() == categoryName.toLowerCase();

              return ChoiceChip(
                label: Text(displayTitle),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedCategoryProvider.notifier).state = isAll ? null : categoryName;
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(), // Silently hide or show minimal error if categories fail
    );
  }
}

