import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learning/learning_state.dart';
import '../domain/academic/academic_models.dart';
import 'assessment_screen.dart';
import 'practice_screen.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.course, required this.lesson});

  final AcademicCourse course;
  final AcademicLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(learningSessionProvider);
    final active = session?.lessonId == lesson.id;
    final completed = active && session!.isCompleted;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(course.name)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: theme.colorScheme.primary, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(lesson.title,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lesson.isFree
                          ? 'هذا الدرس متاح ضمن المحتوى المجاني.'
                          : 'هذا الدرس مدفوع ويحتاج صلاحية الوصول.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  completed
                      ? Icons.check_circle_outline
                      : active
                          ? Icons.play_circle_outline
                          : Icons.radio_button_unchecked,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  completed
                      ? 'اكتملت جلسة الدراسة'
                      : active
                          ? 'جلسة الدراسة جارية'
                          : 'لم تبدأ الدراسة بعد',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  completed
                      ? 'تم تحديث مؤشرات الطالب الذكي.'
                      : 'ابدأ الجلسة لتسجيل تقدمك في هذا الدرس.',
                ),
              ),
            ),
            if (completed && lesson.practices.isNotEmpty)
              ...[
                const SizedBox(height: 18),
                Text('التطبيق العملي',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final practice in lesson.practices)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.code_rounded,
                          color: theme.colorScheme.primary),
                      title: Text(practice.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${practice.tasks.length} مهام'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeScreen(practice: practice),
                        ),
                      ),
                    ),
                  ),
              ],
            if (completed && lesson.assessments.isNotEmpty)
              ...[
                const SizedBox(height: 18),
                Text('التقييم', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final assessment in lesson.assessments)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.assignment_outlined, color: theme.colorScheme.primary),
                      title: Text(assessment.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(assessment.questions.length.toString() + ' أسئلة'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AssessmentScreen(assessment: assessment),
                      )),
                    ),
                  ),
              ],
            const SizedBox(height: 18),
            if (!completed)
              FilledButton.icon(
                onPressed: lesson.isFree
                    ? () {
                        if (!active) {
                          ref
                              .read(learningSessionProvider.notifier)
                              .startLesson(lesson.id);
                        } else {
                          ref
                              .read(learningSessionProvider.notifier)
                              .completeStudy();
                        }
                      }
                    : null,
                icon: Icon(active ? Icons.check : Icons.play_arrow),
                label: Text(active ? 'أنهيت دراسة الدرس' : 'ابدأ دراسة الدرس'),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(learningSessionProvider.notifier).clear();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة إلى المقرر'),
              ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'ملاحظة: بيانات الدرس الأكاديمية المعروضة هنا تأتي من المكتبة الأكاديمية الحالية. لن يتم اختراع محتوى غير موجود في بيانات الدرس.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
