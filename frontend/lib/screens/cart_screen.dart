import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корпа'),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Испразни корпу',
                onPressed: () {
                  _showClearCartDialog(context, cart);
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, cart, item);
                  },
                ),
              ),
              _buildBottomBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Ваша корпа је празна',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Додајте производе из продавнице',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart, item) {
    final theme = Theme.of(context);
    final product = item.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.cake,
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.priceRSD.toStringAsFixed(0)} РСД',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (item.quantity > 1) {
                            cart.updateQuantity(product.id, item.quantity - 1);
                          } else {
                            cart.removeItem(product.id);
                          }
                        },
                        icon: Icon(
                          item.quantity > 1 ? Icons.remove : Icons.delete,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${item.quantity}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cart.updateQuantity(product.id, item.quantity + 1);
                        },
                        icon: const Icon(Icons.add, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const Spacer(),
                      // Total price for this item
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} РСД',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Укупно (${cart.itemCount} ${_getItemLabel(cart.itemCount)}):',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cart.totalPrice.toStringAsFixed(0)} РСД',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showCheckoutDialog(context);
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Наручи'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getItemLabel(int count) {
    if (count == 1) return 'производ';
    if (count >= 2 && count <= 4) return 'производа';
    return 'производа';
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Испразни корпу'),
        content: const Text('Да ли сте сигурни да желите да уклоните све производе из корпе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Откажи'),
          ),
          FilledButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Корпа је испражњена'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Испразни'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Наручивање'),
        content: const Text('Функционалност наручивања ће бити додата у следећој верзији.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('У реду'),
          ),
        ],
      ),
    );
  }
}
