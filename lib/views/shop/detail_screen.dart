import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _activeImageIndex = 0;
  String? _selectedTopSize;
  String? _selectedBottomSize;
  int _selectedQuantity = 1;
  late PageController _pageController;
  
  // Holds mapping of optionName to selected value option
  final Map<String, ProductOption> _selectedOptionsMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // Dynamic default selection from available variants top sizes
    final topSizes = widget.product.variants
        .map((v) => v.topSize)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    _selectedTopSize = topSizes.isNotEmpty ? topSizes[0] : 'M';

    if (widget.product.isSet) {
      final bottomSizes = widget.product.variants
          .map((v) => v.bottomSize)
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      _selectedBottomSize = bottomSizes.isNotEmpty ? bottomSizes[0] : 'M';
    }

    // Default select the first value for each options group
    final optionGroups = <String, List<ProductOption>>{};
    for (var opt in widget.product.options) {
      optionGroups.putIfAbsent(opt.optionName, () => []).add(opt);
    }

    optionGroups.forEach((groupName, optsList) {
      if (optsList.isNotEmpty) {
        _selectedOptionsMap[groupName] = optsList[0];
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _currentPrice {
    final hasDiscount = widget.product.discountPercent > 0;
    
    // 1. Get base variant price
    double price = widget.product.variants.isNotEmpty 
        ? widget.product.variants[0].price 
        : 0.0;

    // Apply seller discount to base price
    if (hasDiscount) {
      price = price * (1 - widget.product.discountPercent / 100);
    }

    // 2. Add options price adjustments
    double adjustments = 0.0;
    _selectedOptionsMap.values.forEach((opt) {
      adjustments += opt.priceAdjustment;
    });

    return price + adjustments;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images.isNotEmpty ? product.images : ['https://via.placeholder.com/400'];
    final optionGroups = <String, List<ProductOption>>{};
    for (var opt in product.options) {
      optionGroups.putIfAbsent(opt.optionName, () => []).add(opt);
    }

    // Extract unique top sizes from available variants dynamically from database
    final List<String> topSizes = product.variants
        .map((v) => v.topSize)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (topSizes.isEmpty) {
      topSizes.addAll(['XS', 'S', 'M', 'L', 'XL']);
    }

    // Extract unique bottom sizes from available variants dynamically from database
    final List<String> bottomSizes = product.variants
        .map((v) => v.bottomSize)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    if (bottomSizes.isEmpty) {
      bottomSizes.addAll(['XS', 'S', 'M', 'L', 'XL']);
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // Elegant Header Image Banner
          SliverAppBar(
            expandedHeight: 480,
            pinned: true,
            backgroundColor: AppColors.cream,
            elevation: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _activeImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  
                  // Active page indicator dots
                  if (images.length > 1)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _activeImageIndex == index
                                  ? AppColors.gold
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Details Card
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Thumbnail List
                  if (images.length > 1) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 64,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final img = images[index];
                          final isSelected = _activeImageIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeImageIndex = index;
                              });
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 48,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppColors.gold : const Color(0xFFFAF5EC),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  // Collection Label & Discount Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 10),
                      ),
                      if (product.discountPercent > 0)
                        Container(
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Product Title
                  Text(
                    product.title,
                    style: AppTextStyles.serifHeading2(),
                  ),
                  
                  // Seller Details
                  if (product.sellerShopName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'by ${product.sellerShopName}',
                      style: AppTextStyles.sansSubtitle(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Price breakdown
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rs. ${_currentPrice.toInt().toString()}',
                        style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(Inclusive of taxes)',
                        style: AppTextStyles.sansSubtitle().copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Size Selector Row with Size Chart Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.isSet ? 'SELECT TOP SIZE' : 'SELECT SIZE',
                        style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
                      ),
                      GestureDetector(
                        onTap: () => _showSizeChart(context),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.ruler, size: 12, color: AppColors.goldDark),
                            const SizedBox(width: 4),
                            Text(
                              'SIZE CHART',
                              style: AppTextStyles.uppercaseLabel(color: AppColors.goldDark, fontSize: 9.5, letterSpacing: 1.0)
                                  .copyWith(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSizeGrid(topSizes, (size) {
                    setState(() {
                      _selectedTopSize = size;
                    });
                  }, _selectedTopSize),
                  
                  if (product.isSet) ...[
                    const SizedBox(height: 16),
                    Text(
                      'SELECT BOTTOM SIZE',
                      style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    _buildSizeGrid(bottomSizes, (size) {
                      setState(() {
                        _selectedBottomSize = size;
                      });
                    }, _selectedBottomSize),
                  ],
                  const SizedBox(height: 24),

                  // Customized Product Options
                  if (optionGroups.isNotEmpty) ...[
                    ...optionGroups.entries.map((entry) {
                      final groupName = entry.key;
                      final optsList = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupName.toUpperCase(),
                            style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
                          ),
                          const SizedBox(height: 8),
                          _buildOptionsRow(groupName, optsList),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ],

                  // Premium Count-based Quantity Selector
                  Row(
                    children: [
                      Text(
                        'QUANTITY',
                        style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_selectedQuantity > 1) {
                                setState(() {
                                  _selectedQuantity--;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.goldLight.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(Icons.remove, size: 14, color: AppColors.charcoal),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              _selectedQuantity.toString(),
                              style: AppTextStyles.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedQuantity++;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.goldLight.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(Icons.add, size: 14, color: AppColors.charcoal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Custom Stitching CTA Card
                  GestureDetector(
                    onTap: () => _showStitchingBottomSheet(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.04),
                        border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.scissors, color: AppColors.goldDark, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NEED CUSTOM TAILORING?',
                                  style: AppTextStyles.uppercaseLabel(color: AppColors.goldDark, fontSize: 9.5, letterSpacing: 1.5)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Get this garment customized to your exact lengths.',
                                  style: AppTextStyles.sansBody(fontSize: 11, color: AppColors.stone),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.goldDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. PRODUCT DETAILS & SILHOUETTES Expandable Accordion
                  ExpansionTile(
                    title: Text(
                      'PRODUCT DETAILS & SILHOUETTES',
                      style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10, letterSpacing: 1.0)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                    expandedAlignment: Alignment.topLeft,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.description,
                        style: AppTextStyles.sansBody(fontSize: 12.5, color: AppColors.stone).copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      if (product.fabricDetails != null)
                        _buildDetailText('Fabric:', product.fabricDetails!),
                      if (product.topLength != null && product.topLength!.isNotEmpty)
                        _buildDetailText('Top Length:', product.topLength!),
                      if (product.pantLength != null && product.pantLength!.isNotEmpty)
                        _buildDetailText('Bottom Length:', product.pantLength!),
                      if (product.sleeveLength != null && product.sleeveLength!.isNotEmpty)
                        _buildDetailText('Sleeve Length:', product.sleeveLength!),
                    ],
                  ),
                  Divider(height: 1, color: AppColors.goldLight.withOpacity(0.3)),

                  // 2. SHIPPING & DELIVERY TIMELINE Expandable Accordion
                  ExpansionTile(
                    title: Text(
                      'SHIPPING & DELIVERY TIMELINE',
                      style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10, letterSpacing: 1.0)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                    expandedAlignment: Alignment.topLeft,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailText('Estimated Dispatch:', product.deliveryTimeline),
                      const SizedBox(height: 4),
                      Text(
                        'Each Vamika Bhargavi order is carefully hand-stitched and shipped. We provide free shipping across India. Standard cash on delivery or online transactions are verified post-checkouts.',
                        style: AppTextStyles.sansBody(fontSize: 12, color: AppColors.stone).copyWith(height: 1.6),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: AppColors.goldLight.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleAddToBag(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.charcoal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.shoppingBag, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ADD TO BAG',
                    style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStitchingBottomSheet(BuildContext context) {
    final product = widget.product;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.scissors, color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Custom Stitching & Orders',
                      style: AppTextStyles.serifHeading3().copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Every garment at Vamika Bhargavi is made-to-order. If you wish to customize lengths, sleeve shapes, neck styles, or specify exact body measurements, please tap below to message our designers on WhatsApp.',
                style: AppTextStyles.sansBody(fontSize: 12.5, color: AppColors.stone).copyWith(height: 1.6),
              ),
              const SizedBox(height: 24),
              
              // WhatsApp Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final String msg = "Hello Vamika Bhargavi, I am interested in custom tailoring for the '${product.title}' (Category: ${product.category.toUpperCase()}). Please assist me with sharing my measurements.";
                    final Uri whatsappUri = Uri.parse("https://wa.me/919876543210?text=${Uri.encodeComponent(msg)}");
                    try {
                      final launched = await launchUrl(whatsappUri, mode: LaunchMode.externalNonBrowserApplication);
                      if (!launched) {
                        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open WhatsApp. Message us at +91 98765 43210.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(LucideIcons.messageSquare, size: 16, color: Colors.white),
                  label: Text(
                    'CONNECT ON WHATSAPP',
                    style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 1.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.charcoal.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                  child: Text(
                    'CLOSE',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 11, letterSpacing: 2.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSizeGrid(List<String> sizes, Function(String) onSelected, String? currentValue) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: sizes.map((size) {
        final isSelected = currentValue == size;
        return GestureDetector(
          onTap: () => onSelected(size),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.charcoal : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.charcoal : AppColors.goldLight.withOpacity(0.5),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              size,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.charcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionsRow(String groupName, List<ProductOption> options) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = _selectedOptionsMap[groupName]?.id == opt.id;
        final extraPrice = opt.priceAdjustment > 0 
            ? ' (+Rs. ${opt.priceAdjustment.toInt().toString()})' 
            : '';

        return ChoiceChip(
          label: Text(
            '${opt.optionValue}$extraPrice',
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : AppColors.charcoal,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.charcoal,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: AppColors.goldLight.withOpacity(0.5)),
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedOptionsMap[groupName] = opt;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.sansBody(fontSize: 12, color: Colors.grey[700]!),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _handleAddToBag(BuildContext context) async {
    final product = widget.product;
    final basePrice = product.variants.isNotEmpty ? product.variants[0].price : 0.0;
    
    // Sort options to build a stable ID
    final sortedOptionsList = _selectedOptionsMap.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final String compoundId = '${product.id}_${_selectedTopSize ?? ''}_${_selectedBottomSize ?? ''}_${sortedOptionsList.map((o) => o.id).join('_')}';

    final cartItem = CartItem(
      id: compoundId,
      productId: product.id,
      productTitle: product.title,
      productImage: product.images.isNotEmpty ? product.images[0] : 'https://via.placeholder.com/150',
      category: product.category,
      sellerShopName: product.sellerShopName ?? 'Luxury Boutique',
      variantId: product.variants.isNotEmpty ? product.variants[0].id : '',
      topSize: _selectedTopSize,
      bottomSize: _selectedBottomSize,
      basePrice: basePrice,
      selectedOptions: sortedOptionsList.map((o) => SelectedOption(
        id: o.id,
        optionName: o.optionName,
        optionValue: o.optionValue,
        priceAdjustment: o.priceAdjustment,
      )).toList(),
      quantity: _selectedQuantity,
      unitPrice: _currentPrice,
      deliveryTimeline: product.deliveryTimeline,
    );

    // Call Provider to add to bag
    await context.read<CartProvider>().addItem(cartItem);

    // Success popup feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.charcoal,
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: AppColors.gold, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Added to Shopping Bag successfully!',
                style: AppTextStyles.sansBody(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSizeChart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Size Guide (inches)',
                style: AppTextStyles.serifHeading3(),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: AppColors.goldLight.withOpacity(0.5), width: 0.8),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08)),
                    children: [
                      _buildTableCell('Size', isHeader: true),
                      _buildTableCell('Bust', isHeader: true),
                      _buildTableCell('Waist', isHeader: true),
                      _buildTableCell('Hips', isHeader: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('XS'),
                      _buildTableCell('32'),
                      _buildTableCell('26'),
                      _buildTableCell('35'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('S'),
                      _buildTableCell('34'),
                      _buildTableCell('28'),
                      _buildTableCell('37'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('M'),
                      _buildTableCell('36'),
                      _buildTableCell('30'),
                      _buildTableCell('39'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('L'),
                      _buildTableCell('38'),
                      _buildTableCell('32'),
                      _buildTableCell('41'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('XL'),
                      _buildTableCell('40'),
                      _buildTableCell('34'),
                      _buildTableCell('43'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '* All measurements are in inches. Standard size variants are loose-fit tunics.',
                style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(fontSize: 10.5),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.sansBody(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.charcoal : AppColors.stone,
        ),
      ),
    );
  }
}

