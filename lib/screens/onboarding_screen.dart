import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  int _currentStep = 0;

  final List<_OnboardingStep> _steps = [
    const _OnboardingStep(
      title: '¡Bienvenido a El Chanchito!',
      description: 'Tu app para organizar tus finanzas de forma simple y visual.',
      icon: Icons.savings,
    ),
    const _OnboardingStep(
      title: 'Organiza tu dinero en divisiones',
      description: 'Crea divisiones para separar tu dinero: gastos, ahorros, inversiones, etc.',
      icon: Icons.account_balance_wallet,
    ),
    const _OnboardingStep(
      title: 'Registra ingresos y egresos',
      description: 'Añade transacciones fácilmente y visualiza tu balance al instante.',
      icon: Icons.receipt_long,
    ),
    const _OnboardingStep(
      title: 'Programa transacciones recurrentes',
      description: 'Configura ingresos y egresos recurrentes (sueldo, alquiler, suscripciones).',
      icon: Icons.schedule,
    ),
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep < _steps.length) {
      return _buildStepScreen(context);
    } else {
      return _buildProfileForm(context);
    }
  }

  Widget _buildStepScreen(BuildContext context) {
    final step = _steps[_currentStep];
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(step.icon, size: 100, color: theme.colorScheme.primary),
              const SizedBox(height: 32),
              Text(
                step.title,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Atrás'),
                    )
                  else
                    const SizedBox.shrink(),
                  FilledButton(
                    onPressed: () => setState(() => _currentStep++),
                    child: Text(_currentStep == _steps.length - 1 ? 'Empezar' : 'Siguiente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Completa tu perfil', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Esta información se usará para personalizar tu experiencia', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (opcional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 32),
FilledButton(
                onPressed: () async {
                  if (_nombreController.text.trim().isEmpty) return;
                  final profile = ref.read(userProfileProvider);
                  final updated = profile.copyWith(
                    nombre: _nombreController.text.trim(),
                    email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                  );
                  await ref.read(userProfileProvider.notifier).update(updated);
                  if (!mounted) return;
                  context.go('/');
                },
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Guardar y entrar', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}