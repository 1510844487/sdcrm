import 'package:flutter/cupertino.dart';

class RefreshListener{

  VoidCallback? doRefresh;
  ValueChanged<bool>? refreshResult;

  RefreshListener({this.refreshResult});

}

