# TOFAN SMART ACADEMY — TOFAN AL-ABQARI

نظام تعليمي ذكي عالمي، يبدأ من الطالب البشري ويعمل معه العبقري طوفان كفريق واحد.

## Vision
- الطالب البشري + العبقري طوفان.
- AI Core متعدد النماذج وقابل للتوسع.
- مكتبة أكاديمية عالمية متعددة المجالات: المجال الأكاديمي/الجامعة/الكلية أو المركز/التخصص/السنة 1–4/الفصل 1–2/المقرر/الوحدة/الدرس، مع دورة تعلم كاملة للتدريب والتقييم والتحليل وتحديث المهارات والمشروع.
- تعلم تفاعلي، تقييم، تحليل تقدم، ومهارات.
- ملفات ومحاضرات واختبارات ومشاريع.
- AI Agents متخصصة للوظائف الأكاديمية.
- العربية RTL والإنجليزية.
- Android أولاً مع Web للابتوب.
- Backend آمن وقاعدة بيانات سحابية.

## Current foundation
هذا المستودع هو واجهة Flutter الأساسية للنظام، وتم تنظيفه من الأجزاء غير المطلوبة والتكرارات قبل بدء البناء الحقيقي.

## Preserved
- Android
- Web/PWA
- Flutter + Riverpod
- local conversation persistence
- AI abstraction layer
- voice feature foundation
- files feature foundation
- tests and project configuration

## Removed
- iOS platform scaffold
- Replit-specific configuration
- unused image-generation screen
- duplicate legacy OpenAI/Gemini service wrappers
- obsolete agent-memory notes

## Architecture direction
Presentation → Application → Domain → Data → AI Core → Backend API

في الإنتاج ستكون مفاتيح مزودي الذكاء الاصطناعي في الخادم، وليس داخل تطبيق الطالب.

## Build rule
نطوّر المشروع تدريجياً داخل هذا المستودع، مع الحفاظ على الأجزاء المفيدة، وعدم إنشاء مشروع بديل أو إعادة كتابة النظام بلا حاجة.