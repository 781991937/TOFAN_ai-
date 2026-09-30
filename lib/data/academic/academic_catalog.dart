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
    final titles = [
      'مقدمة إلى $courseName',
      'المفاهيم والمكونات الأساسية في $courseName',
      'التطبيقات الأساسية في $courseName',
    ];
    final focus = [
      'التعريف بالمجال ومشكلاته ومفاهيمه الأساسية',
      'فهم المكونات والمبادئ والعلاقات بينها',
      'تطبيق المفاهيم على مسألة واقعية وتحليل النتيجة',
    ];
    final lessonId = '$courseId-$lessonNumber';

    return AcademicLesson(
      id: lessonId,
      title: titles[lessonNumber - 1],
      content: 'هذا درس أكاديمي أصلي من TOFAN في مقرر $courseName. يشرح الدرس ${focus[lessonNumber - 1]} بصورة تدريجية، ويربط المفهوم بالممارسة والتقييم والمشروع.',
      learningOutcomes: [
        'يعرّف الطالب المفهوم الرئيس في الدرس ويحدد حدوده.',
        'يفسر العلاقة بين المفاهيم والعناصر الأساسية في $courseName.',
        'يطبق الفكرة على مثال أو مسألة بسيطة ويبرر النتيجة.',
      ],
      keyTerms: ['المفهوم الأساسي', 'المكوّن', 'التطبيق', 'التحليل'],
      examples: [
        'مثال تمهيدي: اختر مسألة بسيطة من $courseName وحدد المفهوم المستخدم فيها.',
        'مثال تطبيقي: قارن بين حالتين ووضّح أي مبدأ من مبادئ $courseName يفسر الفرق.',
      ],
      practices: [
        LessonPractice(
          id: '$lessonId-practice',
          title: 'تدريب عملي: $courseName',
          tasks: [
            PracticeTask(id: '$lessonId-p1', instruction: 'طبّق مفهوم الدرس على مثال صغير من $courseName، واكتب خطوات الحل بترتيب واضح.'),
            PracticeTask(id: '$lessonId-p2', instruction: 'أنشئ مثالًا جديدًا من واقعك، وحدد المفهوم والمكوّنات والنتيجة، ثم فسّر سبب اختيارك.'),
          ],
        ),
      ],
      assessments: [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم: ${titles[lessonNumber - 1]}',
          questions: [
            AssessmentQuestion(id: '$lessonId-q1', text: 'ما الهدف الرئيس من دراسة هذا الدرس في $courseName؟', options: ['فهم المفاهيم وتطبيقها على مشكلة', 'حفظ أسماء الملفات فقط', 'تغيير إعدادات الجهاز فقط', 'تثبيت نظام التشغيل فقط'], correctIndex: 0),
            AssessmentQuestion(id: '$lessonId-q2', text: 'ما الخطوة المناسبة بعد فهم المفهوم الأساسي؟', options: ['تطبيقه على مثال وتحليل النتيجة', 'تجاهل المثال', 'حذف البيانات', 'إيقاف التعلم'], correctIndex: 0),
            AssessmentQuestion(id: '$lessonId-q3', text: 'كيف يتحقق الطالب من فهمه للمفهوم؟', options: ['يشرح الفكرة ويطبقها ويبرر النتيجة', 'يحفظ العنوان فقط', 'ينسخ الإجابة دون فهم', 'يتجنب التدريب'], correctIndex: 0),
          ],
        ),
      ],
      projects: [
        AcademicProject(
          id: '$lessonId-project',
          title: 'مشروع تطبيقي: $courseName',
          description: 'أنجز تطبيقًا مصغرًا مرتبطًا بـ$courseName يوضح مفهوم الدرس، ثم وثّق المشكلة والحل والخطوات والنتيجة والمهارة التي اكتسبتها.',
        ),
      ],
    );
  }

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
