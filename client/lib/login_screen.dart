import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:my_todo/constants.dart';
import 'package:my_todo/dashboard_screen.dart';
import 'package:my_todo/user.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  const LoginScreen({super.key});

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(data.name)) {
        return 'User not exists';
      }
      if (mockUsers[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: "MyTodo👋",
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      onConfirmRecover: _signupConfirm,
      onConfirmSignup: _signupConfirm,
      loginAfterSignUp: false,
      loginProviders: [
        // LoginProvider(
        //   button: Buttons.linkedIn,
        //   label: 'Sign in with LinkedIn',
        //   callback: () async {
        //     return null;
        //   },
        //   providerNeedsSignUpCallback: () {
        //     // put here your logic to conditionally show the additional fields
        //     return Future.value(true);
        //   },
        // ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.google,
        //   label: 'Google',
        //   callback: () async {
        //     return null;
        //   },
        // ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.githubAlt,
        //   label: 'Github',
        //   callback: () async {
        //     debugPrint('start github sign in');
        //     await Future.delayed(loginTime);
        //     debugPrint('stop github sign in');
        //     return null;
        //   },
        // ),
      ],
      termsOfService: [
        // TermOfService(
        //   id: 'newsletter',
        //   mandatory: false,
        //   text: 'Newsletter subscription',
        // ),
        TermOfService(
          id: 'general-term',
          mandatory: true,
          text: 'Term of services',
          linkUrl: 'https://github.com/NearHuscarl/flutter_login',
        ),
      ],
      additionalSignupFields: [
        const UserFormField(
          keyName: 'Username',
          icon: Icon(FontAwesomeIcons.userLarge),
        ),
        const UserFormField(keyName: 'Name'),
        const UserFormField(keyName: 'Surname'),
        UserFormField(
          keyName: 'phone_number',
          displayName: 'Phone Number',
          userType: LoginUserType.phone,
          fieldValidator: (value) {
            final phoneRegExp = RegExp(
              '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$',
            );
            if (value != null &&
                value.length < 7 &&
                !phoneRegExp.hasMatch(value)) {
              return "This isn't a valid phone number";
            }
            return null;
          },
        ),
      ],
      theme: LoginTheme(
        // primaryColor: Colors.purple,
        titleStyle: TextStyle(
          fontFamily: 'Pacifico',
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
        primaryColor: Colors.redAccent,
        cardTheme: CardTheme(elevation: 5),
      ),
      messages: LoginMessages(
        userHint: 'email'.tr,
        passwordHint: 'password'.tr,
        confirmPasswordHint: 'confirm_password'.tr,
        loginButton: 'login'.tr,
        signupButton: 'signup'.tr,
        forgotPasswordButton: 'forgot_password'.tr,
        recoverPasswordButton: 'recover'.tr,
        goBackButton: 'back'.tr,
        confirmPasswordError: 'confirm_password_error'.tr,
        confirmRecoverIntro: 'confirm_recover_intro'.tr,
        recoverPasswordIntro: 'recovery_password_intro'.tr,
        recoverCodePasswordDescription: 'recovery_code_password_description'.tr,
        confirmRecoverSuccess: 'confirm_recover_success'.tr,
        recoverPasswordSuccess: 'recovery_code_sent_success_detail'.tr,
        flushbarTitleSuccess: 'recovery_code_sent_success'.tr,
        recoveryCodeHint: 'recovery_code'.tr,
        recoveryCodeValidationError: 'recovery_code_validator'.tr,
        setPasswordButton: 'set_password'.tr,
      ),
      userValidator: (value) {
        if (value != null && !EmailValidator.validate(value)) {
          return "email_validator".tr;
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'password_is_empty'.tr;
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (final element in signupData.termsOfService) {
            debugPrint(
              ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}',
            );
          }
        }
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      headerWidget: const IntroWidget(),
    );
  }
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "You are trying to login/sign up on server hosted on ",
              ),
              TextSpan(
                text: "example.com",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.justify,
        ),
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.all(8.0), child: Text("Authenticate")),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
