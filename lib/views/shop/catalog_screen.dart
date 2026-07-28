import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/product_provider.dart';
import 'detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<ProductProvider>().applyFilters(search: _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'catalog',
          style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.sliders, color: AppColors.charcoal, size: 20),
            onPressed: () => _showFilterDrawer(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Elegant Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search designer wear, collections...',
                hintStyle: AppTextStyles.sansSubtitle(),
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.stone),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.goldLight.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          
          // Active filter badges
          if (provider.selectedCategory.isNotEmpty ||
              provider.selectedCollection.isNotEmpty ||
              provider.selectedSort.isNotEmpty)
            _buildActiveFilters(context, provider),

          // Catalog Grid
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : products.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildCatalogCard(context, product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, ProductProvider provider) {
    List<Widget> badges = [];

    if (provider.selectedCategory.isNotEmpty) {
      badges.add(_buildFilterChip(provider.selectedCategory, () {
        provider.applyFilters(category: '');
      }));
    }
    if (provider.selectedCollection.isNotEmpty) {
      badges.add(_buildFilterChip(provider.selectedCollection, () {
        provider.applyFilters(collection: '');
      }));
    }


    if (provider.selectedSort.isNotEmpty) {
      final sortName = provider.selectedSort == 'price_low_to_high' ? 'Price: L-H' : 'Price: H-L';
      badges.add(_buildFilterChip(sortName, () {
        provider.applyFilters(sort: '');
      }));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Filters:',
              style: AppTextStyles.sansSubtitle().copyWith(fontSize: 11),
            ),
            const SizedBox(width: 8),
            ...badges.map((widget) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: widget,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(
        label.toLowerCase(),
        style: const TextStyle(fontSize: 10, color: AppColors.charcoal, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.goldLight.withOpacity(0.5),
      deleteIconColor: AppColors.charcoal,
      deleteIcon: const Icon(Icons.close, size: 10),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.frown, color: AppColors.gold, size: 48),
          const SizedBox(height: 16),
          Text(
            'No apparel matches found',
            style: AppTextStyles.serifHeading3(),
          ),
          const SizedBox(height: 8),
          Text(
            'Try altering your search or filters.',
            style: AppTextStyles.sansSubtitle(),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context, dynamic product) {
    final hasDiscount = product.discountPercent > 0;
    final double basePrice = product.variants.isNotEmpty ? product.variants[0].price : 0.0;
    final double salePrice = hasDiscount 
        ? basePrice * (1 - product.discountPercent / 100) 
        : basePrice;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(product: product),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(product.images.isNotEmpty ? product.images[0] : 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppColors.error,
                        child: Text(
                          '${product.discountPercent.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Text Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.sansBody(fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category.toUpperCase(),
                    style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 8),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs. ${salePrice.toInt().toString()}',
                        style: AppTextStyles.sansBody(
                          color: hasDiscount ? AppColors.error : AppColors.charcoal,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${basePrice.toInt().toString()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const FilterBottomSheet();
      },
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = provider.categories;
    final collections = provider.collections;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: AppTextStyles.serifHeading3(),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CLEAR ALL',
                      style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 1. Sort Options
              Text(
                'SORT BY PRICE',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Default'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: provider.selectedSort.isEmpty ? Colors.white : AppColors.charcoal,
                      fontWeight: provider.selectedSort.isEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                    selected: provider.selectedSort.isEmpty,
                    selectedColor: AppColors.charcoal,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: AppColors.goldLight.withOpacity(0.5)),
                    ),
                    onSelected: (selected) {
                      if (selected) provider.applyFilters(sort: '');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Low to High'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: provider.selectedSort == 'price_low_to_high' ? Colors.white : AppColors.charcoal,
                      fontWeight: provider.selectedSort == 'price_low_to_high' ? FontWeight.bold : FontWeight.normal,
                    ),
                    selected: provider.selectedSort == 'price_low_to_high',
                    selectedColor: AppColors.charcoal,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: AppColors.goldLight.withOpacity(0.5)),
                    ),
                    onSelected: (selected) {
                      if (selected) provider.applyFilters(sort: 'price_low_to_high');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('High to Low'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: provider.selectedSort == 'price_high_to_low' ? Colors.white : AppColors.charcoal,
                      fontWeight: provider.selectedSort == 'price_high_to_low' ? FontWeight.bold : FontWeight.normal,
                    ),
                    selected: provider.selectedSort == 'price_high_to_low',
                    selectedColor: AppColors.charcoal,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: AppColors.goldLight.withOpacity(0.5)),
                    ),
                    onSelected: (selected) {
                      if (selected) provider.applyFilters(sort: 'price_high_to_low');
                    },
                  ),
                ],
              ),

              
              // 4. Categories Dropdown
              Text(
                'CATEGORY',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedCategory.isEmpty ? 'all' : provider.selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.charcoal),
                    style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.charcoal),
                    dropdownColor: Colors.white,
                    onChanged: (value) {
                      provider.applyFilters(category: value == 'all' ? '' : value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Categories', style: AppTextStyles.sansSubtitle()),
                      ),
                      ...categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Collections Dropdown
              Text(
                'COLLECTION',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedCollection.isEmpty ? 'all' : provider.selectedCollection,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.charcoal),
                    style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.charcoal),
                    dropdownColor: Colors.white,
                    onChanged: (value) {
                      provider.applyFilters(collection: value == 'all' ? '' : value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Collections', style: AppTextStyles.sansSubtitle()),
                      ),
                      ...collections.map((col) => DropdownMenuItem(
                            value: col,
                            child: Text(col),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    elevation: 0,
                  ),
                  child: Text(
                    'APPLY FILTERS',
                    style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
