import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../orders/history_screen.dart';
import 'about_us_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAuth = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'my account',
          style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
            fontSize: 18,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAuth && user != null) ...[
              // 1. Premium User Header
              _buildUserDetailsCard(user),
              const SizedBox(height: 28),
              
              // 2. High-Fashion Maroon & Gold Wallet Card
              _buildWalletCard(user),
              const SizedBox(height: 32),
              
              // 3. Menu Links Section
              Text(
                'YOUR SHOPPING ASSISTANT',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 9.5, letterSpacing: 2.0),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(context),
              
              const SizedBox(height: 32),
              
              // 4. Logout Button (Sleek and Minimalist)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => authProvider.logout(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 0.8),
                    ),
                  ),
                  child: Text(
                    'LOG OUT OF ACCOUNT',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.error, fontSize: 10, letterSpacing: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 5. Delete Account Button (Minimal and Confirmation Guarded)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showDeleteAccountDialog(context, authProvider),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: BorderSide(color: AppColors.stone.withOpacity(0.2), width: 0.8),
                    ),
                  ),
                  child: Text(
                    'DELETE USER ACCOUNT',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.stone, fontSize: 10, letterSpacing: 2.5),
                  ),
                ),
              ),
            ] else ...[
              // Unauthenticated state view
              _buildGuestView(context),
              const SizedBox(height: 28),
              Text(
                'ABOUT THE BRAND',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 9.5, letterSpacing: 2.0),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
                ),
                child: _buildMenuItem(
                  icon: LucideIcons.info,
                  title: 'About Vamika Bhargavi',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(dynamic user) {
    final displayName = (user.phone != null && user.phone!.isNotEmpty)
        ? user.phone!
        : (user.name ?? 'Customer Profile');
        
    final initial = displayName.isNotEmpty ? displayName.replaceAll('+', '').substring(0, 1).toUpperCase() : 'C';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Elegant Profile Avatar Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTextStyles.serifHeading3(color: AppColors.gold).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // User Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.8),
                  ),
                  child: Text(
                    'REGISTERED MEMBER',
                    style: AppTextStyles.uppercaseLabel(
                      color: AppColors.goldDark, fontSize: 8, letterSpacing: 1.5,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A111C), Color(0xFF280308)], // Deep Royal Maroon to Dark Maroon
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A111C).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOMER WALLET',
                style: AppTextStyles.uppercaseLabel(color: AppColors.goldLight, fontSize: 9.5, letterSpacing: 2.0),
              ),
              const Icon(LucideIcons.wallet, color: AppColors.goldLight, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Rs. ${user.walletBalance.toInt().toString()}',
            style: AppTextStyles.serifHeading2(color: Colors.white).copyWith(fontSize: 32, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Funds will be auto-deducted during checkout',
            style: AppTextStyles.sansSubtitle().copyWith(color: Colors.white.withOpacity(0.6), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: LucideIcons.shoppingBag,
            title: 'Track Orders & Purchase History',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          Divider(height: 1, color: AppColors.goldLight.withOpacity(0.3)),
          _buildMenuItem(
            icon: LucideIcons.mapPin,
            title: 'My Shipping Addresses',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddressesScreen()),
              );
            },
          ),
          Divider(height: 1, color: AppColors.goldLight.withOpacity(0.3)),
          _buildMenuItem(
            icon: LucideIcons.info,
            title: 'About Vamika Bhargavi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold, size: 16),
      title: Text(
        title,
        style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.charcoal),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.stone),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'vamika & bhargavi',
            style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'H A N D C R A F T E D   C O U T U R E',
            style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 7, letterSpacing: 2.0),
          ),
          const SizedBox(height: 28),
          const Icon(LucideIcons.user, color: AppColors.gold, size: 36),
          const SizedBox(height: 16),
          Text(
            'Unlock Your Account',
            style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Log in to review customized checkout states, wallet transactions, and trace shipped delivery timelines.',
            style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.charcoal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                elevation: 0,
              ),
              child: Text(
                'LOG IN / REGISTER',
                style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 10.5, letterSpacing: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'Delete Account',
            style: AppTextStyles.serifHeading3(color: AppColors.error),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This will erase your saved addresses, wallet balance, and track logs. This action is irreversible.',
            style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTextStyles.uppercaseLabel(color: AppColors.charcoal, fontSize: 10, letterSpacing: 1.0),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Dismiss dialog
                final success = await authProvider.deleteAccount();
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account permanently deleted.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete account. Please try again.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              child: Text(
                'DELETE PERMANENTLY',
                style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 10, letterSpacing: 1.0),
              ),
            ),
          ],
        );
      },
    );
  }
}
