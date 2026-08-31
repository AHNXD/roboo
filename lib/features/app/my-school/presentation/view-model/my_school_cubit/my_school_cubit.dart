import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/failuer.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/homework_model.dart';
import '../../../data/repos/enrollment_repo.dart';
import '../../../data/repos/homework_repo.dart';
import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'my_school_state.dart';

class MySchoolCubit extends Cubit<MySchoolState> with SafeEmit<MySchoolState> {
  final EnrollmentRepo _enrollmentRepo;
  final HomeworkRepo _homeworkRepo;

  MySchoolCubit(this._enrollmentRepo, this._homeworkRepo)
    : super(const MySchoolInitial());

  Future<void> loadSchool() async {
    safeEmit(const MySchoolLoading());

    // Homework is section-scoped and simply comes back empty for a student who
    // is not enrolled, so it can be fetched alongside the enrolment check
    // instead of after it.
    final enrollmentFuture = _enrollmentRepo.getEnrollment();
    final homeworkFuture = _homeworkRepo.getHomework();

    final enrollmentResult = await enrollmentFuture;
    _pendingHomework = homeworkFuture;
    final enrollment = enrollmentResult.fold((failure) {
      safeEmit(MySchoolError(errorMsg: failure.message));
      return null;
    }, (enrollment) => enrollment);

    if (enrollment == null) return;

    if (!enrollment.isEnrolled) {
      // That homework request was made while the student had no section, so it
      // came back empty. Drop it: redeeming a code must re-fetch.
      _pendingHomework = null;
      safeEmit(const MySchoolNotEnrolled());
      return;
    }

    await _loadHomework(enrollment);
  }

  /// Joins a section with a teacher-issued coupon. A used or unknown code comes
  /// back as 422 with a message from the backend.
  Future<void> redeemCode(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) return;

    safeEmit(const MySchoolRedeeming());

    final result = await _enrollmentRepo.redeemCode(code: trimmedCode);
    await result.fold(
      (failure) async {
        safeEmit(MySchoolRedeemError(errorMsg: failure.message));
        safeEmit(const MySchoolNotEnrolled());
      },
      (enrollment) async {
        safeEmit(const MySchoolRedeemSuccess());
        await _loadHomework(enrollment);
      },
    );
  }

  /// Set when [loadSchool] already started the homework request in parallel.
  Future<Either<Failure, PagedResult<HomeworkModel>>>? _pendingHomework;

  EnrollmentModel? _enrollment;
  List<HomeworkModel> _homework = const [];
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> _loadHomework(EnrollmentModel enrollment) async {
    safeEmit(const MySchoolLoading());

    final result = await (_pendingHomework ?? _homeworkRepo.getHomework());
    _pendingHomework = null;
    result.fold(
      (failure) => safeEmit(MySchoolError(errorMsg: failure.message)),
      (page) {
        _enrollment = enrollment;
        _homework = page.items;
        _pagination = page.pagination;
        safeEmit(
          MySchoolLoaded(
            enrollment: enrollment,
            homework: _homework,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  /// Appends the next page of homework. A failure leaves the list on screen
  /// untouched; scrolling again retries.
  Future<void> loadMoreHomework() async {
    final enrollment = _enrollment;
    if (enrollment == null || _isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(
      MySchoolLoaded(
        enrollment: enrollment,
        homework: _homework,
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    final result = await _homeworkRepo.getHomework(page: _pagination.nextPage);

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(
        MySchoolLoaded(
          enrollment: enrollment,
          homework: _homework,
          hasMore: _pagination.hasMore,
        ),
      ),
      (page) {
        _homework = [..._homework, ...page.items];
        _pagination = page.pagination;
        safeEmit(
          MySchoolLoaded(
            enrollment: enrollment,
            homework: _homework,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }
}
