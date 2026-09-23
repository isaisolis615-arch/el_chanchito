import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    final currency = ref.watch(currencyProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    profile.nombre.isNotEmpty ? profile.nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(profile.nombre, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (profile.email != null) ...[
                  const SizedBox(height: 4),
                  Text(profile.email!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: theme.colorScheme.primary),
                  title: const Text('Nombre'),
                  subtitle: Text(profile.nombre),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editNombre(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email, color: theme.colorScheme.primary),
                  title: const Text('Email'),
                  subtitle: Text(profile.email ?? 'No configurado'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editEmail(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Preferencias Regionales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Icon(Icons.currency_exchange, color: theme.colorScheme.primary),
                  title: const Text('Moneda'),
                  subtitle: Text('${currency.name} (${currency.symbol})'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectCurrency(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language, color: theme.colorScheme.primary),
                  title: const Text('Idioma'),
                  subtitle: Text(language.nativeName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectLanguage(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette, color: theme.colorScheme.primary),
                  title: const Text('Tema'),
                  subtitle: Text(profile.modoOscuro ? 'Modo Oscuro' : 'Modo Claro'),
                  trailing: Switch(
                    value: profile.modoOscuro,
                    onChanged: (valor) {
                      ref.read(userProfileProvider.notifier).updateModoOscuro(valor);
                      ref.read(themeServiceProvider).setThemeMode(valor ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications, color: theme.colorScheme.primary),
                  title: const Text('Notificaciones'),
                  subtitle: Text(profile.notificacionesActivas ? 'Activadas' : 'Desactivadas'),
                  trailing: Switch(
                    value: profile.notificacionesActivas,
                    onChanged: (valor) => ref.read(userProfileProvider.notifier).updateNotificaciones(valor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  void _editNombre(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(userProfileProvider).nombre);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nombre'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(userProfileProvider.notifier).updateNombre(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editEmail(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(userProfileProvider).email ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Email'),
        content: TextField(controller: controller, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final email = controller.text.trim();
              final updated = ref.read(userProfileProvider).copyWith(email: email.isEmpty ? null : email);
              ref.read(userProfileProvider.notifier).update(updated);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _selectCurrency(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final profile = ref.watch(userProfileProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Seleccionar Moneda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...Currency.supported.map((c) => RadioListTile<String>(
                title: Text('${c.name} (${c.symbol})'),
                subtitle: Text('Código: ${c.code}'),
                value: c.code,
                groupValue: profile.currencyCode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(userProfileProvider.notifier).updateCurrency(value);
                    Navigator.pop(context);
                  }
                },
              )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _selectLanguage(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final currentProfile = ref.watch(userProfileProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Seleccionar Idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...AppLanguage.supported.map((l) => RadioListTile<String>(
                title: Text(l.nativeName),
                subtitle: Text(l.name),
                value: l.code,
                groupValue: currentProfile.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(userProfileProvider.notifier).updateLanguage(value);
                    Navigator.pop(context);
                  }
                },
              )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Se cerrará la sesión actual. Los datos locales se mantendrán.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}