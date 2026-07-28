import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../checkout/checkout_screen.dart';
import '../main_navigation.dart';

class LoginScreen extends StatefulWidget {
  final bool redirectToCheckout;
  
  const LoginScreen({Key? key, this.redirectToCheckout = false}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _formatPhone(String raw) {
    // Keep only digits and '+'
    var phone = raw.replaceAll(RegExp(r'[^\d+]'), '').trim();
    
    if (phone.startsWith('+91')) {
      if (phone.length == 13) return phone;
    } else if (phone.startsWith('91') && phone.length == 12) {
      return '+$phone';
    } else {
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      if (phone.length == 10) {
        return '+91$phone';
      }
    }
    return null; // Invalid format
  }

  void _handleSendOtp(AuthProvider auth) async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a mobile number';
      });
      return;
    }

    final phone = _formatPhone(rawPhone);
    if (phone == null) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    final success = await auth.sendOtp(phone);
    if (success) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.charcoal,
          content: Text(
            'OTP sent successfully (Check terminal/console for dev bypass)',
            style: AppTextStyles.sansBody(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to dispatch verification OTP. Try again.';
      });
    }
  }

  void _handleVerifyOtp(AuthProvider auth) async {
    final phone = _formatPhone(_phoneController.text);
    if (phone == null) {
      setState(() {
        _errorMessage = 'Invalid phone number format';
      });
      return;
    }
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      setState(() {
        _errorMessage = 'Please enter a valid OTP code';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    final success = await auth.verifyOtp(phone, otp);
    if (success) {
      if (widget.redirectToCheckout) {
        // Pop LoginScreen and immediately push CheckoutScreen
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CheckoutScreen(),
          ),
        );
      } else {
        // Direct transition into main homepage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid verification OTP code';
      });
    }
  }

  // Decorative gold divider widget
  Widget _buildGoldDivider({double width = 60}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width * 0.3,
          height: 0.5,
          color: AppColors.goldLight,
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: width * 0.3,
          height: 0.5,
          color: AppColors.goldLight,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content — centered
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),

                          // ─── Brand Identity ───
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'vamika & bhargavi',
                              style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(
                                fontSize: 28,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'H A N D C R A F T E D   C O U T U R E',
                            style: AppTextStyles.uppercaseLabel(
                              color: AppColors.gold, fontSize: 7.5, letterSpacing: 3.0,
                            ).copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),
                          _buildGoldDivider(width: 100),
                          const SizedBox(height: 32),

                          // ─── Section Heading ───
                          Text(
                            _otpSent ? 'Verify Your Code' : 'Welcome',
                            style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
                              fontSize: 22,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _otpSent
                                ? 'Enter the verification code sent\nto your mobile number.'
                                : 'Sign in with your registered\nmobile number to continue.',
                            style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(
                              fontSize: 13,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // ─── Input Fields ───
                          if (!_otpSent) ...[
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: AppTextStyles.sansBody(fontSize: 15, color: AppColors.charcoal),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter 10-digit mobile number',
                                hintStyle: AppTextStyles.sansSubtitle(color: AppColors.stone.withOpacity(0.5)).copyWith(fontSize: 14),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                                  child: Icon(LucideIcons.phone, size: 16, color: AppColors.gold.withOpacity(0.7)),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.goldLight, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                            ),
                          ] else ...[
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              style: AppTextStyles.sansBody(fontSize: 22, color: AppColors.charcoal, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '• • • • • •',
                                hintStyle: TextStyle(
                                  fontSize: 22,
                                  color: AppColors.stone.withOpacity(0.3),
                                  letterSpacing: 6,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                                  child: Icon(LucideIcons.lock, size: 16, color: AppColors.gold.withOpacity(0.7)),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.goldLight, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                            ),
                            if (auth.devOtp != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Dev OTP: ',
                                      style: AppTextStyles.sansBody(fontSize: 11, color: AppColors.stone),
                                    ),
                                    SelectableText(
                                      auth.devOtp!,
                                      style: AppTextStyles.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],

                          // ─── Error Message ───
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: AppColors.error.withOpacity(0.2)),
                              ),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // ─── Action Button ───
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => _otpSent ? _handleVerifyOtp(auth) : _handleSendOtp(auth),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.charcoal,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.charcoal.withOpacity(0.5),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                                    )
                                  : Text(
                                      _otpSent ? 'VERIFY CODE' : 'CONTINUE',
                                      style: AppTextStyles.uppercaseLabel(
                                        color: Colors.white, fontSize: 11, letterSpacing: 2.5,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),

                          if (_otpSent) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _otpSent = false;
                                  _otpController.clear();
                                });
                              },
                              child: Text(
                                'Change Number',
                                style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.stone.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),
                          _buildGoldDivider(width: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Secure & Private',
                            style: AppTextStyles.uppercaseLabel(
                              color: AppColors.stone.withOpacity(0.5), fontSize: 8, letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ─── Back Button Overlay ───
            if (Navigator.canPop(context))
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.charcoal, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
