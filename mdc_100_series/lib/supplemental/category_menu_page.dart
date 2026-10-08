import 'package:flutter/material.dart';
import '../model/product.dart';

class CategoryMenuPage extends StatelessWidget {
  final Category currentCategory;
  final ValueChanged<Category> onCategoryTap;

  // Grab all the available categories from our product model enum
  final List<Category> _categories = Category.values;

  const CategoryMenuPage({
    Key? key,
    required this.currentCategory,
    required this.onCategoryTap,
  }) : super(key: key);

  // Helper method to build each category item in the menu list
  Widget _buildCategory(Category category, BuildContext context) {
    // Format the enum value (e.g. "Category.clothing" becomes "CLOTHING")
    final categoryString =
        category.toString().replaceAll('Category.', '').toUpperCase();
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onCategoryTap(category),
      child: category == currentCategory
          ? Column(
              children: <Widget>[
                const SizedBox(height: 16.0),
                Text(
                  categoryString,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14.0),
                // An underline indicator for the currently selected category
                Container(
                  width: 70.0,
                  height: 2.0,
                  color: theme.colorScheme.primary, // Shrine Pink
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                categoryString,
                style: theme.textTheme.bodyLarge?.copyWith(
                  // Dim the text if it's not the currently selected category
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 40.0),
        // We use a dark color for the back layer menu background
        color: Theme.of(context).colorScheme.secondary,
        child: ListView(
          children: _categories
              .map((Category c) => _buildCategory(c, context))
              .toList(),
        ),
      ),
    );
  }
}