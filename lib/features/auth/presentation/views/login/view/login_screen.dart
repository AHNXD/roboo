import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/enums.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/validation.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/main_screen.dart';
import 'package:roboo/core/widgets/password_textfield.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/presentation/view-model/login_cubit/login_cubit.dart';
import 'package:roboo/features/auth/presentation/views/login/view/widgets/forget_password_link_widget.dart';
import 'package:roboo/features/auth/presentation/views/register/view/register_screen.dart';
import '../../../../../../core/widgets/custome_text_field.dart';
import '../../forget-password/presentation/view/forget_password_screen.dart';
import '../../widgets/auth_footer_widget.dart';
import '../../widgets/auth_header_widget.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getit.get()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is LoginSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              MainScreen.routeName,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                children: [
                  const Positioned.fill(child: DotBackground()),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const AuthHeader(),
                          const SizedBox(height: 30),
                          Hero(
                            tag: 'message_bubble',
                            child: RobotMessageBubble(
                              message: "login_welcome".tr(context),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  hintText: "email_hint".tr(context),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.email,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PasswordTextField(
                                  hintText: "password_hint".tr(context),
                                  controller: _passwordController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.password,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ForgotPasswordLink(
                                  text: "forgot_password".tr(context),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      ForgotPasswordScreen.routeName,
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                if (isLoading)
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColors,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.primaryTwoColors,
                                          offset: Offset(0, 3),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  PrimaryButton(
                                    text: "login_btn".tr(context),
                                    backgroundColor: AppColors.primaryColors,
                                    mainColor: AppColors.primaryTwoColors,
                                    onTap: () => _submitLogin(context),
                                  ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: "google_login".tr(context),
                                  withBorder: true,
                                  mainColor: AppColors.primaryColors,
                                  imagePath: AssetsData.googleIcon,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          AuthFooter(
                            text: "no_account".tr(context),
                            actionText: "create_account_now".tr(context),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RegisterScreen.routeName,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
