// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
class Place {
  const Place({
    this.lat = 0,
    this.lng = 0,
    required this.name,
    this.state = '',
    required this.country,
  });

  factory Place.fromJson(Map<String, dynamic> map) {
    final Map<String, dynamic> props =
        map['properties']! as Map<String, dynamic>;

    return Place(
      name: props['name'] as String? ?? '',
      state: props['state'] as String? ?? '',
      country: props['country'] as String? ?? '',
      lng: map["geometry"]["coordinates"][0] ?? 0,
      lat: map["geometry"]["coordinates"][1] ?? 0,
    );
  }
  final String name;
  final String state;
  final String country;
  final double lat;
  final double lng;

  bool get hasState => state.isNotEmpty == true;
  bool get hasCountry => country.isNotEmpty == true;

  bool get isCountry => hasCountry && name == country;
  bool get isState => hasState && name == state;

  String get address {
    if (isCountry) {
      return country;
    }
    return '$name, $level2Address';
  }

  String get addressShort {
    if (isCountry) {
      return country;
    }
    return '$name, $country';
  }

  String get level2Address {
    if (isCountry || isState || !hasState) {
      return country;
    }
    if (!hasCountry) {
      return state;
    }
    return '$state, $country';
  }

  @override
  String toString() =>
      'Place(name: $name, state: $state, country: $country, coordinates: ($lat, $lng))';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Place &&
        other.name == name &&
        other.state == state &&
        other.country == country;
  }

  @override
  int get hashCode => name.hashCode ^ state.hashCode ^ country.hashCode;
}
