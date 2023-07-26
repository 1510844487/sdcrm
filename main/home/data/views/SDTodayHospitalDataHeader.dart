import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/GlobalConst/SDString.dart';

class SDTodayHospitalDataHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                  child: Text(SDString.hospital_name,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: SDColor.lightBlack)))),
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(SDString.fetch_number,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: SDColor.lightBlack)))),
          Expanded(
              flex: 2,
              child: Container(
                  child: Text(SDString.average_value,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: SDColor.lightBlack)))),
        ],
      ),
    );
  }
}
