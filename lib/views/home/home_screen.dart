import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/product_provider.dart';
import '../shop/catalog_screen.dart';
import '../shop/collections_screen.dart';
import '../shop/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _values = [
    {
      'icon': LucideIcons.sparkles,
      'title': 'Artisanal Weaves',
      'subtitle': 'Handloomed & premium heritage fabrics',
    },
    {
      'icon': LucideIcons.scissors,
      'title': 'Made to Measure',
      'subtitle': 'Flawless custom fit tailored for you',
    },
    {
      'icon': LucideIcons.star,
      'title': 'Slow Fashion',
      'subtitle': 'Zero-waste design and conscious ethics',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _values.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'vamika & bhargavi',
          style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().loadCatalog(),
        color: AppColors.gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Hero Showcase Banner
              _buildHeroBanner(context),
              
              // 2. Minimalist Brand Value Divider Grid (Auto-sliding page-view)
              _buildBrandValues(),
              
              // 3. Shop Curated Collections
              _buildCollectionsCarousel(context),
              
              // 4. Bestsellers Shelf Showcase
              _buildBestsellersShelf(context),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF5A111C), // Rich Premium Maroon
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A111C).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'VAMIKA & BHARGAVI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 9.5).copyWith(
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Handcrafted Couture',
            style: AppTextStyles.serifHeading1(color: AppColors.cream).copyWith(
              fontSize: 28,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 1,
            color: AppColors.gold.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Exquisite silhouettes tailored to perfection, representing timeless heritage and modern craftsmanship.',
            style: AppTextStyles.sansBody(color: AppColors.cream.withOpacity(0.7), fontSize: 12).copyWith(
              height: 1.6,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              context.read<ProductProvider>().clearFilters();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CatalogScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.charcoal,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'EXPLORE COLLECTION',
              style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10, letterSpacing: 2.0).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandValues() {
    return Container(
      height: 92,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
        ),
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemCount: _values.length,
        itemBuilder: (context, index) {
          final item = _values[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: AppTextStyles.sansBody(fontSize: 14.5, fontWeight: FontWeight.bold).copyWith(
                          letterSpacing: 0.5,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: AppTextStyles.sansSubtitle().copyWith(
                          fontSize: 12,
                          color: AppColors.stone,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionsCarousel(BuildContext context) {
    final collections = context.watch<ProductProvider>().collections;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED CLOSETS',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'shop by collection',
                    style: AppTextStyles.serifHeading3(),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CollectionsScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW ALL',
                        style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 9.5, letterSpacing: 1.5).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 9.5, color: AppColors.stone),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: collections.length == 0 ? 3 : collections.length,
            itemBuilder: (context, index) {
              if (collections.length == 0) {
                return _buildCollectionShimmer();
              }
              final col = collections[index];
              return _buildCollectionCard(context, col, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, String collection, int index) {
    // Curated mock links representation
    final images = [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1608748010899-18f300247112?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=600&q=80'
    ];
    final imgUrl = images[index % images.length];

    return GestureDetector(
      onTap: () {
        context.read<ProductProvider>().clearFilters();
        context.read<ProductProvider>().applyFilters(collection: collection);
        // Toggle tab to catalog
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CatalogScreen(),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(imgUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.charcoal.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(12),
          child: Text(
            collection.toLowerCase(),
            style: AppTextStyles.serifBody(color: Colors.white, fontSize: 13).copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildBestsellersShelf(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final bestsellers = products.where((p) => p.isBestseller).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIGHLY COVETED',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'the bestsellers shelf',
                    style: AppTextStyles.serifHeading3(),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  context.read<ProductProvider>().clearFilters();
                  // Optionally apply bestsellers filter if wanted, or just go to Catalog
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW ALL',
                        style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 9.5, letterSpacing: 1.5).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 9.5, color: AppColors.stone),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: bestsellers.length == 0 ? 3 : bestsellers.length,
            itemBuilder: (context, index) {
              if (bestsellers.length == 0) {
                return _buildProductShimmer();
              }
              final product = bestsellers[index];
              return _buildProductCard(context, product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    final hasDiscount = product.discountPercent > 0;
    
    // Find dynamic pricing
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
        width: 155,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                Container(
                  height: 170,
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
            
            // Text Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Rs. ${salePrice.toInt().toString()}',
                        style: AppTextStyles.sansBody(
                          color: hasDiscount ? AppColors.error : AppColors.charcoal,
                          fontSize: 12,
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
}
