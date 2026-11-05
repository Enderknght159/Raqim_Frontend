# Raqim — Flutter client

The Flutter front end for Raqim, a mosque management system. It talks to a Laravel API (kept in a separate, private repository).

Screens cover sign-in, the student list and student file, attendance, courses, and the teacher's own view. The app is built for a weak or missing connection: reads are cached locally, and changes made offline go into a queue that is sent when the connection comes back.

## Structure

```text
lib/
  core/       config, network, storage, router, theme, shared widgets
  features/   auth, students, student, attendance, courses, teacher, admin
  shared/
```

Each feature keeps `data/`, `domain/` and `presentation/` apart.

## Running

```sh
flutter pub get
flutter run
```

The API address comes from a `--dart-define` flag and defaults to the live backend:

```sh
flutter run --dart-define=API_BASE_URL=https://example.com/api/v1 --dart-define=ENV=dev
```

`ENV` accepts `dev`, `staging` or `prod`; `LOGGING_ENABLED=false` turns off request logging for a release build.

## قاعدة إلزامية (Governance)

**أي تعديل على الكود — من أي شخص (بشري أو مساعد) — يستلزم تحديث `../plan/0-overview/feature-status.md` في نفس الالتزام (commit):**
- من **يضيف** ميزة → يُضيف صفًّا بحالتها.
- من **يُعدّل** ميزة → يُحدّث حالتها وملاحظاتها.
- من **يحذف/يؤرشف** ميزة → ينقل صفّها إلى «مؤرشف» بدل حذفه.

> لا يُقبل أي تغيير في الكود دون تحديث الجدول المقابل له.

**قاعدة إعادة الاستخدام (إلزامية):** كل ويدجت يُبنى كلاسًا مستقلاً قابلاً لإعادة الاستخدام في `lib/core/widgets/` أو `lib/features/<feature>/presentation/widgets/` قبل استخدامه؛ لا تُنشأ ويدجتات داخليّة مكرّرة (`plan/README.md`).
