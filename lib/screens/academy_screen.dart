import 'package:flutter/material.dart';

import '../data/academic/academic_catalog.dart';
import '../domain/academic/academic_models.dart';
import 'lesson_screen.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final university = AcademicCatalog.referenceUniversity;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المكتبة الأكاديمية'),
          actions: [
            IconButton(tooltip: 'بحث', onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _HeaderCard(university: university),
            const SizedBox(height: 16),
            for (final college in university.colleges) ...[
              _CollegeSection(college: college),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.university});
  final AcademicUniversity university;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.account_balance_outlined, size: 38, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(university.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'مرجع أكاديمي قابل للتوسع — وليس مقيداً بجامعة واحدة',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollegeSection extends StatelessWidget {
  const _CollegeSection({required this.college});
  final AcademicCollege college;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
        title: Text(college.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [
          for (final specialization in college.specializations)
            _SpecializationTile(specialization: specialization),
        ],
      ),
    );
  }
}

class _SpecializationTile extends StatelessWidget {
  const _SpecializationTile({required this.specialization});
  final AcademicSpecialization specialization;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.psychology_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(specialization.name),
      children: [
        for (final year in specialization.years)
          ExpansionTile(
            tilePadding: const EdgeInsets.only(right: 28, left: 16),
            title: Text('السنة ' + year.number.toString()),
            children: [
              for (final semester in year.semesters)
                ExpansionTile(
                  tilePadding: const EdgeInsets.only(right: 44, left: 16),
                  title: Text('الفصل ' + semester.number.toString()),
                  children: [
                    for (final course in semester.courses)
                      _CourseTile(course: course),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course});
  final AcademicCourse course;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(right: 60, left: 16),
      leading: Icon(Icons.menu_book_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(course.name),
      subtitle: Text(course.lessons.length.toString() + ' دروس'),
      trailing: const Icon(Icons.chevron_left),
      onTap: () => _showLessons(context),
    );
  }

  void _showLessons(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(course.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final lesson in course.lessons)
              ListTile(
                leading: Icon(lesson.isFree ? Icons.play_circle_outline : Icons.lock_outline),
                title: Text(lesson.title),
                subtitle: Text(lesson.isFree ? 'متاح' : 'مدفوع'),
                onTap: () {
                  if (!lesson.isFree) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(course: course, lesson: lesson),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
