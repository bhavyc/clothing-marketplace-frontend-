import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../main_navigation.dart';
import '../orders/history_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String orderNumber;
  
  const SuccessScreen({Key? key, required this.orderNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Gold Checkmark Badge
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  color: AppColors.gold,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'ORDER CONFIRMED',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 12, letterSpacing: 3.0),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been placed successfully.',
                style: AppTextStyles.serifHeading3(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Order Identification Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Number:',
                      style: AppTextStyles.sansBody(color: AppColors.stone, fontSize: 13),
                    ),
                    Text(
                      orderNumber,
                      style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Email Notification Banner
              Text(
                'A confirmation email containing your item specifications, sizes, pricing details, and expected delivery timeline has been dispatched to your email address.',
                style: AppTextStyles.sansSubtitle().copyWith(fontSize: 11, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // CTA Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 10, letterSpacing: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Direct to orders list
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: Text(
                  'VIEW ORDER DETAILS',
                  style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
