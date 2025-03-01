// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';
import 'package:flutter/material.dart';

List names = [
  "Ling Waldner",
  "Gricelda Barrera",
  "Lenard Milton",
  "Bryant Marley",
  "Rosalva Sadberry",
  "Guadalupe Ratledge",
  "Brandy Gazda",
  "Kurt Toms",
  "Rosario Gathright",
  "Kim Delph",
  "Stacy Christensen",
];

List messages = [
  "Hey, how are you doing?",
  "Are you available tomorrow?",
  "It's late. Go to bed!",
  "This cracked me up 😂😂",
  "Flutter Rocks!!!",
  "The last rocket🚀",
  "Griezmann signed for Barca❤️❤️",
  "Will you be attending the meetup tomorrow?",
  "Are you angry at something?",
  "Let's make a UI serie.",
  "Can i hear your voice?",
  "Will you be attending the meetup tomorrow?\nCan i hear your voice?\nCan i hear your voice?\n",
  "Will you be attending the meetup tomorrow? Can i hear your voice? Can i hear your voice? ",
];

List imagesData = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80',
  'https://th.bing.com/th/id/R.b0ea268fa1be279d112489ce83ad4696?rik=qItsh%2fBiy33hlg&riu=http%3a%2f%2fwww.quazero.com%2fuploads%2fallimg%2f140303%2f1-140303215009.jpg&ehk=S6PLWamt%2bMzQV8uO9ugcU5d5M19BpXtCpNz2cRJ7q9M%3d&risl=&pid=ImgRaw&r=0',
];

List videos = [];

class Mock {
  static final List<Color> _colors = [
    const Color(0xff8D7AEE),
    const Color(0xffF468B7),
    const Color(0xffFEC85C),
    const Color(0xff5FD0D3),
    const Color(0xffBFACAA),
  ];

  static Random random = Random();

  static void init([int? seed]) {
    random = Random(seed);
  }

  static String username() {
    return names[random.nextInt(names.length)];
  }

  static String text() {
    return messages[random.nextInt(messages.length)];
  }

  static int number({int min = 0, int max = 100}) {
    min > max ? throw ArgumentError("min should be lower than max") : null;
    if (min.isNegative && max.isNegative) {
      return min + random.nextInt(min.abs() - max.abs() + 1);
    } else if (min.isNegative) {
      return min + random.nextInt(min.abs() + max + 1);
    }
    return min + random.nextInt(max - min + 1);
  }

  static bool boolean() {
    return random.nextBool();
  }

  static double float() {
    return random.nextDouble();
  }

  static DateTime dateTime() {
    if (boolean()) {
      return DateTime.now().subtract(Duration(seconds: random.nextInt(100000)));
    }
    return DateTime.now().add(Duration(seconds: random.nextInt(100000)));
  }

  static uuid() {}

  static Coordinates location() {
    return Coordinates(
      latitude: float() * 90 * (boolean() ? 1 : -1),
      longitude: float() * 180 * (boolean() ? 1 : -1),
    );
  }

  static Color color() {
    return _colors[random.nextInt(_colors.length)];
  }

  static String image() {
    return imagesData[number(max: imagesData.length - 1)];
  }

  static List<String> images({int len = 5}) {
    List<String> res = [];
    for (var i = 0; i < len; i++) {
      res.add(image());
    }
    return res;
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  @override
  String toString() {
    return "latitude: $latitude, longitude: $longitude";
  }
}
