import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/app/profile/data/repos/profile_repo.dart';
import '../../features/app/profile/data/repos/profile_repo_impl.dart';
import '../../features/app/profile/data/repos/profile_password_repo.dart';
import '../../features/app/profile/data/repos/profile_password_repo_impl.dart';
import '../../features/auth/data/repos/login_repo/login_repo.dart';
import '../../features/auth/data/repos/login_repo/login_repo_ipml.dart';
import '../../features/auth/data/repos/logout_repo/logout_repo.dart';
import '../../features/auth/data/repos/logout_repo/logout_repo_iplm.dart';
import '../../features/auth/data/repos/register_repo/register_repo.dart';
import '../../features/auth/data/repos/register_repo/register_repo_iplm.dart';
import '../../features/auth/data/repos/reset_password_repo/reset_password_repo.dart';
import '../../features/auth/data/repos/reset_password_repo/reset_password_repo_iplm.dart';
import '../../features/auth/data/repos/token_repo/token_repo.dart';
import '../../features/auth/data/repos/token_repo/token_repo_ipml.dart';
import '../../features/shared/complaints/data/repos/feedback_repo.dart';
import '../../features/shared/complaints/data/repos/feedback_repo_impl.dart';
import '../../features/shared/faq/data/repos/faq_repo.dart';
import '../../features/shared/faq/data/repos/faq_repo_impl.dart';
import '../Api_services/api_services.dart';
import '../locale/locale_cubit.dart';

final getit = GetIt.instance;

void setupLocatorServices() {
  // init Dio
  getit.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: Duration(minutes: 1),
      ),
    ),
  );

  getit.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  getit.registerLazySingleton<ApiServices>(() => ApiServices(getit.get<Dio>()));

  // auth singleton
  getit.registerSingleton<RegisterRepo>(
    RegisterRepoIplm(getit.get<ApiServices>()),
  );
  getit.registerSingleton<LoginRepo>(LoginRepoIpml(getit.get<ApiServices>()));
  getit.registerSingleton<LogoutRepo>(LogoutRepoIplm(getit.get<ApiServices>()));
  getit.registerSingleton<TokenRepo>(TokenRepoIpml(getit.get<ApiServices>()));
  getit.registerSingleton<ResetPasswordRepo>(
    ResetPasswordRepoImpl(getit.get<ApiServices>()),
  );
  getit.registerSingleton<ProfilePasswordRepo>(
    ProfilePasswordRepoImpl(getit.get<ApiServices>()),
  );
  getit.registerSingleton<ProfileRepo>(
    ProfileRepoImpl(getit.get<ApiServices>()),
  );
  getit.registerSingleton<FeedbackRepo>(
    FeedbackRepoImpl(getit.get<ApiServices>()),
  );
  getit.registerSingleton<FaqRepo>(FaqRepoImpl(getit.get<ApiServices>()));
}
