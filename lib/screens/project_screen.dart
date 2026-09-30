import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/learning/learning_state.dart';
import '../domain/academic/academic_models.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key, required this.project});
  final AcademicProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المشروع')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.rocket_launch_outlined,
                        color: theme.colorScheme.primary, size: 34),
                    const SizedBox(height: 14),
                    Text(project.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(project.description,
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.construction_outlined,
                    color: theme.colorScheme.primary),
                title: const Text('مرحلة المشروع',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text(
                  'يتم تنفيذ المشروع وفق المتطلبات الأكاديمية المرتبطة به.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ref.read(learningSessionProvider.notifier).completeProject();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('إكمال المشروع وتسجيل التقدم'),
            ),
          ],
        ),
      ),
    );
  }
}
