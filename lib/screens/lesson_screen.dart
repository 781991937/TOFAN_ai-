import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learning/learning_state.dart';
import '../domain/learning/learning_models.dart';
import '../domain/academic/academic_models.dart';
import 'assessment_screen.dart';
import 'practice_screen.dart';
import 'project_screen.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.course, required this.lesson});

  final AcademicCourse course;
  final AcademicLesson lesson;

  String _stageLabel(LearningStage stage) {
    switch (stage) {
      case LearningStage.diagnostic: return 'التشخيص';
      case LearningStage.learningPlan: return 'خطة التعلم';
      case LearningStage.study: return 'الدراسة';
      case LearningStage.practice: return 'التطبيق العملي';
      case LearningStage.assessment: return 'التقييم';
      case LearningStage.analysis: return 'التحليل';
      case LearningStage.skillUpdate: return 'تحديث المهارات';
      case LearningStage.project: return 'المشروع';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(learningSessionProvider);
    final active = session?.lessonId == lesson.id;
    final completed = active && session!.isCompleted;
    final planReady = active && session!.stage == LearningStage.learningPlan;
    final practiceReady = active && session!.stage == LearningStage.practice;
    final assessmentReady = active && session!.stage == LearningStage.assessment;
    final projectReady = active && session!.stage == LearningStage.project && !session!.isCompleted;
    final studyReady = active && session!.stage == LearningStage.study;
    final lifecycleInProgress = active && !completed && !planReady && !studyReady && !practiceReady && !assessmentReady && !projectReady;
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
                    if (lesson.content.isNotEmpty) Text(lesson.content),
                    if (lesson.learningOutcomes.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('نواتج التعلم', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      for (final outcome in lesson.learningOutcomes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $outcome'),
                        ),
                    ],
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
                      ? 'وصلت إلى مرحلة المشروع'
                      : planReady
                          ? 'خطة التعلم جاهزة'
                          : active
                              ? 'جلسة الدراسة جارية'
                              : 'لم تبدأ الدراسة بعد',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  completed
                      ? 'اكتملت مراحل التعلم السابقة ويمكنك بدء المشروع.'
                      : planReady
                          ? 'تم إعداد مسار هذا الدرس. ابدأ الدراسة للانتقال إلى المرحلة التالية.'
                          : 'ابدأ الجلسة لتسجيل تقدمك في هذا الدرس.',
                ),
              ),
            ),
            if (practiceReady && lesson.practices.isNotEmpty)
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
            if (projectReady && lesson.projects.isNotEmpty)
              ...[
                const SizedBox(height: 18),
                Text('المشروع',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final project in lesson.projects)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.rocket_launch_outlined,
                          color: theme.colorScheme.primary),
                      title: Text(project.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(project.description),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        ref.read(learningSessionProvider.notifier).enterProject();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectScreen(project: project),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            if (assessmentReady && lesson.assessments.isNotEmpty)
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
            if (!completed && !lifecycleInProgress)
              FilledButton.icon(
                onPressed: lesson.isFree
                    ? () {
                        final controller = ref.read(learningSessionProvider.notifier);
                        if (!active) {
                          controller.startLesson(lesson.id);
                        } else if (planReady) {
                          controller.beginStudy();
                        } else if (studyReady) {
                          controller.completeStudy();
                        }
                      }
                    : null,
                icon: Icon(
                  !active
                      ? Icons.play_arrow
                      : planReady
                          ? Icons.school_outlined
                          : Icons.check,
                ),
                label: Text(
                  !active
                      ? 'ابدأ خطة التعلم'
                      : planReady
                          ? 'ابدأ الدراسة'
                          : 'أنهي الدراسة',
                ),
              )
            else if (lifecycleInProgress)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'الجلسة انتقلت إلى مرحلة ' + _stageLabel(session!.stage) + '. تابع من شاشة هذه المرحلة.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
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
