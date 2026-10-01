import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/abqari/project_engine.dart';
import 'package:tofan_ai/data/academic/academic_project_capability_engine.dart';
import 'package:tofan_ai/data/academic/academic_lesson_blueprints.dart';

void main() {
  test('project capability engine derives build evidence from the canonical library', () {
    const engine = AcademicProjectCapabilityEngine();
    final capabilities = engine.capabilitiesFor('نظام ويب آمن مع قاعدة بيانات وذكاء اصطناعي');

    expect(capabilities, isNotEmpty);
    expect(
      capabilities.any(
        (item) =>
            item.courseId.isNotEmpty &&
            item.lessonIds.isNotEmpty &&
            item.knowledgeUnitIds.isNotEmpty &&
            item.skillIds.isNotEmpty &&
            item.projectTitles.isNotEmpty,
      ),
      isTrue,
    );
    expect(engine.canStartBuild('نظام ويب آمن مع قاعدة بيانات'), isTrue);
  });

  test('Abqari project plan keeps canonical course, lesson, unit, and project traceability', () {
    const engine = AbqariProjectEngine();
    final plan = engine.plan(
      const AbqariProjectRequest(
        idea: 'نظام ويب آمن لإدارة البيانات',
      ),
    );

    expect(plan.sourceCourseIds, isNotEmpty);
    expect(plan.sourceLessonIds, isNotEmpty);
    expect(plan.sourceKnowledgeUnitIds, isNotEmpty);
    expect(plan.sourceProjectTitles, isNotEmpty);
    expect(plan.sourceProjectRequirements, isNotEmpty);
    expect(plan.sourceImplementationTasks, isNotEmpty);
    expect(plan.sourceTestCases, isNotEmpty);
    expect(plan.sourceEvidenceRequirements, isNotEmpty);
  });
  test('global curriculum gap courses do not use the generic lesson fallback', () {
    const gapCourses = [
      'الأنظمة الموزعة',
      'تحليل المتطلبات',
      'ضمان الجودة',
      'تطوير التطبيقات',
      'أساسيات تقنية المعلومات',
      'إدارة الأنظمة',
      'مقدمة نظم المعلومات',
      'تحليل النظم',
      'نظم دعم القرار',
      'إدارة الخدمات',
      'معالجة البيانات الضخمة',
      'التجارب وتحليلها',
      'الذكاء الاصطناعي التطبيقي',
      'هندسة منصات البيانات',
      'الاستجابة للحوادث',
      'تحليل البرمجيات الخبيثة',
      'التحقيق الجنائي الرقمي',
      'الحوسبة المتوازية',
      'النمذجة ثلاثية الأبعاد',
      'الواقع الافتراضي',
      'الرؤية الحاسوبية',
      'الواقع المعزز',
      'تصميم البرمجيات',
      'تصميم النظم',
      'تصميم الأنظمة',
      'برمجة واجهات المستخدم',
      'معالجة اللغة للبيانات',
      'رياضيات وأسس التشفير',
    ];

    for (final course in gapCourses) {
      final lessons = AcademicCourseLessonBlueprints.forCourse(course, const []);
      expect(lessons, isNotEmpty);
      expect(lessons.first.title, isNot('مدخل إلى $course'));
    }
  });

}


  test('specialized routing uses deep project blueprints for previously ambiguous courses', () {
    const courses = [
      'تصميم البرمجيات',
      'تصميم النظم',
      'تصميم الأنظمة',
      'برمجة واجهات المستخدم',
      'معالجة اللغة للبيانات',
      'رياضيات وأسس التشفير',
    ];

    for (final course in courses) {
      final lessons = AcademicCourseLessonBlueprints.forCourse(course, const []);
      expect(lessons, hasLength(6));
      expect(
        lessons.every((lesson) =>
            !lesson.title.startsWith('الأساس المفاهيمي') &&
            !lesson.title.startsWith('البنية والمكونات') &&
            !lesson.title.startsWith('التطبيق الموجه')),
        isTrue,
      );
      expect(lessons.last.title, contains('بناء'));
    }
  });
