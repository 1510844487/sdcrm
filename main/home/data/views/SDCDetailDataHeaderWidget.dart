import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SDCDetailDataHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(
                "组织名称",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFF999999)),
              ))),
          SizedBox(width: 30),
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(
                "团队捐单",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFF999999)),
              ))),
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(
                "团队发起",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFF999999)),
              ))),
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(
                "有效发起",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFF999999)),
              ))),
          Expanded(
              flex: 1,
              child: Container(
                  child: Text(
                "爆款数量",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFF999999)),
              ))),
        ],
      ),
    );
  }
}
