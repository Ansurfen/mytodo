// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/map/select/place.dart';

class SearchModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Rx<List<Place>> _suggestions = Rx(history);
  Rx<List<Place>> get suggestions => (_suggestions);

  String _query = '';
  String get query => _query;

  SearchModel(this.onSelected);

  late final ValueChanged<Object> onSelected;

  Future<void> onQueryChanged(String query) async {
    if (query == _query) {
      return;
    }

    _query = query;
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _suggestions.value = history;
    } else {
      Dio dio = Dio();
      await dio.get('https://photon.komoot.io/api/?q=$query').then((value) {
        final dynamic body = value.data;

        // ignore: avoid_dynamic_calls
        final List<dynamic> features = body['features'] as List<dynamic>;

        _suggestions.value = features
            .map((dynamic e) => Place.fromJson(e as Map<String, dynamic>))
            .toSet()
            .toList();
      });
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _suggestions.value = history;
    notifyListeners();
  }
}

const List<Place> history = <Place>[
  Place(
    name: 'San Fracisco',
    country: 'United States of America',
    state: 'California',
  ),
  Place(
    name: 'Singapore',
    country: 'Singapore',
  ),
  Place(
    name: 'Munich',
    state: 'Bavaria',
    country: 'Germany',
  ),
  Place(
    name: 'London',
    country: 'United Kingdom',
  ),
];
