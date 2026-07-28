import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class TrackingScreen extends StatefulWidget {
  final String orderNumber;
  const TrackingScreen({Key? key, required this.orderNumber}) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final OrderService _orderService = OrderService();
  OrderModel? _order;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final order = await _orderService.fetchOrderDetail(widget.orderNumber);
      if (order != null) {
        setState(() {
          _order = order;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Order details not found.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch tracking details.';
        _loading = false;
      });
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'PLACED':
        return 0;
      case 'CONFIRMED':
        return 1;
      case 'SHIPPED':
        return 2;
      case 'DELIVERED':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'track status',
          style: AppTextStyles.serifHeading3().copyWith(fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _error.isNotEmpty
              ? _buildErrorView()
              : _buildTrackingContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 36),
          const SizedBox(height: 12),
          Text(_error, style: AppTextStyles.sansBody(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrackingContent() {
    final order = _order!;
    final step = _getStatusStep(order.status);
    final isCancelled = order.status == 'CANCELLED';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number header
          Text(
            order.orderNumber,
            style: AppTextStyles.serifHeading2(),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated Delivery: 10-15 Days',
            style: AppTextStyles.sansSubtitle(),
          ),
          const SizedBox(height: 24),

          // Status Progress Timeline
          if (isCancelled)
            _buildCancelledTimeline()
          else
            _buildTimelineProgress(step),

          const SizedBox(height: 32),

          // Live Tracking details card (Courier information)
          if (order.status == 'SHIPPED' || order.status == 'DELIVERED')
            _buildCourierCard(order),

          const SizedBox(height: 24),

          // Delivery Address Card
          Text(
            'SHIPPING ADDRESS',
            style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
          ),
          const SizedBox(height: 8),
          _buildAddressCard(order),
        ],
      ),
    );
  }

  Widget _buildCancelledTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.xCircle, color: AppColors.error, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, color: AppColors.error),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your payment (if deducted) will be refunded to your source account or wallet.',
                  style: AppTextStyles.sansSubtitle().copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineProgress(int currentStep) {
    final stages = [
      {'title': 'Order Placed', 'subtitle': 'Order successfully received'},
      {'title': 'Confirmed', 'subtitle': 'Apparel is being tailor-crafted'},
      {'title': 'Shipped', 'subtitle': 'Shipment is currently in transit'},
      {'title': 'Delivered', 'subtitle': 'Package delivered at your doorstep'},
    ];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: AppColors.goldLight.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: List.generate(stages.length, (index) {
            final isCompleted = index <= currentStep;
            final isLast = index == stages.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Connector
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.gold : Colors.white,
                        border: Border.all(
                          color: isCompleted ? AppColors.gold : Colors.grey[300]!,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? const Center(
                              child: Icon(Icons.check, size: 10, color: Colors.white),
                            )
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 45,
                        color: index < currentStep ? AppColors.gold : Colors.grey[300]!,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stages[index]['title']!,
                        style: AppTextStyles.sansBody(
                          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? AppColors.charcoal : Colors.grey[500]!,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stages[index]['subtitle']!,
                        style: AppTextStyles.sansSubtitle().copyWith(
                          color: isCompleted ? AppColors.stone : Colors.grey[400]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCourierCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.truck, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              Text(
                'COURIER / CARRIER DETAILS',
                style: AppTextStyles.uppercaseLabel(color: AppColors.gold, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCourierRow('Shipping Partner:', order.trackingCompany ?? 'Standard Delivery'),
          const SizedBox(height: 8),
          _buildCourierRow('Tracking Number:', order.trackingNumber ?? 'None'),
          const SizedBox(height: 12),
          Text(
            'Use the tracking number on the courier partner\'s website to check transit checkpoints.',
            style: AppTextStyles.sansSubtitle().copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.sansBody(color: AppColors.stone, fontSize: 12)),
        Text(
          value,
          style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.customerName,
            style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            order.shippingAddress,
            style: AppTextStyles.sansBody(color: Colors.grey[700]!, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${order.city}, ${order.state} - ${order.pincode}',
            style: AppTextStyles.sansBody(color: Colors.grey[700]!, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Phone: ${order.customerPhone}',
            style: AppTextStyles.sansSubtitle().copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
