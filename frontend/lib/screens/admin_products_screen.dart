import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  static const List<String> _categories = ['Bombone', 'Čokolada', 'Mafini'];

  String _imageLabel(String url, int index) {
    final cleaned = url.trim();
    if (cleaned.isEmpty) return 'Slika ${index + 1}';

    final fileName = cleaned.split('/').isNotEmpty ? cleaned.split('/').last : cleaned;
    if (fileName.isEmpty) return 'Slika ${index + 1}';

    if (fileName.length > 24) {
      return 'Slika ${index + 1} • ${fileName.substring(0, 24)}...';
    }
    return 'Slika ${index + 1} • $fileName';
  }

  Product? _productForImageUrl(ProductProvider provider, String url) {
    final normalized = url.trim();
    for (final product in provider.products) {
      if (product.imageUrl.trim() == normalized) {
        return product;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _showProductDialog({Product? product}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
      text: product != null ? product.priceRSD.toStringAsFixed(0) : '',
    );

    final existingImageUrls = productProvider.products
        .map((p) => p.imageUrl.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    String selectedImageUrl = (product?.imageUrl ?? '').trim();
    if (selectedImageUrl.isNotEmpty &&
        !existingImageUrls.contains(selectedImageUrl)) {
      existingImageUrls.insert(0, selectedImageUrl);
    }
    if (selectedImageUrl.isEmpty && existingImageUrls.isNotEmpty) {
      selectedImageUrl = existingImageUrls.first;
    }

    String selectedCategory = product?.category ?? _categories.first;
    int stock = product?.inStock == true ? 1 : 0;
    bool isAvailable = product?.inStock ?? true;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:
                  Text(product == null ? 'Novi proizvod' : 'Izmeni proizvod'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Naziv'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Naziv je obavezan'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Opis'),
                        maxLines: 2,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Opis je obavezan'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        decoration:
                            const InputDecoration(labelText: 'Cena (RSD)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return 'Cena je obavezna';
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 0)
                            return 'Unesite validnu cenu';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Kategorija'),
                        items: _categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (existingImageUrls.isEmpty)
                        const Text(
                          'Nema dostupnih slika iz postojećih proizvoda.',
                          style: TextStyle(color: Colors.red),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: selectedImageUrl,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Slika proizvoda (iz shopa)'),
                          selectedItemBuilder: (context) {
                            return existingImageUrls.asMap().entries.map((entry) {
                              final index = entry.key;
                              final url = entry.value;
                              final imageProduct =
                                  _productForImageUrl(productProvider, url);
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        url,
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 22,
                                          height: 22,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.broken_image_outlined, size: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        imageProduct != null
                                            ? '${imageProduct.name} • ${imageProduct.category}'
                                            : _imageLabel(url, index),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          items: existingImageUrls.asMap().entries
                              .map((entry) {
                                final index = entry.key;
                                final url = entry.value;
                                final imageProduct =
                                    _productForImageUrl(productProvider, url);
                                return DropdownMenuItem<String>(
                                    value: url,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            url,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 24,
                                              height: 24,
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.broken_image_outlined, size: 14),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                imageProduct?.name ??
                                                    _imageLabel(url, index),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                imageProduct?.category ?? 'Bez kategorije',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.grey.shade600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                              })
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              selectedImageUrl = value;
                            });
                          },
                        ),
                      if (selectedImageUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  selectedImageUrl,
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 56,
                                    width: 56,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedImageUrl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '$stock',
                              decoration:
                                  const InputDecoration(labelText: 'Stock'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                setDialogState(() {
                                  stock =
                                      parsed == null || parsed < 0 ? 0 : parsed;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isAvailable,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      isAvailable = value ?? true;
                                    });
                                  },
                                ),
                                const Flexible(child: Text('Dostupan')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Otkaži'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final authToken = authProvider.authToken;
                    if (authToken == null) {
                      Navigator.of(context).pop(false);
                      return;
                    }

                    final parsedPrice =
                        double.parse(priceController.text.trim());

                    if (selectedImageUrl.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Izaberite sliku iz postojećih proizvoda'),
                        ),
                      );
                      return;
                    }

                    bool success;
                    if (product == null) {
                      success = await productProvider.createProduct(
                        authToken: authToken,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: parsedPrice,
                        category: selectedCategory,
                        imageUrl: selectedImageUrl.trim(),
                        stock: stock,
                        isAvailable: isAvailable,
                      );
                    } else {
                      success = await productProvider.updateProduct(
                        authToken: authToken,
                        productId: product.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: parsedPrice,
                        category: selectedCategory,
                        imageUrl: selectedImageUrl.trim(),
                        stock: stock,
                        isAvailable: isAvailable,
                      );
                    }

                    if (!mounted) return;
                    Navigator.of(context).pop(success);
                  },
                  child: Text(product == null ? 'Sačuvaj' : 'Ažuriraj'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || saved == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? (product == null
                  ? 'Proizvod je kreiran'
                  : 'Proizvod je ažuriran')
              : 'Akcija nije uspela',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši proizvod'),
        content:
            Text('Da li ste sigurni da želite da obrišete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Da, obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authToken = authProvider.authToken;
    if (authToken == null) return;

    final success = await productProvider.deleteProduct(
      authToken: authToken,
      productId: product.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Proizvod je obrisan' : 'Brisanje nije uspelo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin panel')),
        body: const Center(
          child: Text('Pristup je dozvoljen samo administratorima.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin panel - Proizvodi'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null &&
              productProvider.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productProvider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => productProvider.fetchProducts(),
                      child: const Text('Pokušaj ponovo'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return const Center(child: Text('Nema proizvoda u bazi.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              final bool isAsset = product.imageUrl.startsWith('assets/');
              final bool isUrl = product.imageUrl.startsWith('http://') ||
                  product.imageUrl.startsWith('https://');
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: isAsset
                        ? AssetImage(product.imageUrl) as ImageProvider<Object>
                        : (isUrl ? NetworkImage(product.imageUrl) as ImageProvider<Object> : null),
                    onBackgroundImageError: (isAsset || isUrl) ? (_, __) {} : null,
                    child: (!isAsset && !isUrl) || product.imageUrl.isEmpty
                        ? const Icon(Icons.image_outlined)
                        : null,
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                      '${product.category} • ${product.priceRSD.toStringAsFixed(0)} RSD'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Izmeni',
                        onPressed: () => _showProductDialog(product: product),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Obriši',
                        onPressed: () => _confirmDelete(product),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj proizvod'),
      ),
    );
  }
}
