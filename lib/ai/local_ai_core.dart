import 'ai_core.dart';

/// Local-first AI engine.
/// No network dependency and no API key.
class LocalAiCore implements AiCore {
  const LocalAiCore();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final context = request.context;
    final name = context['student_name'];
    final specialization = context['specialization'];
    final course = context['current_course_id'];
    final knowledge = context['knowledge_level'];
    final skill = context['skill_level'];
    final capability = context['capability_level'];

    final hasStudent = name != null && name.isNotEmpty;
    final hasLevels = knowledge != null && skill != null && capability != null;

    if (request.userMessage.trim().isEmpty) {
      return const AiResponse(
        text: 'اكتب طلبك أولاً، وسأتعامل معه ضمن سياق أكاديمية طوفان.',
        provider: 'local',
        model: 'tofan-local-core',
      );
    }

    final buffer = StringBuffer()
      ..writeln('تم تشغيل TOFAN AI محليًا بدون مفتاح API.');
    if (hasStudent) buffer.writeln('الطالب: $name.');
    if (specialization != null && specialization.isNotEmpty) {
      buffer.writeln('التخصص: $specialization.');
    }
    if (course != null && course.isNotEmpty) {
      buffer.writeln('المقرر الحالي: $course.');
    }
    if (hasLevels) {
      buffer.writeln(
        'مستويات الحالة الذكية المسجلة: معرفة $knowledge، مهارة $skill، قدرة $capability.',
      );
    }
    buffer
      ..writeln('الطلب: ${request.userMessage}')
      ..writeln(
        'المحرك المحلي الحالي يحافظ على بيانات الطالب ولا يخترع محتوى أكاديمي غير موجود. '
        'يمكن لاحقًا تركيب نموذج لغوي محلي على هذا العقد دون تغيير طبقة الوكلاء.',
      );

    return AiResponse(
      text: buffer.toString(),
      provider: 'local',
      model: 'tofan-local-core',
    );
  }
}
