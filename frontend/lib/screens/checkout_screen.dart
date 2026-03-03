import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;

  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Попуните сва поља!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated || authProvider.authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Морате бити пријављени да направите наруџбину'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Create order
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser?.id ?? '',
      items: cartProvider.items
          .map((cartItem) => OrderItem(
                productId: cartItem.product.id,
                productName: cartItem.product.name,
                price: cartItem.product.priceRSD,
                quantity: cartItem.quantity,
              ))
          .toList(),
      totalPrice: cartProvider.totalPrice,
      status: 'pending',
      createdAt: DateTime.now(),
      shippingAddress:
          '${_addressController.text}, ${_cityController.text} ${_postalCodeController.text}',
      shippingPhone: _phoneController.text,
      paymentMethod: _selectedPaymentMethod,
    );

    // Send order to backend API
    final success = await orderProvider.createOrder(
      order: order,
      authToken: authProvider.authToken!,
    );

    if (!mounted) return;

    if (success) {
      // Clear cart
      cartProvider.clearCart();

      setState(() => _isLoading = false);

      // Navigate to confirmation screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Грешка при креирању наруџбине'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Наручивање'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Text(
              'Преглед наруџбе',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...cartProvider.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: theme.textTheme.bodyMedium),
                                  Text('${item.quantity}x',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey,
                                          )),
                                ],
                              ),
                            ),
                            Text(
                              '${item.totalPrice.toStringAsFixed(0)} дин',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  Divider(color: Colors.grey.shade300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Укупно',
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                      Text(
                        '${cartProvider.totalPrice.toStringAsFixed(0)} дин',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shipping info
            Text(
              'Подаци за доставу',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Име и презиме',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Емаил',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Адреса',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Град',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Поштански број',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment method
            Text(
              'Начин плаћања',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'cash',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                  const Text('Готина при преузимању'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = 'card'),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                  const Text('Платна картица'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place order button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _handlePlaceOrder,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Потврди наруџбу'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Отпусти'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
