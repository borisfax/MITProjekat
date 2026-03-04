import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      if (authProvider.authToken != null) {
        adminProvider.fetchAllUsers(authToken: authProvider.authToken!);
      }
    });
  }

  Future<void> _showUserDialog({User? user}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');
    String selectedRole = user?.role ?? 'user';
    final formKey = GlobalKey<FormState>();

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(user == null ? 'Нов корисник' : 'Измени корисника'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Име'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Име је обавезно'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return 'Email је обавезан';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value))
                            return 'Унесите важећи email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Адреса'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Улога'),
                        items: [
                          const DropdownMenuItem(
                            value: 'user',
                            child: Text('Корисник'),
                          ),
                          const DropdownMenuItem(
                            value: 'admin',
                            child: Text('Администратор'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedRole = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отустани'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (authProvider.authToken == null) {
                      Navigator.of(context).pop(false);
                      return;
                    }

                    bool success;
                    if (user == null) {
                      // Can't create user from admin panel (needs password)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Нови кориснички налози се морају kreirati кроз регистрацију',
                          ),
                        ),
                      );
                      Navigator.of(context).pop(false);
                      return;
                    } else {
                      debugPrint('DEBUG: Pokušavam da ažuriram korisnika: ${user.id}');
                      success = await adminProvider.updateUser(
                        userId: user.id,
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                        authToken: authProvider.authToken!,
                      );
                      debugPrint('DEBUG: Rezultat iz providera: $success');
                    }

                    if (!mounted) return;
                    Navigator.of(context).pop(success);
                  },
                  child: const Text('Сачувај'),
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
          saved ? 'Корисник је ажуриран' : 'Акција није успела',
        ),
        backgroundColor: saved ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(User user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    debugPrint('🗑️  Delete attempt:');
    debugPrint('   User ID: ${user.id}');
    debugPrint('   User email: ${user.email}');
    debugPrint('   Current user is admin: ${authProvider.isAdmin}');
    debugPrint('   Auth token present: ${authProvider.authToken != null}');

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обриши корисника'),
        content: Text(
          'Да ли сте сигурни да желите да оброшите "${user.name}"? Ова акција се не може опозвати.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Не'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Да, обриши'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    if (authProvider.authToken == null) {
      debugPrint('❌ No auth token');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Истекла је ваша сесија. Пријавите се поново.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('🗑️  Sending delete request...');
    final success = await adminProvider.deleteUser(
      userId: user.id,
      authToken: authProvider.authToken!,
    );

    if (!mounted) return;
    
    debugPrint('🗑️  Delete result: $success');
    debugPrint('🗑️  Error message: ${adminProvider.error}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success 
            ? 'Корисник је обрисан' 
            : (adminProvider.error ?? 'Брисање није успело'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin – Ћориници')),
        body: const Center(
          child: Text('Приступ је дозвољен само администраторима'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin – Корисници'),
        centerTitle: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading && adminProvider.allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null && adminProvider.allUsers.isEmpty) {
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
                          adminProvider.fetchAllUsers(
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

          final users = adminProvider.allUsers;

          if (users.isEmpty) {
            return const Center(child: Text('Нема корисника'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              final isAdmin = user.role == 'admin';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.purple : Colors.blue,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        isAdmin ? 'Администратор' : 'Кориcник',
                        style: TextStyle(
                          fontSize: 11,
                          color: isAdmin ? Colors.purple : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Измени',
                          onPressed: () => _showUserDialog(user: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Обриши',
                          onPressed: () => _confirmDelete(user),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
