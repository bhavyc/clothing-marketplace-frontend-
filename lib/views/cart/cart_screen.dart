import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../profile/login_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  String _couponError = '';

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'shopping bag',
          style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyBag(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(context, item, cartProvider);
                    },
                  ),
                ),
                
                // Coupon input & Totals summary block
                _buildSummaryBlock(context, cartProvider, authProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyBag(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.shoppingBag, color: AppColors.gold, size: 64),
          const SizedBox(height: 16),
          Text(
            'Your shopping bag is empty',
            style: AppTextStyles.serifHeading3(),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some handcrafted luxury apparel to get started.',
            style: AppTextStyles.sansSubtitle(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, dynamic item, CartProvider provider) {
    final optionText = item.selectedOptions.isNotEmpty
        ? item.selectedOptions.map((o) => '${o.optionName}: ${o.optionValue}').join(', ')
        : null;

    final sizeText = [
      item.topSize != null ? 'Top: ${item.topSize}' : null,
      item.bottomSize != null ? 'Bottom: ${item.bottomSize}' : null,
    ].where((e) => e != null).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              item.productImage,
              width: 85,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productTitle,
                        style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 13.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => provider.removeItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 10, color: AppColors.stone),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${item.sellerShopName}'.toUpperCase(),
                  style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 8.5, letterSpacing: 1.0),
                ),
                const SizedBox(height: 12),
                
                // Size and Custom features tags
                if (sizeText.isNotEmpty || optionText != null) ...[
                  Row(
                    children: [
                      if (sizeText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            sizeText,
                            style: AppTextStyles.sansBody(fontSize: 9.5, color: AppColors.stone, fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (sizeText.isNotEmpty && optionText != null)
                        const SizedBox(width: 6),
                      if (optionText != null)
                        Expanded(
                          child: Text(
                            optionText,
                            style: AppTextStyles.sansBody(fontSize: 9.5, color: AppColors.stone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Price & Quantity counters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${(item.unitPrice * item.quantity).toInt().toString()}',
                      style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14),
                    ),
                    
                    // Quantity adjustments counter
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => provider.updateQuantity(item.id, item.quantity - 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.remove, size: 10, color: AppColors.charcoal),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: AppTextStyles.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                          ),
                          GestureDetector(
                            onTap: () => provider.updateQuantity(item.id, item.quantity + 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.add, size: 10, color: AppColors.charcoal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBlock(BuildContext context, CartProvider provider, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promo Code box
            if (provider.couponCode == null) ...[
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.5),
                  border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.tag, size: 14, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: AppTextStyles.sansBody(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Enter promo code (e.g. PAY5)',
                          hintStyle: AppTextStyles.sansSubtitle().copyWith(fontSize: 11, color: AppColors.stone),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_couponController.text.isEmpty) return;
                        final success = await provider.applyCoupon(_couponController.text);
                        if (success) {
                          setState(() {
                            _couponError = '';
                          });
                          _couponController.clear();
                        } else {
                          setState(() {
                            _couponError = 'Invalid coupon code';
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.gold,
                      ),
                      child: Text(
                        'APPLY',
                        style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.availableCoupons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: provider.availableCoupons.map((coupon) {
                        final code = coupon['code']?.toString() ?? '';
                        final isPercent = ((coupon['discountPercent'] as num?)?.toDouble() ?? 0.0) > 0;
                        final discText = isPercent
                            ? '${(coupon['discountPercent'] as num).toInt()}% OFF'
                            : 'Rs. ${(coupon['discountAmount'] as num).toInt()} OFF';
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _couponController.text = code;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.25), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.tag, size: 10, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Text(
                                  '$code ($discText)',
                                  style: AppTextStyles.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.tag, size: 14, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'Promo code ${provider.couponCode} applied',
                          style: AppTextStyles.sansBody(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => provider.removeCoupon(),
                      child: const Icon(LucideIcons.x, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            if (_couponError.isNotEmpty && provider.couponCode == null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _couponError,
                  style: AppTextStyles.sansBody(color: AppColors.error, fontSize: 10.5),
                ),
              ),
            ],
            const SizedBox(height: 18),
            
            // Subtotal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTextStyles.sansBody(color: AppColors.stone, fontSize: 12)),
                Text('Rs. ${provider.cartSubtotal.toInt().toString()}', style: AppTextStyles.sansBody(color: AppColors.charcoal, fontSize: 12)),
              ],
            ),
            
            // Applied Discount Row
            if (provider.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Applied Discount', style: AppTextStyles.sansBody(color: AppColors.error, fontSize: 12)),
                  Text('- Rs. ${provider.discountAmount.toInt().toString()}', style: AppTextStyles.sansBody(color: AppColors.error, fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              height: 0.5,
              color: AppColors.goldLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            
            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${provider.finalTotal.toInt().toString()}',
                  style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleCheckout(context, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  elevation: 0,
                ),
                child: Text(
                  'PROCEED TO CHECKOUT',
                  style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context, AuthProvider auth) {
    if (!auth.isAuthenticated) {
      // Direct user to log in first
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(redirectToCheckout: true),
        ),
      );
    } else {
      // Push directly to checkout screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CheckoutScreen(),
        ),
      );
    }
  }
}

extension FilterList<T> on List<T?> {
  String join(String separator) {
    return where((element) => element != null).map((e) => e.toString()).join(separator);
  }
  
  bool get isNotEmpty => where((element) => element != null).isNotEmpty;
}
