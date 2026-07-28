import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
   
  bool _useWallet = false;
  bool _isPlacingOrder = false;
  String _errorMessage = '';

  late Razorpay _razorpay;
  String? _pendingOrderNumber;
  String? _pendingRazorpayOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Prefill form details from authenticated user session profile
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = (user.name == 'Guest User') ? '' : (user.name ?? '');
      
      final email = user.email;
      final isPlaceholder = email.startsWith('user-') && email.endsWith('@boutique.com');
      _emailController.text = isPlaceholder ? '' : email;
      
      _phoneController.text = user.phone ?? '';
    }
    _prefillDefaultAddress();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Show loading on checkout screen
    setState(() {
      _isPlacingOrder = true;
      _errorMessage = '';
    });
    
    try {
      final verifySuccess = await _orderService.verifyPayment(
        orderNumber: _pendingOrderNumber!,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? _pendingRazorpayOrderId!,
        signature: response.signature ?? '',
      );

      if (verifySuccess) {
        await _saveCheckoutAddressToLocal();
        if (mounted) {
          final cart = context.read<CartProvider>();
          final auth = context.read<AuthProvider>();
          await cart.clearCart();
          await auth.fetchUserProfile();
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SuccessScreen(orderNumber: _pendingOrderNumber!)),
            (route) => route.isFirst,
          );
        }
      } else {
        throw Exception('Payment verification failed.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isPlacingOrder = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isPlacingOrder = false;
      _errorMessage = response.message ?? 'Payment failed or cancelled';
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isPlacingOrder = false;
      _errorMessage = 'External wallet payment not supported in this version';
    });
  }

  Future<void> _prefillDefaultAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesStr = prefs.getString('saved_addresses');
      if (addressesStr != null && addressesStr.isNotEmpty) {
        final decoded = json.decode(addressesStr);
        if (decoded is List && decoded.isNotEmpty) {
          final defaultAddr = decoded.firstWhere(
            (addr) => addr['isDefault'] == true,
            orElse: () => decoded[0],
          );
          if (defaultAddr != null) {
            setState(() {
              if (_nameController.text.isEmpty || _nameController.text == 'Guest User') {
                _nameController.text = defaultAddr['name'] ?? '';
              }
              if (_phoneController.text.isEmpty) {
                _phoneController.text = defaultAddr['phone'] ?? '';
              }
              _addressController.text = defaultAddr['streetAddress'] ?? '';
              _cityController.text = defaultAddr['city'] ?? '';
              _stateController.text = defaultAddr['state'] ?? '';
              _pincodeController.text = defaultAddr['pincode'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      print('Error prefilling checkout address: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  double get _walletDeduction {
    if (!_useWallet) return 0.0;
    final walletBal = context.read<AuthProvider>().user?.walletBalance ?? 0.0;
    final finalTotal = context.read<CartProvider>().finalTotal;
    
    // Deduct whichever is smaller (balance or total amount)
    return walletBal > finalTotal ? finalTotal : walletBal;
  }

  double get _finalAmountToPay {
    final finalTotal = context.read<CartProvider>().finalTotal;
    return finalTotal - _walletDeduction;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'shipping & checkout',
          style: AppTextStyles.serifHeading3().copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address fields form card
              _buildSectionTitle('Shipping Address'),
              _buildAddressCard(),
              const SizedBox(height: 24),
              
              // Wallet usage card
              if (user != null && user.walletBalance > 0) ...[
                _buildSectionTitle('Wallet Balance'),
                _buildWalletCard(user),
                const SizedBox(height: 24),
              ],

              // Order Summary invoice breakdown
              _buildSectionTitle('Summary Invoice'),
              _buildSummaryCard(cartProvider),
              const SizedBox(height: 30),
              
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(cartProvider, authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    elevation: 0,
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'PLACE ORDER (Rs. ${_finalAmountToPay.toInt().toString()})',
                          style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.5),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField('Recipient Name', _nameController, true),
          const SizedBox(height: 12),
          _buildTextField('Email Address', _emailController, true, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildTextField('Phone Number', _phoneController, true, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField('Full Shipping Address', _addressController, true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('City', _cityController, true)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField('State', _stateController, true)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Pincode / Postal Code', _pincodeController, true, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    bool required, {
    TextInputType keyboardType = TextInputType.text
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.charcoal),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: AppTextStyles.sansSubtitle().copyWith(color: AppColors.stone, fontSize: 11),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: AppColors.cream.withValues(alpha: 0.3),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gold, width: 1.0),
          borderRadius: BorderRadius.circular(2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 0.8),
          borderRadius: BorderRadius.circular(2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        if (label == 'Email Address' || label == 'Email Address *') {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (value != null && !emailRegex.hasMatch(value.trim())) {
            return 'Please enter a valid email address';
          }
          final isPlaceholder = value!.trim().startsWith('user-') && value.trim().endsWith('@boutique.com');
          if (isPlaceholder) {
            return 'Please enter a valid personal email address';
          }
        }
        return null;
      },
    );
  }

  Widget _buildWalletCard(UserModel user) {
    return Container(
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
      child: SwitchListTile(
        title: Text(
          'Deduct from Wallet',
          style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoal),
        ),
        subtitle: Text(
          'Available: Rs. ${user.walletBalance.toInt().toString()}',
          style: AppTextStyles.sansSubtitle().copyWith(color: AppColors.stone),
        ),
        value: _useWallet,
        activeColor: AppColors.gold,
        onChanged: (val) {
          setState(() {
            _useWallet = val;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard(CartProvider provider) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummaryRow('Cart Subtotal', provider.cartSubtotal),
          if (provider.discountAmount > 0)
            _buildSummaryRow('Applied Promo Discount', -provider.discountAmount, color: AppColors.error),
          if (_useWallet && _walletDeduction > 0)
            _buildSummaryRow('Wallet Deduction', -_walletDeduction, color: AppColors.stone),
          const SizedBox(height: 12),
          Container(
            height: 0.5,
            color: AppColors.goldLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Total',
                style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ${_finalAmountToPay.toInt().toString()}',
                style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double val, {Color? color}) {
    final formattedVal = val >= 0 
        ? 'Rs. ${val.toInt().toString()}' 
        : '- Rs. ${val.abs().toInt().toString()}';
        
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.sansBody(color: color ?? AppColors.stone, fontSize: 12)),
          Text(formattedVal, style: AppTextStyles.sansBody(color: color ?? AppColors.charcoal, fontSize: 12)),
        ],
      ),
    );
  }

  void _handlePlaceOrder(CartProvider cart, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isPlacingOrder = true;
      _errorMessage = '';
    });

    try {
      // 1. Submit order details to backend route
      final orderResult = await _orderService.placeOrder(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        items: cart.items,
        useWallet: _useWallet,
        couponId: cart.couponCode,
      );

      if (orderResult == null || orderResult['success'] != true) {
        throw Exception('Server checkout processing failed.');
      }
       
      final String orderNumber = orderResult['orderNumber'];
      final double totalAmount = (orderResult['totalAmount'] as num).toDouble();
      final String? razorpayOrderId = orderResult['razorpayOrderId'];
      
      // 2. Resolve Payment Gateway Verification
      if (totalAmount == 0) {
        // Fully paid via wallet deductions, already marked as PAID on server
        await _saveCheckoutAddressToLocal();
        await cart.clearCart();
        await auth.fetchUserProfile(); // Refresh wallet state
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SuccessScreen(orderNumber: orderNumber)),
            (route) => route.isFirst,
          );
        }
      } else {
        // Save pending order details
        _pendingOrderNumber = orderNumber;
        _pendingRazorpayOrderId = razorpayOrderId;

        // Open Real Razorpay payment sheet!
        final amountInPaise = (totalAmount * 100).round();
        final options = {
          'key': 'rzp_test_SHuZT9fDb8rLhx', // Razorpay Test Key from .env
          'amount': amountInPaise,
          'name': 'Vamika & Bhargavi',
          'description': 'Order #$orderNumber Payment',
          'order_id': razorpayOrderId, // Real backend order id created in transaction
          'prefill': {
            'contact': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
          },
          'timeout': 300, // 5 minutes timeout
        };

        try {
          _razorpay.open(options);
        } catch (e) {
          setState(() {
            _errorMessage = 'Could not open Razorpay checkout: $e';
            _isPlacingOrder = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isPlacingOrder = false;
      });
    }
  }

  Future<void> _saveCheckoutAddressToLocal() async {
    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final street = _addressController.text.trim();
      final city = _cityController.text.trim();
      final state = _stateController.text.trim();
      final pincode = _pincodeController.text.trim();

      if (name.isEmpty || phone.isEmpty || street.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final String? addressesStr = prefs.getString('saved_addresses');
      
      List<dynamic> addressesList = [];
      if (addressesStr != null && addressesStr.isNotEmpty) {
        try {
          final decoded = json.decode(addressesStr);
          if (decoded is List) {
            addressesList = decoded;
          }
        } catch (e) {
          print('Error decoding saved addresses in checkout: $e');
        }
      }

      // Check if this address already exists to avoid duplication
      final alreadyExists = addressesList.any((addr) =>
          addr is Map &&
          addr['streetAddress']?.toString().toLowerCase() == street.toLowerCase() &&
          addr['city']?.toString().toLowerCase() == city.toLowerCase() &&
          addr['pincode']?.toString() == pincode);

      if (!alreadyExists) {
        final newAddress = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'phone': phone,
          'streetAddress': street,
          'city': city,
          'state': state,
          'pincode': pincode,
          'isDefault': addressesList.isEmpty,
        };
        addressesList.add(newAddress);
        await prefs.setString('saved_addresses', json.encode(addressesList));
      }
    } catch (e) {
      print('Error saving checkout address: $e');
    }
  }
}


