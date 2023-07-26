import 'package:flutter/material.dart';

import 'SDCDetailDataItemWidget.dart';

class DetailDataWidget extends StatelessWidget {
  bool? isUnfold;
  DetailDataWidget({this.isUnfold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemBuilder: _itemBuilder,
          itemCount: !(isUnfold ?? false) ? 3 : 6),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return SDCDetailDataItemWidget();
  }
}
