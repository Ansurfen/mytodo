import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get pastel {
    var hsl = HSLColor.fromColor(this);
    var newSaturation = hsl.saturation > 0.1 ? 0.65 : hsl.saturation;
    return hsl.withSaturation(newSaturation).withLightness(0.87).toColor();
  }

  Color get onPastel {
    var hsl = HSLColor.fromColor(this);
    var newSaturation = hsl.saturation > 0.1 ? 0.48 : hsl.saturation;
    return hsl.withSaturation(newSaturation).withLightness(0.20).toColor();
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

extension DateTimeExtensions on DateTime {
  /// Returns [DateTime] without timestamp.
  DateTime get withoutTime => DateTime(year, month, day);
}

extension IterableExtension<T> on List<T> {
  Iterable<T> distinctBy(Object getCompareValue(T e)) {
    var idSet = <Object>{};
    var distinct = <T>[];
    for (var d in this) {
      if (idSet.add(getCompareValue(d))) {
        distinct.add(d);
      }
    }
    return distinct;
  }
}
