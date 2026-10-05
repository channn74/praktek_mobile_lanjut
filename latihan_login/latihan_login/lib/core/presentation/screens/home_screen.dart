import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/colors.dart';
import '../../data/database/database_helper.dart';
import '../../utils/app_snack_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

/// Halaman dashboard setelah login berhasil. Menampilkan data user
/// yang sedang login beserta daftar seluruh pengguna dari database.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user, required this.onLogout});

  final Map<String, Object?> user;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, Object?>>> _usersFuture;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseHelper.getAllUsers();
  }

  String _read(String key, [String fallback = '-']) {
    final value = widget.user[key];
    return value == null ? fallback : value.toString();
  }

  Future<void> _reload() async {
    setState(() => _usersFuture = DatabaseHelper.getAllUsers());
  }

  Future<void> _confirmDelete(Map<String, Object?> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus akun'),
        content: Text(
          '${AppConstants.msgConfirmDeleteAccount}\n\n'
          'Email: ${user[AppConstants.columnEmail]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final id = user[AppConstants.columnId] as int?;
    if (id == null) return;

    await DatabaseHelper.deleteUser(id);
    if (!mounted) return;

    AppSnackBar.success(context, AppConstants.msgAccountDeleted);
    await _reload();

    // Bila akun yang sedang login ikut dihapus, arahkan ke login.
    if (widget.user[AppConstants.columnId] == id) {
      widget.onLogout();
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    // Tutup koneksi agar sesi berikutnya membuka database baru.
    await DatabaseHelper.close();
    if (!mounted) return;
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final name = _read(AppConstants.columnName);
    final email = _read(AppConstants.columnEmail);
    final createdAt = _read(AppConstants.columnCreatedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          IconButton(
            tooltip: AppConstants.buttonRefresh,
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.formMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Divider(height: 32),
                        _InfoRow(
                          label: 'ID',
                          value: _read(AppConstants.columnId),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Terdaftar', value: createdAt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppConstants.registeredUsers,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUserList(),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppConstants.buttonLogout,
                    icon: Icons.logout,
                    backgroundColor: AppColors.error,
                    isLoading: _isLoggingOut,
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Daftar pengguna hasil query ke tabel `user`.
  Widget _buildUserList() {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppConstants.msgDatabaseError}: ${snapshot.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final users = snapshot.data ?? const <Map<String, Object?>>[];

        if (users.isEmpty) {
          return CustomCard(
            child: Text(
              AppConstants.noUserData,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return CustomCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(children: users.map(_buildUserTile).toList()),
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, Object?> user) {
    final id = user[AppConstants.columnId] as int?;

    return ListTile(
      leading: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, size: 18, color: Colors.white),
      ),
      title: Text(
        '${user[AppConstants.columnName]}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text('${user[AppConstants.columnEmail]}'),
      trailing: id == null
          ? null
          : IconButton(
              tooltip: AppConstants.buttonDeleteAccount,
              onPressed: () => _confirmDelete(user),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
    );
  }
}

/// Baris label-value sederhana untuk menampilkan detail profil.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
