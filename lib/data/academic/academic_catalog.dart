import '../../domain/academic/academic_models.dart';

/// Reference catalog for the global TOFAN AI STUDENT library.
/// The structure is independent from any single university.
/// Learning content is aligned with internationally published computing
/// curriculum guidance and is written as original TOFAN academic content.
class AcademicCatalog {
  const AcademicCatalog._();

  static final universities = <AcademicUniversity>[
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
            ..._globalSpecializations,
          ],
        ),
      ],
    ),
  ];

  /// Global computing specializations. These entries complete the academic
  /// skeleton across four years and two semesters; lesson content is expanded
  /// incrementally from the same approved global curriculum foundation.
  static final List<AcademicSpecialization> _globalSpecializations = [
    _specialization('computer-science', 'علوم الحاسوب', [
      ['البرمجة 1', 'رياضيات متقطعة', 'أساسيات الحوسبة'], ['البرمجة 2', 'هياكل البيانات', 'منطق رقمي'],
      ['الخوارزميات', 'قواعد البيانات', 'أنظمة التشغيل'], ['شبكات الحاسوب', 'هندسة البرمجيات', 'تحليل الخوارزميات'],
      ['البرمجة المتقدمة', 'الأنظمة الموزعة', 'أمن الحاسوب'], ['تطوير الويب', 'تفاعل الإنسان والحاسوب', 'الحوسبة السحابية'],
      ['الذكاء الاصطناعي', 'علم البيانات', 'المترجمات'], ['مشروع التخرج 1', 'موضوعات متقدمة في علوم الحاسوب', 'منهجية البحث'],
    ]),
    _specialization('software-engineering', 'هندسة البرمجيات', [
      ['أساسيات البرمجة', 'رياضيات متقطعة', 'أساسيات هندسة البرمجيات'], ['البرمجة الكائنية', 'هياكل البيانات', 'إدارة الإصدارات'],
      ['تحليل المتطلبات', 'تصميم البرمجيات', 'اختبار البرمجيات'], ['قواعد البيانات', 'هندسة البرمجيات المتقدمة', 'إدارة المشاريع البرمجية'],
      ['معمارية البرمجيات', 'DevOps', 'ضمان الجودة'], ['تطوير التطبيقات', 'الأمن البرمجي', 'الأنظمة الموزعة'],
      ['الأنظمة السحابية', 'هندسة البرمجيات الحديثة', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة هندسة البرمجيات'],
    ]),
    _specialization('information-technology', 'تقنية المعلومات', [
      ['أساسيات تقنية المعلومات', 'البرمجة', 'رياضيات للحوسبة'], ['قواعد البيانات', 'شبكات 1', 'أنظمة التشغيل'],
      ['شبكات 2', 'إدارة الأنظمة', 'أمن المعلومات'], ['خدمات الشبكات', 'إدارة قواعد البيانات', 'دعم المستخدم'],
      ['الحوسبة السحابية', 'أمن الشبكات', 'إدارة البنية التحتية'], ['افتراضية الحوسبة', 'DevOps', 'استمرارية الأعمال'],
      ['إدارة خدمات تقنية المعلومات', 'حوكمة تقنية المعلومات', 'تدقيق الأنظمة'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'منهجية البحث'],
    ]),
    _specialization('information-systems', 'نظم المعلومات', [
      ['مقدمة نظم المعلومات', 'البرمجة', 'رياضيات وإحصاء'], ['تحليل النظم', 'قواعد البيانات', 'إدارة الأعمال'],
      ['تصميم النظم', 'نمذجة البيانات', 'إدارة المشاريع'], ['نظم المؤسسات', 'ذكاء الأعمال', 'أمن نظم المعلومات'],
      ['تحليل البيانات', 'تخطيط موارد المؤسسة', 'إدارة العمليات'], ['نظم دعم القرار', 'الحوسبة السحابية', 'إدارة الخدمات'],
      ['التحول الرقمي', 'حوكمة البيانات', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة نظم المعلومات'],
    ]),
    _specialization('data-science', 'علم البيانات', [
      ['البرمجة للبيانات', 'رياضيات متقطعة', 'إحصاء 1'], ['هياكل البيانات', 'إحصاء 2', 'قواعد البيانات'],
      ['تنقيب البيانات', 'تحليل البيانات', 'تصوير البيانات'], ['تعلم الآلة', 'هندسة البيانات', 'الاحتمالات'],
      ['تعلم الآلة المتقدم', 'معالجة البيانات الضخمة', 'التجارب وتحليلها'], ['معالجة اللغة للبيانات', 'السلاسل الزمنية', 'الحوسبة السحابية'],
      ['الذكاء الاصطناعي التطبيقي', 'هندسة منصات البيانات', 'أخلاقيات البيانات'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'منهجية البحث'],
    ]),
    _specialization('cybersecurity', 'الأمن السيبراني', [
      ['أساسيات الحوسبة', 'البرمجة', 'رياضيات للحوسبة'], ['شبكات 1', 'أنظمة التشغيل', 'أساسيات الأمن'],
      ['شبكات 2', 'التشفير', 'أمن الأنظمة'], ['أمن التطبيقات', 'الاستجابة للحوادث', 'تحليل البرمجيات الخبيثة'],
      ['اختبار الاختراق الأخلاقي', 'أمن الشبكات المتقدم', 'أمن قواعد البيانات'], ['التحقيق الرقمي', 'أمن السحابة', 'إدارة المخاطر'],
      ['أمن البرمجيات', 'حوكمة الأمن', 'أمن الأنظمة الموزعة'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'منهجية البحث الأمني'],
    ]),
    _specialization('computer-engineering', 'هندسة الحاسوب', [
      ['أساسيات البرمجة', 'رياضيات 1', 'منطق رقمي'], ['برمجة منخفضة المستوى', 'رياضيات 2', 'معمارية الحاسوب'],
      ['دوائر ومنطق متقدم', 'هياكل البيانات', 'أنظمة التشغيل'], ['معمارية المعالجات', 'أنظمة مضمنة', 'شبكات الحاسوب'],
      ['تصميم الأنظمة الرقمية', 'إنترنت الأشياء', 'الأنظمة الزمنية الحقيقية'], ['معالجة الإشارة', 'الأنظمة المضمنة المتقدمة', 'الأمن العتادي'],
      ['الحوسبة المتوازية', 'تصميم الأنظمة', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة هندسة الحاسوب'],
    ]),
    _specialization('graphics-hci', 'الرسوميات وتفاعل الإنسان والحاسوب', [
      ['أساسيات البرمجة', 'مبادئ التصميم', 'رياضيات للحوسبة'], ['برمجة واجهات المستخدم', 'تصميم تجربة المستخدم', 'رسوميات الحاسوب 1'],
      ['رسوميات الحاسوب 2', 'تفاعل الإنسان والحاسوب', 'تصميم المعلومات'], ['النمذجة ثلاثية الأبعاد', 'تصميم الألعاب', 'اختبار قابلية الاستخدام'],
      ['الرسوميات المتقدمة', 'الواقع الافتراضي', 'تصميم التفاعل'], ['الرؤية الحاسوبية', 'الواقع المعزز', 'الوسائط التفاعلية'],
      ['التصميم التفاعلي المتقدم', 'أبحاث HCI', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة الرسوميات وHCI'],
    ]),
  ];

  static AcademicSpecialization _specialization(String id, String name, List<List<String>> semesters) {
    return AcademicSpecialization(
      id: id,
      name: name,
      years: List.generate(4, (yearIndex) => AcademicYear(
        number: yearIndex + 1,
        semesters: [
          AcademicSemester(number: 1, courses: semesters[yearIndex * 2].map((name) => _course(id, yearIndex + 1, 1, name)).toList()),
          AcademicSemester(number: 2, courses: semesters[yearIndex * 2 + 1].map((name) => _course(id, yearIndex + 1, 2, name)).toList()),
        ],
      )),
    );
  }

  static AcademicCourse _course(String specializationId, int year, int semester, String name) {
    final courseId = '${specializationId}-y$year-s$semester-${name.toLowerCase().replaceAll(' ', '-')}'
        .replaceAll('—', '-');

    final lessons = List<AcademicLesson>.generate(
      3,
      (index) => _generatedLesson(courseId: courseId, courseName: name, lessonNumber: index + 1),
    );

    return AcademicCourse(
      id: courseId,
      name: name,
      lessons: lessons,
      units: [
        AcademicUnit(id: '$courseId-unit-1', title: 'الوحدة الأولى: المدخل والمفاهيم الأساسية', lessons: [lessons[0]]),
        AcademicUnit(id: '$courseId-unit-2', title: 'الوحدة الثانية: المفاهيم والمكونات', lessons: [lessons[1]]),
        AcademicUnit(id: '$courseId-unit-3', title: 'الوحدة الثالثة: التطبيقات الأساسية', lessons: [lessons[2]]),
      ],
    );
  }

  static AcademicLesson _generatedLesson({
    required String courseId,
    required String courseName,
    required int lessonNumber,
  }) {
    final blueprint = _blueprintFor(courseName);
    final title = blueprint.titles[lessonNumber - 1];
    final topic = blueprint.topics[lessonNumber - 1];
    final lessonId = '$courseId-$lessonNumber';

    return AcademicLesson(
      id: lessonId,
      title: title,
      content: '''
$title

هذا المحتوى التعليمي الأصلي من مكتبة TOFAN يقدّم موضوع «$topic» داخل مقرر «$courseName» بصورة متدرجة. يبدأ الطالب بتحديد المفهوم ومشكلته، ثم يربطه بالمكونات الأساسية، ثم يطبقه على حالة عملية.

الفكرة الأساسية:
$topic

طريقة الدراسة:
1. اقرأ التعريف وحدد المصطلحات الجديدة.
2. اربط المفهوم بالمثال المعطى.
3. نفّذ التدريب قبل الانتقال إلى التقييم.
4. بعد التقييم راجع الأخطاء، ثم نفّذ المشروع المصغر.

ملاحظة أكاديمية: المحتوى مبني على المعرفة والموضوعات العامة في إرشادات المناهج العالمية للحوسبة، بينما صياغة الدرس والأمثلة والتدريبات هنا أصلية لمكتبة TOFAN.
''',
      learningOutcomes: [
        'يشرح الطالب مفهوم «$topic» بلغة علمية واضحة.',
        'يميز المكونات والعلاقات الرئيسة المرتبطة بـ«$topic».',
        'يطبق المفهوم على مسألة أو مثال مناسب لمقرر «$courseName».',
        'يحلل النتيجة ويبرر الاختيار أو الحل باستخدام المصطلحات الصحيحة.',
      ],
      keyTerms: blueprint.terms,
      examples: [
        'مثال مفاهيمي: حدّد «$topic» في موقف عملي، ثم اشرح سبب تحديدك له.',
        'مثال تطبيقي: قارن حالتين مرتبطتين بـ«$topic» وحدد أثر اختلاف المدخلات أو القيود على النتيجة.',
      ],
      practices: [
        LessonPractice(
          id: '$lessonId-practice',
          title: 'تدريب متدرج: $topic',
          tasks: [
            PracticeTask(id: '$lessonId-p1', instruction: 'اكتب تعريفًا مختصرًا لـ«$topic» ثم حدد مكوناته الأساسية في مثال من مقرر $courseName.'),
            PracticeTask(id: '$lessonId-p2', instruction: 'طبّق «$topic» على مسألة صغيرة، وسجّل خطواتك والنتيجة والسبب الذي يدعمها.'),
            PracticeTask(id: '$lessonId-p3', instruction: 'أنشئ مثالًا جديدًا من عندك، ثم اشرح كيف تعرف أن التطبيق صحيح.'),
          ],
        ),
      ],
      assessments: [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم: $title',
          questions: [
            AssessmentQuestion(
              id: '$lessonId-q1',
              text: 'ما أفضل وصف للموضوع الرئيس «$topic»؟',
              options: [blueprint.correct, blueprint.distractor1, blueprint.distractor2, blueprint.distractor3],
              correctIndex: 0,
            ),
            AssessmentQuestion(
              id: '$lessonId-q2',
              text: 'ما الخطوة التي تدل على فهم تطبيقي للموضوع؟',
              options: ['تطبيقه على حالة وتفسير النتيجة', 'حفظ اسم الموضوع فقط', 'نسخ تعريف دون فهم', 'تجاهل القيود والافتراضات'],
              correctIndex: 0,
            ),
            AssessmentQuestion(
              id: '$lessonId-q3',
              text: 'ماذا ينبغي أن يفعل الطالب عند ظهور نتيجة غير متوقعة؟',
              options: ['يفحص الافتراضات والخطوات والبيانات ثم يفسر السبب', 'يغيّر النتيجة دون فحص', 'يحذف المسألة', 'يتوقف عن التقييم'],
              correctIndex: 0,
            ),
          ],
        ),
      ],
      projects: [
        AcademicProject(
          id: '$lessonId-project',
          title: 'مشروع مصغر: $topic',
          description: 'أنجز تطبيقًا أو دراسة حالة صغيرة في «$courseName» تركز على «$topic». وثّق المشكلة، المفاهيم المستخدمة، خطوات التنفيذ، النتيجة، الأخطاء التي واجهتها، وكيف تحققت من صحة الحل.',
        ),
      ],
    );
  }

  static _LessonBlueprint _blueprintFor(String courseName) {
    final n = courseName.toLowerCase();
    if (n.contains('python') || n.contains('البرمجة')) {
      return _LessonBlueprint(
        titles: ['الأساس البرمجي والمفاهيم', 'التحكم بالبيانات والعمليات', 'بناء برنامج تطبيقي'],
        topics: ['المتغيرات وأنواع البيانات', 'التعبيرات والتحكم وتدفق التنفيذ', 'تصميم برنامج صغير واختباره'],
        terms: ['متغير', 'نوع بيانات', 'تعبير', 'تدفق التنفيذ'],
        correct: 'هو فهم بنية البرنامج والبيانات ثم تحويل المشكلة إلى خطوات قابلة للتنفيذ',
        distractor1: 'هو حفظ أسماء الأوامر دون معرفة استخدامها',
        distractor2: 'هو تشغيل الجهاز دون كتابة تعليمات',
        distractor3: 'هو تخزين الملفات فقط',
      );
    }
    if (n.contains('رياضيات') || n.contains('mathemat')) {
      return _LessonBlueprint(
        titles: ['المفاهيم والرموز الرياضية', 'العمليات والاستدلال', 'تطبيق رياضي في الحوسبة'],
        topics: ['التعريفات والرموز والبنى الرياضية', 'العمليات والاستدلال المنطقي', 'نمذجة مشكلة حاسوبية بأداة رياضية'],
        terms: ['تعريف', 'مجموعة', 'علاقة', 'استدلال'],
        correct: 'استخدام تعريفات ورموز وعمليات رياضية لبناء استدلال صحيح',
        distractor1: 'حفظ النتائج دون معرفة شروطها',
        distractor2: 'استبدال البرهان بالتخمين',
        distractor3: 'استخدام رمز دون تعريف',
      );
    }
    if (n.contains('ذكاء اصطناعي') || n.contains('ai') || n.contains('تعلم الآلة') || n.contains('الرؤية') || n.contains('اللغة')) {
      return _LessonBlueprint(
        titles: ['أساسيات الذكاء الاصطناعي والبيانات', 'النماذج والاستدلال والتقييم', 'تطبيق ذكي وتحليل نتائجه'],
        topics: ['صياغة المشكلة والبيانات والتمثيل', 'اختيار النموذج وقياس الأداء', 'بناء تطبيق ذكي وتحليل حدوده'],
        terms: ['بيانات', 'تمثيل', 'نموذج', 'تقييم'],
        correct: 'حل مشكلة حاسوبية باستخدام تمثيل أو نموذج مناسب مع تقييم النتيجة وحدودها',
        distractor1: 'أي برنامج يستخدم شاشة رسومية',
        distractor2: 'حفظ أسماء الخوارزميات دون بيانات',
        distractor3: 'اعتبار كل مخرجات النموذج صحيحة تلقائيًا',
      );
    }
    if (n.contains('شبك') || n.contains('network')) {
      return _LessonBlueprint(
        titles: ['أساسيات الاتصال الشبكي', 'البروتوكولات والعنونة والتوجيه', 'تصميم شبكة وتحليل الاتصال'],
        topics: ['الأجهزة والطبقات ومسار البيانات', 'العنونة والبروتوكولات والتوجيه', 'تحليل اتصال شبكة واكتشاف مشكلة'],
        terms: ['شبكة', 'بروتوكول', 'عنوان', 'توجيه'],
        correct: 'تنظيم اتصال بين أجهزة وفق بروتوكولات وعنونة ومسارات محددة',
        distractor1: 'توصيل الأجهزة بلا قواعد اتصال',
        distractor2: 'تخزين الملفات فقط',
        distractor3: 'زيادة سرعة المعالج',
      );
    }
    if (n.contains('قواعد البيانات') || n.contains('البيانات') || n.contains('data')) {
      return _LessonBlueprint(
        titles: ['نمذجة البيانات والمفاهيم الأساسية', 'الاستعلام والمعالجة والتحقق', 'حل مشكلة بيانات واقعية'],
        topics: ['الكيانات والسمات والعلاقات', 'الاستعلامات وجودة البيانات', 'تصميم حل بيانات واختبار نتائجه'],
        terms: ['بيان', 'كيان', 'علاقة', 'استعلام'],
        correct: 'تنظيم البيانات وربطها ومعالجتها للحصول على معلومات صحيحة قابلة للاستخدام',
        distractor1: 'تخزين أي نص بلا بنية',
        distractor2: 'حذف القيود من قاعدة البيانات',
        distractor3: 'عرض البيانات دون التحقق منها',
      );
    }
    if (n.contains('أمن') || n.contains('security') || n.contains('تشفير') || n.contains('اختبار الاختراق')) {
      return _LessonBlueprint(
        titles: ['مفاهيم الأمن والتهديدات', 'الحماية والتحليل الأمني', 'دراسة حالة أمنية'],
        topics: ['الأصول والتهديدات ونماذج المخاطر', 'الضوابط والتشفير والممارسات الآمنة', 'تحليل حادثة أو تصميم حماية مناسبة'],
        terms: ['أصل', 'تهديد', 'ثغرة', 'ضابط أمني'],
        correct: 'حماية الأصول والأنظمة عبر فهم التهديدات والثغرات وتطبيق ضوابط مناسبة',
        distractor1: 'اختبار أنظمة الآخرين دون تصريح',
        distractor2: 'إخفاء الأخطاء بدل معالجتها',
        distractor3: 'اعتبار كلمة المرور حماية كافية لكل نظام',
      );
    }
    if (n.contains('هندسة البرمجيات') || n.contains('software') || n.contains('devops')) {
      return _LessonBlueprint(
        titles: ['مشكلة البرمجيات ودورة التطوير', 'المتطلبات والتصميم والجودة', 'تطوير وتسليم برمجية قابلة للصيانة'],
        topics: ['دورة حياة البرمجيات وممارسات التطوير', 'المتطلبات والتصميم والاختبار', 'التكامل والتسليم والتحسين المستمر'],
        terms: ['متطلب', 'تصميم', 'اختبار', 'صيانة'],
        correct: 'هندسة البرمجيات تستخدم عمليات ومنهجيات لإنتاج برمجيات موثوقة قابلة للصيانة',
        distractor1: 'كتابة الكود دون متطلبات أو اختبار',
        distractor2: 'اعتبار المشروع منتهيًا عند أول تشغيل',
        distractor3: 'إلغاء التوثيق والمراجعة',
      );
    }
    if (n.contains('رسوميات') || n.contains('graphics') || n.contains('تصميم') || n.contains('تفاعل') || n.contains('hci') || n.contains('واجهات')) {
      return _LessonBlueprint(
        titles: ['المستخدم والمشكلة والتصميم', 'المبادئ البصرية والتفاعلية', 'بناء نموذج واختباره'],
        topics: ['فهم المستخدم والسياق والهدف', 'التخطيط البصري والتفاعل وقابلية الاستخدام', 'النمذجة والاختبار والتحسين'],
        terms: ['مستخدم', 'واجهة', 'تفاعل', 'قابلية الاستخدام'],
        correct: 'تصميم تجربة أو واجهة تستند إلى احتياجات المستخدم ثم اختبارها وتحسينها',
        distractor1: 'اختيار الشكل دون معرفة المستخدم',
        distractor2: 'إضافة عناصر كثيرة بلا هدف',
        distractor3: 'اعتبار التصميم مكتملًا دون اختبار',
      );
    }
    if (n.contains('نظم المعلومات') || n.contains('إدارة') || n.contains('مشاريع') || n.contains('حوكمة')) {
      return _LessonBlueprint(
        titles: ['المشكلة التنظيمية ونظم المعلومات', 'التحليل واتخاذ القرار', 'حل معلوماتي قابل للقياس'],
        topics: ['أصحاب المصلحة والعمليات والمعلومات', 'تحليل المتطلبات والبيانات ومؤشرات الأداء', 'تصميم حل معلوماتي وقياس أثره'],
        terms: ['نظام معلومات', 'عملية', 'متطلب', 'مؤشر أداء'],
        correct: 'استخدام الأشخاص والعمليات والتقنية والبيانات لدعم أهداف المنظمة وقراراتها',
        distractor1: 'شراء تقنية دون تحليل المشكلة',
        distractor2: 'اعتبار النظام مجرد أجهزة',
        distractor3: 'اتخاذ القرار من دون بيانات أو هدف',
      );
    }
    if (n.contains('تشغيل') || n.contains('أنظمة التشغيل') || n.contains('معمار') || n.contains('هندسة الحاسوب') || n.contains('أنظمة مضمنة')) {
      return _LessonBlueprint(
        titles: ['بنية النظام ومكوناته', 'الموارد والتنفيذ والتفاعل', 'تحليل نظام حاسوبي'],
        topics: ['المعالج والذاكرة والبرمجيات كمنظومة', 'إدارة الموارد والتنفيذ والتواصل بين المكونات', 'تحليل تصميم نظام وفق متطلباته'],
        terms: ['معالج', 'ذاكرة', 'موارد', 'تنفيذ'],
        correct: 'فهم تفاعل مكونات النظام الحاسوبي وإدارة الموارد لتحقيق متطلبات محددة',
        distractor1: 'دراسة مكون واحد بمعزل دائمًا',
        distractor2: 'اعتبار البرمجيات والعتاد غير مترابطين',
        distractor3: 'زيادة الموارد دون قياس الحاجة',
      );
    }
    return _LessonBlueprint(
      titles: ['مدخل إلى $courseName', 'المفاهيم والمكونات في $courseName', 'تطبيقات $courseName وتحليلها'],
      topics: ['مشكلة المجال ومفاهيمه الأساسية', 'المكونات والعلاقات والمبادئ', 'تطبيق المفاهيم على مسألة واقعية'],
      terms: ['مفهوم', 'مكوّن', 'مبدأ', 'تطبيق'],
      correct: 'فهم المفاهيم الأساسية للمقرر وربطها بتطبيق عملي قابل للتحليل',
      distractor1: 'حفظ المصطلحات دون تطبيق',
      distractor2: 'استخدام أداة دون فهم المشكلة',
      distractor3: 'قبول النتيجة دون تحليل',
    );
  }

  static const _LessonBlueprint _blueprintDummy = _LessonBlueprint(
    titles: ['','',''], topics: ['','',''], terms: ['','','',''],
    correct: '', distractor1: '', distractor2: '', distractor3: '',
  );

  /// Global top-level academic fields. The current reference catalog is
  /// grouped under computing and information technology and can expand without
  /// changing the lower academic hierarchy.
  static final fields = <AcademicField>[
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

class _LessonBlueprint {
  const _LessonBlueprint({
    required this.titles,
    required this.topics,
    required this.terms,
    required this.correct,
    required this.distractor1,
    required this.distractor2,
    required this.distractor3,
  });
  final List<String> titles;
  final List<String> topics;
  final List<String> terms;
  final String correct;
  final String distractor1;
  final String distractor2;
  final String distractor3;
}
