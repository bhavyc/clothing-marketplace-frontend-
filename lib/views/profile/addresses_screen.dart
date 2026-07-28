import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String streetAddress;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesStr = prefs.getString('saved_addresses');
    if (addressesStr != null && addressesStr.isNotEmpty) {
      try {
        final List decodedList = json.decode(addressesStr);
        setState(() {
          _addresses = decodedList.map((item) => Address.fromJson(item)).toList();
          _isLoading = false;
        });
        return;
      } catch (e) {
        print('Error loading saved addresses: $e');
      }
    }
    
    // Default fallback address using active profile if available
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _addresses = [
        Address(
          id: 'default_1',
          name: user.name ?? 'Guest User',
          phone: user.phone ?? '',
          streetAddress: 'Add your shipping address details',
          city: 'City',
          state: 'State',
          pincode: '000000',
          isDefault: true,
        ),
      ];
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_addresses.map((a) => a.toJson()).toList());
    await prefs.setString('saved_addresses', encoded);
  }

  void _addNewAddress(Address address) {
    setState(() {
      _addresses.add(address);
    });
    _saveAddresses();
  }

  void _deleteAddress(String id) {
    setState(() {
      _addresses.removeWhere((item) => item.id == id);
    });
    _saveAddresses();
  }

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
          'shipping addresses',
          style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return _buildAddressCard(address);
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () => _showAddAddressSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.charcoal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              elevation: 0,
            ),
            child: Text(
              'ADD NEW ADDRESS',
              style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.mapPin, color: AppColors.gold, size: 48),
            const SizedBox(height: 16),
            Text(
              'No Saved Addresses',
              style: AppTextStyles.serifHeading3(),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a delivery address to enable faster checkout states.',
              style: AppTextStyles.sansSubtitle(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: address.isDefault ? AppColors.gold : AppColors.goldLight.withOpacity(0.3), width: 0.8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.name,
                style: AppTextStyles.serifHeading3(color: AppColors.charcoal).copyWith(fontSize: 14),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.08),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: AppTextStyles.uppercaseLabel(color: AppColors.goldDark, fontSize: 8, letterSpacing: 1.0),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.streetAddress,
            style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone).copyWith(height: 1.5),
          ),
          Text(
            '${address.city}, ${address.state} - ${address.pincode}',
            style: AppTextStyles.sansBody(fontSize: 13, color: AppColors.stone),
          ),
          const SizedBox(height: 12),
          Text(
            'Phone: ${address.phone}',
            style: AppTextStyles.sansSubtitle(color: AppColors.stone).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.goldLight.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _deleteAddress(address.id),
                icon: const Icon(LucideIcons.trash2, size: 13, color: AppColors.error),
                label: Text(
                  'REMOVE',
                  style: AppTextStyles.uppercaseLabel(color: AppColors.error, fontSize: 9, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String phone = '';
    String street = '';
    String city = '';
    String state = '';
    String pincode = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Shipping Address',
                    style: AppTextStyles.serifHeading3(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Name Field
                  TextFormField(
                    decoration: _buildInputDecoration('Full Name'),
                    style: AppTextStyles.sansBody(fontSize: 13),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => name = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Field
                  TextFormField(
                    decoration: _buildInputDecoration('Phone Number'),
                    style: AppTextStyles.sansBody(fontSize: 13),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => phone = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  
                  // Street Address Field
                  TextFormField(
                    decoration: _buildInputDecoration('Address (House No, Area, Street)'),
                    style: AppTextStyles.sansBody(fontSize: 13),
                    maxLines: 2,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => street = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  
                  // City & State Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: _buildInputDecoration('City'),
                          style: AppTextStyles.sansBody(fontSize: 13),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          onSaved: (val) => city = val ?? '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: _buildInputDecoration('State'),
                          style: AppTextStyles.sansBody(fontSize: 13),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          onSaved: (val) => state = val ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Pincode Field
                  TextFormField(
                    decoration: _buildInputDecoration('Pincode'),
                    style: AppTextStyles.sansBody(fontSize: 13),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => pincode = val ?? '',
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          _addNewAddress(Address(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            phone: phone,
                            streetAddress: street,
                            city: city,
                            state: state,
                            pincode: pincode,
                          ));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.charcoal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        elevation: 0,
                      ),
                      child: Text(
                        'SAVE ADDRESS',
                        style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 11, letterSpacing: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.sansSubtitle(color: AppColors.stone),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: AppColors.goldLight.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: AppColors.goldLight.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }
}
