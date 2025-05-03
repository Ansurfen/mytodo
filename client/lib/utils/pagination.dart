// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Pagination<T> extends PaginationCounter {
  Rx<List<T>> data = Rx([]);
  late int _limit;
  final RxInt _total = RxInt(0);
  Function? _callback;
  bool _hasMore = true;

  Pagination({super.page, int limit = 10}) {
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

  void setTotal(int total) {
    _total.value = total;
    _hasMore = page * _limit < total;
  }

  int getTotal() {
    return _total.value;
  }

  void setCallback(Function callback) {
    _callback = callback;
  }

  bool hasMore() {
    return _hasMore;
  }

  Future<void> loadMore() async {
    if (!_hasMore || _callback == null) return;

    await _callback!();
  }

  void reset() {
    super.reset();
    data.value = [];
    _total.value = 0;
    _hasMore = true;
  }
}

class PaginationCounter {
  int page;

  PaginationCounter({this.page = 1});

  void inc() {
    page++;
  }

  void dec() {
    if (page > 1) {
      page--;
    }
  }

  void reset() {
    page = 1;
  }

  int index() {
    return page;
  }

  void setIndex(int i) {
    page = i;
  }
}
