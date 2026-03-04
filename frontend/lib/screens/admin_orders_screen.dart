import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      if (authProvider.authToken != null) {
        adminProvider.fetchAllOrders(authToken: authProvider.authToken!);
      }
    });
  }

  Future<void> _updateOrderStatus(Order order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    const statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    String? selectedStatus = order.status;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ažuriraj статус наруџбе'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Наруџба ID: ${order.id}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: statuses
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(_getStatusLabel(s)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Статус',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отустани'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ажуриraj'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && selectedStatus != null && authProvider.authToken != null) {
      debugPrint('📋 Order update attempt:');
      debugPrint('   Order ID: ${order.id}');
      debugPrint('   Order ID type: ${order.id.runtimeType}');
      debugPrint('   New status: $selectedStatus');
      debugPrint('   Admin: ${authProvider.isAdmin}');
      final success = await adminProvider.updateOrderStatus(
        orderId: order.id,
        status: selectedStatus!,
        authToken: authProvider.authToken!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Статус је ажуриран' : 'Грешка при ажурирању'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _getStatusLabel(String status) {
    const labels = {
      'pending': '⏳ На чекању',
      'processing': '🔄 Обрада',
      'shipped': '📦 Послато',
      'delivered': '✅ Достављено',
      'cancelled': '❌ Отказано',
    };
    return labels[status] ?? status;
  }

  Color _getStatusColor(String status) {
    const colors = {
      'pending': Colors.orange,
      'processing': Colors.blue,
      'shipped': Colors.purple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    return colors[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin – Наруџбе')),
        body: const Center(
          child: Text('Приступ је дозвољен само администраторима'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin – Наруџбе'),
        centerTitle: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading && adminProvider.allOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null && adminProvider.allOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      adminProvider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        if (authProvider.authToken != null) {
                          adminProvider.fetchAllOrders(
                            authToken: authProvider.authToken!,
                          );
                        }
                      },
                      child: const Text('Покушај поново'),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = adminProvider.allOrders;

          if (orders.isEmpty) {
            return const Center(child: Text('Нема наруџби'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Наруџба #${order.id.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.totalPrice.toStringAsFixed(2)} РСД',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(order.status),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('ID наруџбе', order.id),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Датум',
                            order.createdAt?.toLocal().toString().split('.')[0] ?? 'Неизвесно',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Адреса', order.shippingAddress),
                          const SizedBox(height: 12),
                          _buildDetailRow('Телефон', order.shippingPhone),
                          const SizedBox(height: 12),
                          _buildDetailRow('Начин плаћања', order.paymentMethod),
                          const SizedBox(height: 12),
                          const Text(
                            'Артикли:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '• ${item.productName} x${item.quantity} = ${(item.price * item.quantity).toStringAsFixed(2)} РСД',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _updateOrderStatus(order),
                              icon: const Icon(Icons.edit),
                              label: const Text('Ажуриraj статус'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
