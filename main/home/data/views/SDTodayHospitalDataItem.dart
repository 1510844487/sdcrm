import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';

class SDTodayHospitalDataItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                child: Text(
                  "北京医科大学附属第二医院清华长庚医院第二附属附属医院预防接诊科室",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.normal,
                      color: SDColor.black),
                ),
              )),
          SizedBox(
            width: 28,
          ),
          Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  "122002",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.normal,
                      color: SDColor.black),
                ),
              )),
          Expanded(
              flex: 2,
              child: Container(
                child: Text(
                  "+5（+40%）",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.normal,
                      color: SDColor.red),
                ),
              )),
        ],
      ),
    );
  }
}
