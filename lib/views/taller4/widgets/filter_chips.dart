import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/task_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'Todas',
                isSelected: provider.filter == TaskFilter.all,
                onTap: () => provider.setFilter(TaskFilter.all),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Pendientes',
                isSelected: provider.filter == TaskFilter.pending,
                onTap: () => provider.setFilter(TaskFilter.pending),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Completadas',
                isSelected: provider.filter == TaskFilter.completed,
                onTap: () => provider.setFilter(TaskFilter.completed),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
