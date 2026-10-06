import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = [
      _HelpSection(
        title: '🏠 Inicio',
        items: [
          _HelpItem('Resumen general', 'Vista general de tus divisiones, balance total y movimientos recientes.'),
          _HelpItem('Balance', 'Verde = ingresos totales, Rojo = egresos totales, Balance = diferencia.'),
          _HelpItem('Accesos rápidos', 'Botón flotante (+) para nueva transacción. Drawer (☰) para navegación.'),
        ],
      ),
      _HelpSection(
        title: '💼 Divisiones (Pestaña "Mis Divisiones")',
        items: [
          _HelpItem('Qué son', 'Son contenedores para separar tu dinero: Gastos, Ahorros, Inversiones, etc.'),
          _HelpItem('Crear', 'Botón "+" en la lista o FAB en pantalla de divisiones. Elige nombre, icono, color y saldo inicial.'),
          _HelpItem('Editar/Eliminar', 'Menú ⋮ en cada tarjeta → Editar/Duplicar/Eliminar.'),
          _HelpItem('Detalle', 'Toca una división para ver sus movimientos y balance individual.'),
        ],
      ),
      _HelpSection(
        title: '💰 Transacciones (Ingresos / Egresos)',
        items: [
          _HelpItem('Crear', 'Botón flotante (+) → Ingreso o Egreso.'),
          _HelpItem('Campos', 'Monto (obligatorio), Motivo, División destino, Categoría, Lugar (solo egresos).'),
          _HelpItem('Montos rápidos', 'Botones de acceso rápido: \$10, \$50, \$100, \$500, \$1000.'),
          _HelpItem('Categorías', 'Chips de selección rápida: 🍔 Comida, 🚌 Transporte, 💡 Servicios, etc.'),
          _HelpItem('Filtrar', 'Chips superiores: Todo/Ingresos/Egresos/Programados. Chips de tiempo: 7d/30d/90d. Buscador por texto.'),
          _HelpItem('Eliminar', 'Mantener presionado (long press) en un movimiento → Eliminar (recalcula saldo).'),
        ],
      ),
      _HelpSection(
        title: '⏰ Transacciones Programadas',
        items: [
          _HelpItem('Qué son', 'Transacciones que se ejecutan automáticamente en fechas recurrentes (sueldo, alquiler, suscripciones).'),
          _HelpItem('Crear', 'FAB (+) → "Transacción Programada" o desde pantalla Programadas.'),
          _HelpItem('Frecuencias', 'Diaria, Semanal, Quincenal, Mensual, Trimestral, Anual, Personalizada.'),
          _HelpItem('Gestión', 'Lista con toggle Activo/Inactivo. Ver próximas ejecuciones. Editar/Eliminar.'),
          _HelpItem('Notificaciones', 'Recibes aviso cuando se ejecuta (salvo en web). Se activa/desactiva en Perfil/Ajustes.'),
        ],
      ),
      _HelpSection(
        title: '👤 Perfil y Configuración',
        items: [
          _HelpItem('Perfil', 'Nombre, Email, Moneda (12 opciones), Idioma (ES/EN/PT), Tema Claro/Oscuro.'),
          _HelpItem('Moneda', '12 monedas: USD, ARS, EUR, MXN, COP, CLP, PEN, UYU, BRL, GBP, CAD, AUD.'),
          _HelpItem('Idioma', 'Español, English, Português.'),
          _HelpItem('Tema', 'Claro / Oscuro / Sistema. Cambio instantáneo y persistente.'),
          _HelpItem('Notificaciones', 'Activa/desactiva avisos de transacciones programadas.'),
          _HelpItem('Ajustes avanzados', 'Retención de historial (7d/30d/90d/Siempre), Exportar CSV, Borrar todo.'),
          _HelpItem('Cerrar sesión', 'Borra perfil local pero mantiene datos financieros. Vuelve a onboarding.'),
        ],
      ),
      _HelpSection(
        title: '🔔 Notificaciones',
        items: [
          _HelpItem('Qué avisan', 'Ejecución de transacciones programadas (sueldo, alquiler, suscripciones).'),
          _HelpItem('Cuándo', 'En segundo plano aunque la app esté cerrada (nativo). En web: solo al abrir la app.'),
          _HelpItem('Control', 'Activa/desactiva en Perfil → Notificaciones o Ajustes → Notificaciones.'),
          _HelpItem('Icono ℹ️', 'Toca el icono ⓘ junto al switch para ver esta explicación detallada.'),
        ],
      ),
      _HelpSection(
        title: '💡 Tips y Trucos',
        items: [
          _HelpItem('Duplicar división', 'Menú ⋮ → Duplicar (copia nombre, icono, color, saldo=0).'),
          _HelpItem('Filtros combinados', 'Combina filtro de Tipo (Ingresos/Egresos) + Tiempo (7d/30d) + Búsqueda.'),
          _HelpItem('Exportar CSV', 'Ajustes → Exportar Historial a CSV → Se copia al portapapeles para Excel.'),
          _HelpItem('Retención', 'Ajustes → Conservar historial por: 7d/30d/90d/Siempre. Limpieza automática.'),
          _HelpItem('Duplicar transacción', 'No hay botón directo, pero crea nueva con mismos datos rápidos.'),
          _HelpItem('Respaldo', 'Datos en SharedPreferences local. Exporta CSV periódicamente como respaldo.'),
        ],
      ),
      _HelpSection(
        title: '❓ Preguntas Frecuentes',
        items: [
          _HelpItem('¿Se pierden datos al actualizar?', 'No, datos en SharedPreferences local persisten entre actualizaciones.'),
          _HelpItem('¿Multi-dispositivo?', 'No hay sincronización en la nube aún. Cada dispositivo es independiente.'),
          _HelpItem('¿Múltiples perfiles?', 'No hay soporte multi-perfil aún. Un perfil por dispositivo.'),
          _HelpItem('¿Backup?', 'Exporta CSV regularmente. No hay backup automático en la nube aún.'),
          _HelpItem('¿Eliminé una división por error?', 'No hay "papelera". Recrea la división manualmente.'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Guía de El Chanchito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Buscar en la guía',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return _HelpSectionWidget(section: section);
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar en la guía'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Buscar...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (query) {
            Navigator.pop(context);
            _showSearchResults(context, query);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void _showSearchResults(BuildContext context, String query) {
    final results = <_SearchResult>[];
    final queryLower = query.toLowerCase();
    for (final section in _getAllSections()) {
      for (final item in section.items) {
        if (item.title.toLowerCase().contains(queryLower) ||
            item.description.toLowerCase().contains(queryLower)) {
          results.add(_SearchResult(sectionTitle: section.title, item: item));
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultados para "$query" (${results.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(
                title: Text(r.item.title),
                subtitle: Text(r.sectionTitle),
                onTap: () {
                  Navigator.pop(context);
                  // Could navigate to specific section
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  List<_HelpSection> _getAllSections() {
    return [
      _HelpSection(title: '🏠 Inicio', items: [
        _HelpItem('Resumen general', 'Vista general de tus divisiones, balance total y movimientos recientes.'),
        _HelpItem('Balance', 'Verde = ingresos totales, Rojo = egresos totales, Balance = diferencia.'),
        _HelpItem('Accesos rápidos', 'Botón flotante (+) para nueva transacción. Drawer (☰) para navegación.'),
      ]),
      _HelpSection(title: '💼 Divisiones (Pestaña "Mis Divisiones")', items: [
        _HelpItem('Qué son', 'Son contenedores para separar tu dinero: Gastos, Ahorros, Inversiones, etc.'),
        _HelpItem('Crear', 'Botón "+" en la lista o FAB en pantalla de divisiones. Elige nombre, icono, color y saldo inicial.'),
        _HelpItem('Editar/Eliminar', 'Menú ⋮ en cada tarjeta → Editar/Duplicar/Eliminar.'),
        _HelpItem('Detalle', 'Toca una división para ver sus movimientos y balance individual.'),
      ]),
      _HelpSection(title: '💰 Transacciones (Ingresos / Egresos)', items: [
        _HelpItem('Crear', 'Botón flotante (+) → Ingreso o Egreso.'),
        _HelpItem('Campos', 'Monto (obligatorio), Motivo, División destino, Categoría, Lugar (solo egresos).'),
        _HelpItem('Montos rápidos', 'Botones de acceso rápido: \$10, \$50, \$100, \$500, \$1000.'),
        _HelpItem('Categorías', 'Chips de selección rápida: 🍔 Comida, 🚌 Transporte, 💡 Servicios, etc.'),
        _HelpItem('Filtrar', 'Chips superiores: Todo/Ingresos/Egresos/Programados. Chips de tiempo: 7d/30d/90d. Buscador por texto.'),
        _HelpItem('Eliminar', 'Mantener presionado (long press) en un movimiento → Eliminar (recalcula saldo).'),
      ]),
      _HelpSection(title: '⏰ Transacciones Programadas', items: [
        _HelpItem('Qué son', 'Transacciones que se ejecutan automáticamente en fechas recurrentes (sueldo, alquiler, suscripciones).'),
        _HelpItem('Crear', 'FAB (+) → "Transacción Programada" o desde pantalla Programadas.'),
        _HelpItem('Frecuencias', 'Diaria, Semanal, Quincenal, Mensual, Trimestral, Anual, Personalizada.'),
        _HelpItem('Gestión', 'Lista con toggle Activo/Inactivo. Ver próximas ejecuciones. Editar/Eliminar.'),
        _HelpItem('Notificaciones', 'Recibes aviso cuando se ejecuta (salvo en web). Se activa/desactiva en Perfil/Ajustes.'),
      ]),
      _HelpSection(title: '👤 Perfil y Configuración', items: [
        _HelpItem('Perfil', 'Nombre, Email, Moneda (12 opciones), Idioma (ES/EN/PT), Tema Claro/Oscuro.'),
        _HelpItem('Moneda', '12 monedas: USD, ARS, EUR, MXN, COP, CLP, PEN, UYU, BRL, GBP, CAD, AUD.'),
        _HelpItem('Idioma', 'Español, English, Português.'),
        _HelpItem('Tema', 'Claro / Oscuro / Sistema. Cambio instantáneo y persistente.'),
        _HelpItem('Notificaciones', 'Activa/desactiva avisos de transacciones programadas.'),
        _HelpItem('Ajustes avanzados', 'Retención de historial (7d/30d/90d/Siempre), Exportar CSV, Borrar todo.'),
        _HelpItem('Cerrar sesión', 'Borra perfil local pero mantiene datos financieros. Vuelve a onboarding.'),
      ]),
      _HelpSection(title: '🔔 Notificaciones', items: [
        _HelpItem('Qué avisan', 'Ejecución de transacciones programadas (sueldo, alquiler, suscripciones).'),
        _HelpItem('Cuándo', 'En segundo plano aunque la app esté cerrada (nativo). En web: solo al abrir la app.'),
        _HelpItem('Control', 'Activa/desactiva en Perfil → Notificaciones o Ajustes → Notificaciones.'),
        _HelpItem('Icono ℹ️', 'Toca el icono ⓘ junto al switch para ver esta explicación detallada.'),
      ]),
      _HelpSection(title: '💡 Tips y Trucos', items: [
        _HelpItem('Duplicar división', 'Menú ⋮ → Duplicar (copia nombre, icono, color, saldo=0).'),
        _HelpItem('Filtros combinados', 'Combina filtro de Tipo (Ingresos/Egresos) + Tiempo (7d/30d) + Búsqueda.'),
        _HelpItem('Exportar CSV', 'Ajustes → Exportar Historial a CSV → Se copia al portapapeles para Excel.'),
        _HelpItem('Retención', 'Ajustes → Conservar historial por: 7d/30d/90d/Siempre. Limpieza automática.'),
        _HelpItem('Duplicar transacción', 'No hay botón directo, pero crea nueva con mismos datos rápidos.'),
        _HelpItem('Respaldo', 'Datos en SharedPreferences local. Exporta CSV periódicamente como respaldo.'),
      ]),
      _HelpSection(title: '❓ Preguntas Frecuentes', items: [
        _HelpItem('¿Se pierden datos al actualizar?', 'No, datos en SharedPreferences local persisten entre actualizaciones.'),
        _HelpItem('¿Multi-dispositivo?', 'No hay sincronización en la nube aún. Cada dispositivo es independiente.'),
        _HelpItem('¿Múltiples perfiles?', 'No hay soporte multi-perfil aún. Un perfil por dispositivo.'),
        _HelpItem('¿Backup?', 'Exporta CSV regularmente. No hay backup automático en la nube aún.'),
        _HelpItem('¿Eliminé una división por error?', 'No hay "papelera". Recrea la división manualmente.'),
      ]),
    ];
  }
}

class _HelpSection {
  final String title;
  final List<_HelpItem> items;

  _HelpSection({required this.title, required this.items});
}

class _HelpItem {
  final String title;
  final String description;

  _HelpItem(this.title, this.description);
}

class _SearchResult {
  final String sectionTitle;
  final _HelpItem item;

  _SearchResult({required this.sectionTitle, required this.item});
}

class _HelpSectionWidget extends StatelessWidget {
  final _HelpSection section;

  const _HelpSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(section.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: section.items.map((item) => _HelpItemWidget(item: item)).toList(),
      ),
    );
  }
}

class _HelpItemWidget extends StatelessWidget {
  final _HelpItem item;

  const _HelpItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(item.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Divider(height: 16),
        ],
      ),
    );
  }
}