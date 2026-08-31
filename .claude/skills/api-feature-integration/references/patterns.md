# Canonical Layer Templates

Extracted from working code in this repo (`news`, `courses`, `topics`, `product-details`).
Replace `X` / `Thing` with the feature name. Keep the file/class naming exactly as shown.

---

## 1. Endpoint — `lib/core/Api_services/urls.dart`

Add to the matching `// current …` section:

```dart
static const String quizzes = "quizzes";
static String quizDetails(int quizId) => "quizzes/$quizId";
static String quizSubmit(int quizId) => "quizzes/$quizId/submit";
```

---

## 2. Model — `<feature>/data/models/x_model.dart`

No codegen. Hand-written `fromJson`, everything defensive, unproven fields nullable.

```dart
import '../../../../../core/utils/api_media_url_resolver.dart';

class QuizModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final int? timeLimit;
  final int points;
  final String imageUrl;

  const QuizModel({
    this.id,
    this.title,
    this.titleAr,
    this.timeLimit,
    required this.points,
    required this.imageUrl,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      timeLimit: _parseInt(json['time_limit']),
      points: _parseInt(json['points']) ?? 0,
      imageUrl: ApiMediaUrlResolver.resolve(json['image']?.toString()),
    );
  }

  // Locale-aware accessors live on the model, never in widgets.
  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) return titleAr!;
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
```

---

## 3. Repository contract — `<feature>/data/repos/x_repo.dart`

```dart
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/quiz_model.dart';

abstract class QuizzesRepo {
  Future<Either<Failure, List<QuizModel>>> getQuizzes({int? topicId});
}
```

---

## 4. Repository impl — `<feature>/data/repos/x_repo_impl.dart`

### Envelope with a named array (`courses`, `quizzes`)

```dart
import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/quiz_model.dart';
import 'quizzes_repo.dart';

class QuizzesRepoImpl implements QuizzesRepo {
  final ApiServices _apiServices;

  QuizzesRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<QuizModel>>> getQuizzes({int? topicId}) async {
    try {
      final response = await _apiServices.get(
        endPoint: _quizzesEndpoint(topicId: topicId),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final quizzesData = data is Map<String, dynamic> ? data['quizzes'] : null;

        if (quizzesData is List) {
          final quizzes = quizzesData
              .whereType<Map<String, dynamic>>()
              .map(QuizModel.fromJson)
              .toList();
          return right(quizzes);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  // ApiServices.get has no query-param map — build the query into the path.
  String _quizzesEndpoint({int? topicId}) {
    if (topicId == null) return Urls.quizzes;

    return Uri(
      path: Urls.quizzes,
      queryParameters: {'topic_id': topicId.toString()},
    ).toString();
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
```

### Laravel pagination (products, orders, favorites, galleries, faqs)

Only the extraction differs — the list is one level deeper:

```dart
final paginationData = responseData['data'];
final data = paginationData is Map<String, dynamic> ? paginationData['data'] : null;
if (data is List) { /* … */ }
```

### Single object (`privacy-policy`, `products/{id}`, `auth/me`)

```dart
final data = responseData['data'];
if (data is Map<String, dynamic>) {
  return right(ProductModel.fromJson(data));
}
return left(ServerFailure(ErrorHandler.defaultMessage()));
```

### POST

```dart
final response = await _apiServices.post(
  endPoint: Urls.feedbacks,
  data: {'rating': rating, 'note': note},
);
```

Accept `200` **and** `201` for create endpoints (`orders`, `feedbacks` return `201`).
Multipart uses `_apiServices.postFormData(endPoint: ..., data: FormData.fromMap({...}))`.

---

## 5. Cubit + state — `<feature>/presentation/view-model/x_cubit/`

`x_cubit.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/quiz_model.dart';
import '../../../data/repos/quizzes_repo.dart';

part 'quizzes_state.dart';

class QuizzesCubit extends Cubit<QuizzesState> {
  final QuizzesRepo _quizzesRepo;

  QuizzesCubit(this._quizzesRepo) : super(const QuizzesInitial());

  Future<void> getQuizzes({int? topicId}) async {
    emit(const QuizzesLoading());

    final result = await _quizzesRepo.getQuizzes(topicId: topicId);
    result.fold(
      (failure) => emit(QuizzesError(errorMsg: failure.message)),
      (quizzes) {
        if (quizzes.isEmpty) {
          emit(const QuizzesEmpty());
          return;
        }
        emit(QuizzesLoaded(quizzes: quizzes));
      },
    );
  }
}
```

`x_state.dart`:

```dart
part of 'quizzes_cubit.dart';

sealed class QuizzesState extends Equatable {
  const QuizzesState();

  @override
  List<Object?> get props => [];
}

final class QuizzesInitial extends QuizzesState {
  const QuizzesInitial();
}

final class QuizzesLoading extends QuizzesState {
  const QuizzesLoading();
}

final class QuizzesLoaded extends QuizzesState {
  final List<QuizModel> quizzes;

  const QuizzesLoaded({required this.quizzes});

  @override
  List<Object?> get props => [quizzes];
}

final class QuizzesEmpty extends QuizzesState {
  const QuizzesEmpty();
}

final class QuizzesError extends QuizzesState {
  final String errorMsg;

  const QuizzesError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
```

`sealed` + `final class` matters: the screens use exhaustive `switch` expressions, so a
missing state becomes a compile error instead of a silent blank screen.

### When a filter must survive reloads

Carry the already-loaded context (topics, selected index) on the loading/error states so the
tab bar does not disappear mid-request. See `CoursesCubit.selectTopic` and
`CoursesContentLoading` / `CoursesContentError` in
`lib/features/app/courses/presentation/view-model/courses_cubit/`.

---

## 6. DI — `lib/core/utils/services_locater.dart`

```dart
getit.registerSingleton<QuizzesRepo>(QuizzesRepoImpl(getit.get<ApiServices>()));
```

Feature Cubits are **not** registered — they are created at the screen. Only app-wide state
is registered (`CartCubit`, `FavoritesCubit` lazy singletons; `OrdersCubit` factory).

---

## 7. Screen wiring

```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => QuizzesCubit(getit.get())..getQuizzes(),
    child: Scaffold(
      appBar: CustomAppbar(title: "quizzes_title".tr(context)),
      body: SafeArea(
        child: BlocBuilder<QuizzesCubit, QuizzesState>(
          builder: (context, state) {
            return switch (state) {
              QuizzesInitial() || QuizzesLoading() => StatusDisplayWidget(
                message: "wait".tr(context),
                withAnimation: true,
              ),
              QuizzesError(:final errorMsg) => StatusDisplayWidget(
                message: errorMsg.tr(context),
              ),
              QuizzesEmpty() => StatusDisplayWidget(
                message: "no_quizzes_available".tr(context),
              ),
              QuizzesLoaded(:final quizzes) => RefreshIndicator(
                onRefresh: context.read<QuizzesCubit>().getQuizzes,
                child: ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    final languageCode =
                        Localizations.localeOf(context).languageCode;

                    return QuizeListItem(
                      title: quiz.titleFor(languageCode),
                      points: quiz.points,
                    );
                  },
                ),
              ),
            };
          },
        ),
      ),
    ),
  );
}
```

Two Cubits on one screen (e.g. topics filter + content) use `MultiBlocProvider`; reused
app-wide cubits use `BlocProvider.value(value: getit<CartCubit>())`.
Actions dispatch through `context.read<XCubit>().method(...)` — never a repository call.

Shared presentation widgets to reuse before writing new ones:
`StatusDisplayWidget` (loading / empty / error), `ShimmerContainer`, `CustomErrorWidget`,
`CustomImageWidget`, `CustomAppbar`, `PrimaryButton`.

---

## 8. Localization

```json
// assets/lang/en.json
"no_quizzes_available": "No quizzes available currently",
// assets/lang/ar.json
"no_quizzes_available": "لا توجد اختبارات متاحة حالياً",
```

Both files, same key, every time. Also add any backend `message` key the endpoint can
return (the error path renders `errorMsg.tr(context)`, so an unmapped key leaks to the UI).

---

## 9. Verify

```bash
/Users/ahn/develop/flutter/bin/flutter analyze
```

There is no `test/` directory and no test convention. Do not stand one up as part of an
integration task.
