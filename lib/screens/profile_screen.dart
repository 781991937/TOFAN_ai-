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
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('العبقري طوفان')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: primary.withValues(alpha: .14),
                      child: Icon(Icons.person_outline, size: 34, color: primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.name ?? 'طالب جديد',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(profile?.specialization ?? 'أكمل ملفك الأكاديمي للبدء',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'تعديل',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
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
                  leading: Icon(Icons.school_outlined, color: primary),
                  title: Text(profile.university, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(profile.college + ' — ' + profile.specialization),
                ),
              ),
            const SizedBox(height: 18),
            Text('حالة العبقري طوفان',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _MetricTile(title: 'المعرفة', value: smart.knowledgeLevel)),
                const SizedBox(width: 10),
                Expanded(child: _MetricTile(title: 'المهارات', value: smart.skillLevel)),
                const SizedBox(width: 10),
                Expanded(child: _MetricTile(title: 'القدرات', value: smart.capabilityLevel)),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_outlined, color: primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سلسلة التعلم', style: TextStyle(fontWeight: FontWeight.w800)),
                          Text('الاستمرارية في الدراسة والتطبيق'),
                        ],
                      ),
                    ),
                    Text(smart.learningStreak.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('هوية النظام', textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(AppConstants.productName, textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value});
  final String title;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Text(value.toStringAsFixed(0) + '%',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 9),
            LinearProgressIndicator(value: value / 100, minHeight: 5),
          ],
        ),
      ),
    );
  }
}