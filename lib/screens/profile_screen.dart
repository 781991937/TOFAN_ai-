import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/student/student_state.dart';
import '../utils/constants.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    final smart = ref.watch(smartStudentProvider);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الطالب الذكي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 44, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                profile?.name ?? 'طالب جديد',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                profile == null ? 'أكمل الملف الأكاديمي للبدء' : profile.specialization,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 20),
            if (profile == null)
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                ),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('إعداد الملف الأكاديمي'),
              )
            else
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(profile.university),
                  subtitle: Text(profile.college + ' — ' + profile.specialization),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('حالة الطالب الذكي', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _MetricCard(title: 'المعرفة', value: smart.knowledgeLevel),
            _MetricCard(title: 'المهارات', value: smart.skillLevel),
            _MetricCard(title: 'القدرات', value: smart.capabilityLevel),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department_outlined),
                title: const Text('سلسلة التعلم'),
                trailing: Text(smart.learningStreak.toString()),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppConstants.productName, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final double value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(value.toStringAsFixed(0) + '%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: value / 100),
            ],
          ),
        ),
      );
}
