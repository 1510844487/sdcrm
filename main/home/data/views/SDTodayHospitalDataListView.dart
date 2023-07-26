import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SDTodayHospitalDataItem.dart';

class SDTodayHospitalDataListView extends StatelessWidget {
  final bool? isUnfold;

  SDTodayHospitalDataListView({this.isUnfold = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemBuilder: _itemBuilder,
        itemCount: !(isUnfold ?? false) ? 3 : 6);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return SDTodayHospitalDataItem();
  }
}
