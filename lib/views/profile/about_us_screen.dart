import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'OUR STORY',
          style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 12, letterSpacing: 3.0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Classic Serif Brand Wordmark
              Text(
                'vamika bhargavi',
                style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(
                  fontSize: 32,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A MOTHER-DAUGHTER LEGACY',
                style: AppTextStyles.uppercaseLabel(color: AppColors.goldDark, fontSize: 8.5, letterSpacing: 4.0),
              ),
              const SizedBox(height: 32),

              // 2. Premium Quote Block (Editorial Focus)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
                    const SizedBox(height: 16),
                    Text(
                      '“Curated with love. Crafted with purpose. Designed to become part of your story.”',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
                        fontSize: 14.5,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 3. Editorial Story Text (One unified clean card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.3), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.charcoal.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: The Beginning
                    _buildSectionHeader('THE BEGINNING'),
                    const SizedBox(height: 12),
                    Text(
                      'Vamika Bhargavi was born from a simple yet meaningful idea—to celebrate the timeless bond between a mother and daughter through fashion.',
                      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Founded by Bhargavi and inspired by her daughter Vamika, our brand is a reflection of love, legacy, and individuality. Every collection is thoughtfully curated to bring together the richness of Indian craftsmanship with a modern, effortless aesthetic.',
                      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.7),
                    ),
                    
                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 28),

                    // Section 2: The Philosophy
                    _buildSectionHeader('EXPRESSING TRADITION'),
                    const SizedBox(height: 12),
                    Text(
                      'We believe clothing is more than what you wear—it is a way of expressing your personality, celebrating traditions, and creating memories. Whether it’s a festive gathering, an intimate celebration, or an everyday statement, each piece is selected and designed to make you feel confident, graceful, and uniquely yourself.',
                      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'At Vamika Bhargavi, we focus on curated fashion that balances timeless elegance with contemporary design. From handpicked fabrics and intricate embroideries to refined silhouettes and meticulous finishing, every detail is chosen with intention.',
                      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.7),
                    ),

                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 28),

                    // Section 3: The Vision
                    _buildSectionHeader('OUR VISION'),
                    const SizedBox(height: 12),
                    Text(
                      'As a mother-daughter brand, our vision extends beyond creating beautiful garments. We aspire to build a label that is cherished across generations—a name associated with authenticity, craftsmanship, and thoughtful design.',
                      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 5. Founders Signature Block
              Text(
                'Welcome to Vamika Bhargavi.',
                style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'With love,',
                style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text(
                'Bhargavi & Vamika',
                style: AppTextStyles.serifHeading2(color: AppColors.goldDark).copyWith(fontSize: 18, letterSpacing: 0.5),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.uppercaseLabel(color: AppColors.goldDark, fontSize: 10, letterSpacing: 2.5),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 1,
          color: AppColors.gold,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.5,
      color: AppColors.goldLight.withOpacity(0.3),
    );
  }
}
