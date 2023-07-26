import 'package:flutter/cupertino.dart';

import 'RefreshListener.dart';

abstract class HomeBaseState<T extends StatefulWidget> extends State<T> {
  RefreshListener? refreshListener;

  HomeBaseState(this.refreshListener);

  @override
  void initState() {
    super.initState();
    doRefresh();
  }

  doRefresh() {
    if (refreshListener != null) {
      refreshListener!.doRefresh = () {
        getData();
      };
    }
  }

  refreshComplete(bool isSuccess) {
    if (refreshListener != null && refreshListener!.refreshResult != null) {
      refreshListener!.refreshResult!(isSuccess);
    }
  }

  getData();
}
