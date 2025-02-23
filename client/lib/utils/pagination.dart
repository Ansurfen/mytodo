// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Pagination<T> extends PaginationCounter {
  Rx<List<T>> data = Rx([]);
  late int _limit;

  Pagination({int index = 0, int limit = 10}) : super(page: index) {
    _limit = limit;
  }

  List<T> getData() {
    return data.value;
  }

  void setData(List<T> v) {
    data.value = v;
  }

  void refresh() {
    data.refresh();
  }

  void setLimit(int s) {
    _limit = s;
  }

  int getLimit() {
    return _limit;
  }
}

class PaginationCounter {
  int page;

  PaginationCounter({this.page = 0});

  void inc() {
    page++;
  }

  void dec() {
    page--;
  }

  void reset() {
    page = 0;
  }

  int index() {
    return page;
  }

  void setIndex(int i) {
    page = i;
  }
}
