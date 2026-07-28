import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'tracking_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      final list = await _orderService.fetchOrders();
      setState(() {
        _orders = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch order history. Try again.';
        _loading = false;
      });
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
          'order history',
          style: AppTextStyles.serifHeading3().copyWith(fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: AppColors.gold,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : _error.isNotEmpty
                ? _buildErrorView()
                : _orders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(context, order);
                        },
                      ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              _error,
              style: AppTextStyles.sansBody(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.charcoal),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.package, color: AppColors.gold, size: 48),
          const SizedBox(height: 16),
          Text(
            'No orders placed yet',
            style: AppTextStyles.serifHeading3(),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first custom order on checkout!',
            style: AppTextStyles.sansSubtitle(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    // Format timestamp nicely
    final dateString = order.createdAt.substring(0, 10);
    
    // Status text chip color
    Color statusColor;
    switch (order.status) {
      case 'DELIVERED':
        statusColor = AppColors.success;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.gold;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.cream.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Placed on $dateString',
                      style: AppTextStyles.sansSubtitle().copyWith(fontSize: 10),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card Items Preview
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: item.productImage.isNotEmpty
                              ? Image.network(item.productImage, width: 40, height: 48, fit: BoxFit.cover)
                              : Container(color: Colors.grey[200], width: 40, height: 48),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productTitle,
                                style: AppTextStyles.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: AppTextStyles.sansSubtitle().copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs. ${item.priceAtPurchase.toInt().toString()}',
                          style: AppTextStyles.sansBody(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                const Divider(),
                
                // Total Summary & CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.sansBody(fontSize: 12, color: AppColors.stone),
                        children: [
                          const TextSpan(text: 'Total Amount: '),
                          TextSpan(
                            text: 'Rs. ${order.totalAmount.toInt().toString()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.charcoal),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (order.status == 'DELIVERED') ...[
                          OutlinedButton(
                            onPressed: () => _showReturnDialog(context, order),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                            child: Text(
                              'RETURN',
                              style: AppTextStyles.uppercaseLabel(color: AppColors.error, fontSize: 9, letterSpacing: 1.0),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TrackingScreen(orderNumber: order.orderNumber),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.charcoal,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                          child: Text(
                            'TRACK STATUS',
                            style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 9, letterSpacing: 1.0),
                          ),
                        ),
                      ],
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

  void _showReturnDialog(BuildContext context, OrderModel order) {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REQUEST RETURN',
                style: AppTextStyles.serifHeading1(color: AppColors.charcoal).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Order: ${order.orderNumber}',
                style: AppTextStyles.sansSubtitle(),
              ),
              const SizedBox(height: 20),
              Text(
                'Reason for Return',
                style: AppTextStyles.sansBody(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Size does not fit, defective item...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a return reason')),
                      );
                      return;
                    }
                    
                    final returnItems = order.items.map((item) => {
                      'orderItemId': item.id,
                      'quantity': item.quantity,
                      'reason': reason,
                    }).toList();
                    
                    final success = await _orderService.requestReturn(
                      orderId: order.id,
                      returnItems: returnItems,
                    );
                    
                    Navigator.pop(context); // close bottom sheet
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Return request submitted successfully!'),
                        ),
                      );
                      _loadOrders(); // Reload orders
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text('Failed to submit return request.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'SUBMIT RETURN REQUEST',
                    style: AppTextStyles.uppercaseLabel(color: Colors.white, fontSize: 10, letterSpacing: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
