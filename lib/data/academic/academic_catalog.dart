import '../../domain/academic/academic_models.dart';

/// Reference catalog for the global TOFAN AI STUDENT library.
/// The structure is independent from any single university.
/// Learning content is aligned with internationally published computing
/// curriculum guidance and is written as original TOFAN academic content.
class AcademicCatalog {
  const AcademicCatalog._();

  static const universities = <AcademicUniversity>[
    AcademicUniversity(
      id: 'sanaa',
      name: 'جامعة صنعاء',
      colleges: [
        AcademicCollege(
          id: 'computer',
          name: 'كلية الحاسوب وتكنولوجيا المعلومات',
          specializations: [
            AcademicSpecialization(
              id: 'ai',
              name: 'الذكاء الاصطناعي',
              years: [
                AcademicYear(
                  number: 1,
                  semesters: [
                    AcademicSemester(
                      number: 1,
                      courses: [
                        AcademicCourse(
                          id: 'python',
                          name: 'أساسيات البرمجة — Python',
                          lessons: [
                            AcademicLesson(
                              id: 'python-1',
                              title: 'مقدمة في Python',
                              practices: [
                                LessonPractice(
                                  id: 'python-1-practice',
                                  title: 'تطبيق: أول برنامج',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اكتب برنامجًا يطبع رسالة ترحيب ثم عدّل الرسالة إلى نص من اختيارك.'),
                                    PracticeTask(id: 'p2', instruction: 'شغّل البرنامج، لاحظ المخرجات، ثم اشرح باختصار الفرق بين الكود والمخرجات.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-1-assessment',
                                  title: 'تقييم: مقدمة في Python',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما وظيفة البرنامج في Python؟', options: ['تنفيذ تعليمات مكتوبة', 'تصميم العتاد فقط', 'تخزين الصور فقط', 'إدارة الشبكات فقط'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'ما الذي ينتج عادةً عن تنفيذ print؟', options: ['إخراج نص أو قيمة', 'إنشاء قاعدة بيانات', 'تثبيت نظام تشغيل', 'حذف المترجم'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ما المقصود بالتعليمات البرمجية؟', options: ['أوامر يفهمها المفسر أو المترجم لتنفيذ مهمة', 'صورة ثابتة', 'اسم جهاز', 'ملف صوتي'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-1-project',
                                  title: 'مشروع: برنامج ترحيب بسيط',
                                  description: 'أنشئ برنامجًا قصيرًا يستخدم مخرجات نصية واضحة، ثم وثّق وظيفة كل سطر بكلماتك.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'python-2',
                              title: 'المتغيرات وأنواع البيانات',
                              practices: [
                                LessonPractice(
                                  id: 'python-2-practice',
                                  title: 'تطبيق: بيانات الطالب',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'أنشئ متغيرات لاسم طالب وعمره، ثم اطبع القيمتين.'),
                                    PracticeTask(id: 'p2', instruction: 'استخدم type لفحص نوع كل قيمة، ثم اشرح لماذا يختلف النوع بين النص والعدد.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-2-assessment',
                                  title: 'تقييم: المتغيرات والأنواع',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما المتغير؟', options: ['اسم يشير إلى قيمة يمكن استخدامها في البرنامج', 'جهاز إدخال', 'مجلد نظام', 'شبكة'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'أي نوع يمثل نصًا في Python؟', options: ['str', 'int', 'bool فقط', 'float فقط'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ما وظيفة type؟', options: ['معرفة نوع قيمة', 'قراءة لوحة المفاتيح فقط', 'إغلاق البرنامج', 'حذف متغير'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-2-project',
                                  title: 'مشروع: بطاقة بيانات طالب',
                                  description: 'أنشئ برنامجًا يخزن عدة بيانات أساسية في متغيرات ويعرضها بصورة منظمة.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'python-3',
                              title: 'الإدخال والعمليات الحسابية',
                              practices: [
                                LessonPractice(
                                  id: 'python-3-practice',
                                  title: 'تطبيق: حساب بسيط',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اقرأ عددين باستخدام input وحولهما إلى أعداد صحيحة باستخدام int.'),
                                    PracticeTask(id: 'p2', instruction: 'احسب الجمع والطرح والضرب والقسمة الصحيحة وباقي القسمة، ثم اعرض النتائج.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-3-assessment',
                                  title: 'تقييم: الإدخال والعمليات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما وظيفة input؟', options: ['قراءة إدخال من المستخدم كنص', 'طباعة ملف', 'إنشاء متغير تلقائيًا من دون قيمة', 'إغلاق المفسر'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'لماذا نستخدم int(input(...)) عند الحاجة إلى عدد صحيح؟', options: ['لتحويل الإدخال النصي إلى عدد صحيح', 'لتحويل العدد إلى صورة', 'لإخفاء الإدخال', 'لإنشاء قائمة'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ما العامل % في Python؟', options: ['باقي القسمة', 'الأس', 'القسمة الصحيحة', 'الجمع'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-3-project',
                                  title: 'مشروع: حاسبة طالب',
                                  description: 'أنشئ حاسبة تفاعلية تقرأ قيمًا من المستخدم وتعرض نتائج عمليات حسابية أساسية بصورة واضحة.',
                                ),
                              ],
                            ),
                          ],
                        ),
                        AcademicCourse(
                          id: 'discrete-math',
                          name: 'الرياضيات المتقطعة',
                          lessons: [
                            AcademicLesson(
                              id: 'sets',
                              title: 'المجموعات',
                              practices: [
                                LessonPractice(
                                  id: 'sets-practice',
                                  title: 'تطبيق: عمليات المجموعات',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'كوّن مجموعتين صغيرتين وحدد عناصر الاتحاد والتقاطع بينهما.'),
                                    PracticeTask(id: 'p2', instruction: 'أنشئ مثالًا على الفرق بين مجموعتين، ثم تحقق من النتيجة عنصرًا عنصرًا.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'sets-assessment',
                                  title: 'تقييم: المجموعات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما المجموعة؟', options: ['تجميع محدد من عناصر مميزة', 'عدد عشري فقط', 'برنامج', 'شبكة'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'ماذا يمثل تقاطع مجموعتين؟', options: ['العناصر المشتركة بينهما', 'كل العناصر من دون تكرار', 'عناصر المجموعة الأولى فقط', 'عناصر خارج المجموعتين'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ماذا يمثل اتحاد مجموعتين؟', options: ['عناصر المجموعتين معًا دون تكرار', 'العناصر المشتركة فقط', 'العناصر في المجموعة الأولى فقط', 'العناصر في المجموعة الثانية فقط'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'sets-project',
                                  title: 'مشروع: نموذج مجموعات بيانات',
                                  description: 'مثّل مجموعات لطلاب أو مقررات، ثم استخدم الاتحاد والتقاطع والفرق لتحليل العلاقة بينها.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'relations',
                              title: 'العلاقات',
                              practices: [
                                LessonPractice(
                                  id: 'relations-practice',
                                  title: 'تطبيق: تمثيل علاقة',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'كوّن علاقة بين عناصر مجموعتين باستخدام أزواج مرتبة.'),
                                    PracticeTask(id: 'p2', instruction: 'حدد من المثال ما إذا كانت العلاقة تمثل شرطًا محددًا بين عناصر المجال والمدى.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'relations-assessment',
                                  title: 'تقييم: العلاقات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'كيف يمكن تمثيل علاقة بين مجموعتين؟', options: ['بمجموعة من الأزواج المرتبة', 'بصورة فقط', 'بملف صوتي فقط', 'بمتغير واحد فقط'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'ما الزوج المرتب؟', options: ['عنصران بترتيب محدد', 'مجموعة غير مرتبة فقط', 'عدد صحيح', 'تعليمة Python'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'لماذا تُستخدم العلاقات في علوم الحاسوب؟', options: ['لتمثيل ارتباطات بين عناصر وكيانات', 'لزيادة سرعة المعالج فقط', 'لضغط الصور فقط', 'لتثبيت البرامج'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'relations-project',
                                  title: 'مشروع: علاقة المقررات والمتطلبات',
                                  description: 'مثّل علاقة بسيطة بين مقررات ومتطلبات سابقة باستخدام الأزواج المرتبة وفسّر ما تمثله.',
                                ),
                              ],
                            ),
                          ],
                        ),
                        AcademicCourse(
                          id: 'ai-intro',
                          name: 'مقدمة في الذكاء الاصطناعي',
                          lessons: [
                            AcademicLesson(
                              id: 'ai-foundations',
                              title: 'مفاهيم الذكاء الاصطناعي',
                              practices: [
                                LessonPractice(
                                  id: 'ai-foundations-practice',
                                  title: 'تطبيق: تحليل نظام ذكي',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اختر نظامًا يستخدم الذكاء الاصطناعي وحدد المدخلات والمخرجات والمهمة التي يؤديها.'),
                                    PracticeTask(id: 'p2', instruction: 'ميّز في المثال بين النظام الذي يعتمد على قواعد ثابتة والنظام الذي يتعلم من البيانات إن أمكن.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'ai-foundations-assessment',
                                  title: 'تقييم: مفاهيم الذكاء الاصطناعي',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما أحد الموضوعات الأساسية في الذكاء الاصطناعي الحديث؟', options: ['التعلم الآلي', 'تنسيق المستندات فقط', 'إدارة الملفات فقط', 'تصميم الشرائح فقط'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'ما المقصود بالتمثيل المعرفي؟', options: ['تمثيل المعلومات بطريقة تسمح للنظام باستخدامها في الاستدلال أو المعالجة', 'نسخ الملفات', 'تغيير حجم الشاشة', 'تثبيت نظام التشغيل'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'لماذا تُدرَس آثار الذكاء الاصطناعي المجتمعية؟', options: ['لفهم الاستخدام المسؤول والمخاطر والآثار المحتملة للأنظمة الذكية', 'لزيادة حجم الملفات', 'لتسريع لوحة المفاتيح', 'لإلغاء الاختبارات'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'ai-foundations-project',
                                  title: 'مشروع: دراسة حالة لنظام ذكي',
                                  description: 'حلّل نظامًا ذكيًا حقيقيًا من حيث المهمة والمدخلات والمخرجات ونوع المعرفة أو التعلم المستخدم وآثاره المحتملة.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'ai-agents',
                              title: 'الوكلاء الأذكياء',
                              practices: [
                                LessonPractice(
                                  id: 'ai-agents-practice',
                                  title: 'تطبيق: نموذج وكيل ذكي',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اختر مهمة لوكيل ذكي وحدد البيئة والملاحظات والأفعال التي يمكنه تنفيذها.'),
                                    PracticeTask(id: 'p2', instruction: 'اكتب وصفًا مختصرًا لكيفية اختيار الوكيل لفعل مناسب استنادًا إلى الملاحظات والهدف.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'ai-agents-assessment',
                                  title: 'تقييم: الوكلاء الأذكياء',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما الوكيل الذكي؟', options: ['نظام يستقبل ملاحظات عن بيئته ويختار أفعالًا لتحقيق هدف', 'برنامج طباعة فقط', 'قاعدة بيانات فقط', 'جهاز تخزين'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'ما المقصود بالبيئة في نموذج الوكيل؟', options: ['العالم أو السياق الذي يتفاعل معه الوكيل', 'اسم المتغير فقط', 'ذاكرة الحاسوب فقط', 'لغة البرمجة فقط'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ما العلاقة بين الإدراك والفعل في الوكيل؟', options: ['الملاحظات تساعد الوكيل على اختيار أفعاله', 'الفعل يحدث قبل أي ملاحظة دائمًا', 'لا توجد علاقة', 'الملاحظات هي نفسها قاعدة البيانات'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'ai-agents-project',
                                  title: 'مشروع: تصميم وكيل تعليمي',
                                  description: 'صمّم نموذجًا مفاهيميًا لوكيل تعليمي يراقب تقدم الطالب ويختار إجراءً تعليميًا مناسبًا، مع تحديد البيئة والملاحظات والأفعال والهدف.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    AcademicSemester(
                      number: 2,
                      courses: [
                        AcademicCourse(
                          id: 'data-structures',
                          name: 'هياكل البيانات',
                          lessons: [
                            AcademicLesson(
                              id: 'arrays',
                              title: 'المصفوفات والقوائم',
                              practices: [
                                LessonPractice(
                                  id: 'arrays-practice',
                                  title: 'تطبيق: التعامل مع قائمة',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'أنشئ قائمة قيم وأضف إليها عنصرًا ثم اقرأ عنصرًا منها باستخدام الفهرس.'),
                                    PracticeTask(id: 'p2', instruction: 'احسب عدد العناصر وجرّب المرور عليها لعرض القيم بالتتابع.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'arrays-assessment',
                                  title: 'تقييم: القوائم',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما القائمة في Python؟', options: ['بنية بيانات مرتبة يمكن أن تحتوي عدة قيم', 'عدد واحد فقط', 'دالة طباعة', 'ملف نظام'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q2', text: 'كيف نصل عادةً إلى عنصر في قائمة؟', options: ['باستخدام الفهرس', 'بتغيير اسم الملف', 'بتثبيت مكتبة', 'بإغلاق البرنامج'], correctIndex: 0),
                                    AssessmentQuestion(id: 'q3', text: 'ما فائدة بنية البيانات؟', options: ['تنظيم البيانات ومعالجتها بكفاءة مناسبة للمهمة', 'تغيير دقة الشاشة فقط', 'إدارة الكهرباء', 'تشغيل لوحة المفاتيح'], correctIndex: 0),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'arrays-project',
                                  title: 'مشروع: قائمة مهام برمجية',
                                  description: 'أنشئ نموذجًا بسيطًا لقائمة مهام باستخدام بنية قائمة، مع إضافة عناصر وعرضها وتنظيمها.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  /// Global top-level academic fields. The current reference catalog is
  /// grouped under computing and information technology and can expand without
  /// changing the lower academic hierarchy.
  static const fields = <AcademicField>[
    AcademicField(
      id: 'computing-it',
      name: 'علوم الحاسوب وتكنولوجيا المعلومات',
      universities: universities,
    ),
  ];

  static AcademicUniversity get referenceUniversity => universities.first;

  static int get courseCount => universities.expand((u) => u.colleges)
      .expand((c) => c.specializations).expand((s) => s.years)
      .expand((y) => y.semesters).expand((s) => s.courses).length;

  static int get lessonCount => universities.expand((u) => u.colleges)
      .expand((c) => c.specializations).expand((s) => s.years)
      .expand((y) => y.semesters).expand((s) => s.courses)
      .expand((c) => c.lessons).length;
}
