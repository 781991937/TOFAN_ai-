import 'package:flutter/material.dart';

import '../data/academic/academic_catalog.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOFAN SMART ACADEMY',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: primary, fontWeight: FontWeight.w800, letterSpacing: .5)),
                        const SizedBox(height: 4),
                        Text('مساحتك الذكية للتعلم',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withValues(alpha: .22)),
                    ),
                    child: Icon(Icons.auto_awesome, color: primary),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.psychology_outlined, color: primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('TOFAN AI',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                          Icon(Icons.arrow_forward_ios, size: 15, color: primary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('الطالب البشري + الطالب الذكي',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        'تعلم، طبّق، قيّم مستواك، وطوّر المعرفة والمهارات والقدرات مع نواة الذكاء.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('ابدأ جلسة التعلم'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('نظرة سريعة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatCard(value: AcademicCatalog.courseCount.toString(), label: 'مقررات')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: AcademicCatalog.lessonCount.toString(), label: 'دروس')),
                  const SizedBox(width: 10),
                  const Expanded(child: _StatCard(value: '1', label: 'تخصص مرجعي')),
                ],
              ),
              const SizedBox(height: 18),
              Text('المسار الأكاديمي', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: const [
                    _PathItem(icon: Icons.account_balance_outlined, title: 'المكتبة الأكاديمية', subtitle: 'جامعة → كلية → تخصص → سنة → فصل'),
                    _PathItem(icon: Icons.menu_book_outlined, title: 'المقرر والدروس', subtitle: 'محتوى أكاديمي منظم وقابل للتوسع'),
                    _PathItem(icon: Icons.analytics_outlined, title: 'التشخيص والتقييم', subtitle: 'قياس المعرفة والمهارات والقدرات'),
                    _PathItem(icon: Icons.rocket_launch_outlined, title: 'المشاريع', subtitle: 'تحويل التعلم إلى تطبيق عملي'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PathItem extends StatelessWidget {
  const _PathItem({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
    );
  }
}