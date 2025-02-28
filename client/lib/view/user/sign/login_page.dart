import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/constants.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/user.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/user/sign/login_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController controller = Get.find<LoginController>();

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
      loginAfterSignUp: true,
      termsOfService: [
        TermOfService(
          id: 'general-term',
          mandatory: true,
          text: 'term_of_service'.tr,
          linkUrl: 'https://github.com/ansurfen/mytodo',
          validationErrorMessage: 'required'.tr,
        ),
      ],
      additionalSignupFields: [
        UserFormField(
          keyName: 'username',
          displayName: 'username'.tr,
          icon: Icon(FontAwesomeIcons.userLarge),
        ),
        UserFormField(
          keyName: 'phone_number',
          displayName: 'phone_number'.tr,
          userType: LoginUserType.phone,
          fieldValidator: (value) {
            final phoneRegExp = RegExp(
              '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$',
            );
            if (value != null &&
                value.length < 7 &&
                !phoneRegExp.hasMatch(value)) {
              return "phone_validator".tr;
            }
            return null;
          },
        ),
        UserFormField(
          keyName: 'is_male',
          displayName: 'is_male'.tr,
          icon: Icon(FontAwesomeIcons.phone),
          userType: LoginUserType.checkbox,
        ),
      ],
      theme: LoginTheme(
        errorColor: Colors.redAccent,
        switchAuthTextColor: Color(0xff132137),
        // primaryColor: Colors.purple,
        titleStyle: TextStyle(
          fontFamily: 'Pacifico',
          color: Color(0xff132137),
          fontWeight: FontWeight.w300,
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: HexColor.fromInt(0xFEFAF7),
        ),
        primaryColor: darken(HexColor.fromInt(0xF5EBE2)),
        buttonTheme: LoginButtonTheme(backgroundColor: Color(0xff132137)),
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
        additionalSignUpFormDescription: 'additional_signup_form_desc'.tr,
        additionalSignUpSubmitButton: 'additional_signup_submit'.tr,
        signUpSuccess: 'signup_success'.tr,
        confirmSignupIntro: 'confirm_signup_intro'.tr,
        confirmationCodeHint: 'confirm_code_hint'.tr,
        resendCodeButton: 'resend_code'.tr,
        confirmSignupButton: 'confirm_signup'.tr,
        confirmationCodeValidationError: 'confirm_code_validator'.tr,
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
      onSubmitAnimationCompleted: () {},
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      onResendCode: (data) {
        // showCountdownToast();
        return Future.delayed(const Duration(seconds: 5));
      },
      headerWidget: const IntroWidget(),
    );
  }

  void showCountdownToast() {
    int countdown = 5;
    void updateToast() {
      if (countdown >= 0) {
        showToast(
          "倒计时：$countdown 秒",
          position: ToastPosition.bottom,
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black87,
          textStyle: TextStyle(color: Colors.white),
        );
        countdown--;
        if (countdown >= 0) {
          Future.delayed(Duration(seconds: 1), updateToast);
        }
      }
    }

    updateToast();
  }

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      userSign(email: data.name, password: data.password)
          .then((res) {
            if (res.code != 200) {
              return res.msg;
            } else if (res.jwt.isEmpty) {
              return "invalid jwt";
            }
            Guard.jwt = "Bearer ${res.jwt}";
            userGet(UserGetRequest())
                .then((res) {
                  Guard.setUser(res.user);
                })
                .onError((error, stackTrace) {
                  showTipDialog(context, content: error.toString());
                  return;
                });
          })
          .onError((error, stackTrace) {
            showTipDialog(context, content: error.toString());
            return error.toString();
          });
      // if (!mockUsers.containsKey(data.name)) {
      //   return 'User not exists';
      // }
      // if (mockUsers[data.name] != data.password) {
      //   return 'Password does not match';
      // }
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
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(text: "authenticate_desc".tr),
          textAlign: TextAlign.justify,
        ),
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("authenticate".tr),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
