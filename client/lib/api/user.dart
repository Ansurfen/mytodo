// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';

Future userVerifyOTPRequest({required String email}) async {
  return HTTP.post("/user/verify", data: {"email": email});
}

Future userRecoverRequest({
  required String email,
  required String pwd,
  required String otp,
}) async {
  return HTTP.post(
    "/user/recover",
    data: {"email": email, "pwd": pwd, "otp": otp},
  );
}

Future<String> userSignUpRequest({
  required String email,
  required String pwd,
  required String username,
  required String telephone,
  required bool isMale,
  required String otp,
}) async {
  return (await HTTP.post(
    "/user/signup",
    data: {
      "email": email,
      "pwd": pwd,
      "username": username,
      "telephone": telephone,
      "is_male": isMale,
      "otp": otp,
    },
  )).data["jwt"];
}

Future<String> userLoginRequest({
  required String email,
  required String pwd,
}) async {
  return (await HTTP.post(
    "/user/login",
    data: {"email": email, "pwd": pwd},
  )).data["jwt"];
}

Future<User> userDetailRequest() async {
  return User.fromJson(
    (await HTTP.get(
      "/user/detail",
      options: Options(headers: {"Authorization": Guard.jwt}),
    )).data["user"],
  );
}

class UserSignRequest {
  String email;
  String password;

  UserSignRequest(this.email, this.password);

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'email': email, 'password': password}.entries);
    return formData;
  }
}

class UserSignResponse extends BaseResponse {
  String jwt = "";

  UserSignResponse(super.json);

  UserSignResponse.fromResponse(Response res) : super(res.data) {
    try {
      jwt = res.data["data"]["jwt"];
    } catch (e) {}
  }
}

Future<UserSignResponse> userSign({
  required String email,
  required String password,
}) async {
  return UserSignResponse.fromResponse(
    await HTTP.post("/user/sign", data: {"email": email, "pwd": password}),
  );
}

class UserGetRequest {}

class UserGetResponse extends BaseResponse {
  late User user;

  UserGetResponse(super.json);

  UserGetResponse.fromResponse(Response res)
    : user = User.fromJson(res.data["data"]),
      super(res.data);
}

Future<UserGetResponse> userGet(UserGetRequest req) async {
  return UserGetResponse.fromResponse(
    await HTTP.post(
      "/user/get",
      options: Options(headers: {"Authorization": Guard.jwt}),
    ),
  );
}

class UserEditRequest {
  String name;
  String email;
  String? telephone;
  TFile? profile;

  UserEditRequest(this.name, this.email, {this.telephone, this.profile});

  Future<FormData> toFormData() async {
    FormData formData = FormData();
    formData.fields.addAll(
      {'name': name, 'email': email, 'telephone': telephone ?? ""}.entries,
    );
    if (profile != null) {
      formData.files.add(MapEntry("profile", await profile!.m));
    }
    return formData;
  }
}

class UserEditResponse extends BaseResponse {
  UserEditResponse(super.json);

  UserEditResponse.fromResponse(Response res) : super(res.data);
}

Future<UserEditResponse> userEdit(UserEditRequest req) async {
  return UserEditResponse.fromResponse(
    await HTTP.post(
      "/user/edit",
      data: await req.toFormData(),
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}

Future userEditRequest({required User u, TFile? profile}) async {
  FormData formData = FormData();
  formData.fields.addAll(
    {
      "name": u.name,
      "email": u.email,
      "telephone": u.telephone ?? "",
      "is_male": u.isMale ? "1" : "0",
    }.entries,
  );
  if (profile != null) {
    formData.files.add(MapEntry("profile", await profile.m));
  }
  return await HTTP.post(
    "/user/edit",
    data: formData,
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
}

Image userProfile(int id) {
  return Image.network("${Guard.server}/user/profile/$id");
}

Future<User> userInfo(int id) async {
  var data = (await HTTP.get('/user/info/$id')).data;
  return User(id, data["data"]["name"], "");
}
