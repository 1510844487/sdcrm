import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/utils/LoginHelper.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:fluttercrmmodule/widgets/sdesign_button.dart';
import 'SDAlert.dart';

class MyLogoutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Container(
        constraints: BoxConstraints.expand(height: 61, width: Tools.getScreenWidth(context)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
            child: SDFlatButton(
              color: Colors.white,
              onPressed: () {
                SDAlert.show(
                  context,
                  title: "退出登录",
                  desc: "您确定要退出登录？",
                  confirmCallBack: () {
                    LoginHelper.logout();
                  },
                );
              },
              child: Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      "退出登录",
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
