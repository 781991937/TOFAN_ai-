import '../../domain/student/student_models.dart';
import '../../domain/learning/learning_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../learning/learning_state.dart';
import '../learning/progress_state.dart';
import '../learning/skill_update_state.dart';
import '../student/student_state.dart';
import '../../ai/ai_core.dart';

class StudentAiContext {
  const StudentAiContext({
    required this.profile,
    required this.smartStudent,
    required this.learningPlan,
    required this.progress,
    required this.skillUpdates,
  });

  final StudentProfile? profile;
  final SmartStudentState smartStudent;
  final LearningPlan? learningPlan;
  final LearningProgress progress;
  final List<SkillUpdateRecord> skillUpdates;

  Map<String, String> toMap() {
    final p = profile;
    final plan = learningPlan;
    return {
      if (p != null) 'student_name': p.name,
      if (p != null) 'university': p.university,
      if (p != null) 'college': p.college,
      if (p != null) 'specialization': p.specialization,
      if (p != null) 'year': p.currentYear.toString(),
      if (p != null) 'semester': p.currentSemester.toString(),
      'knowledge_level': smartStudent.knowledgeLevel.toStringAsFixed(1),
      'skill_level': smartStudent.skillLevel.toStringAsFixed(1),
      'capability_level': smartStudent.capabilityLevel.toStringAsFixed(1),
      'learning_streak': smartStudent.learningStreak.toString(),
      'completed_lessons': progress.completedLessonIds.join(','),
      if (plan != null) 'learning_plan_courses': plan.courseIds.join(','),
      if (plan != null && plan.currentCourseId != null)
        'current_course_id': plan.currentCourseId!,
      'skill_update_count': skillUpdates.length.toString(),
    };
  }
}

final studentAiContextProvider = Provider<StudentAiContext>((ref) {
  return StudentAiContext(
    profile: ref.watch(studentProfileProvider),
    smartStudent: ref.watch(smartStudentProvider),
    learningPlan: ref.watch(learningPlanProvider),
    progress: ref.watch(learningProgressProvider),
    skillUpdates: ref.watch(skillUpdateHistoryProvider),
  );
});

final studentAwareAiRequestProvider = Provider.family<AiRequest, String>(
  (ref, userMessage) {
    final context = ref.watch(studentAiContextProvider);
    return AiRequest(
      systemInstruction:
          'استخدم سياق الطالب الموثق فقط. لا تخترع بيانات عن الطالب ولا درجات أو مقررات غير موجودة.',
      userMessage: userMessage,
      context: context.toMap(),
    );
  },
);
