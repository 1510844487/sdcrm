import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/main/my/views/SDAlert.dart';
import 'package:fluttercrmmodule/utils/LoginHelper.dart';
import 'package:sd_flutter_base/module/user/UserHelper.dart';
import 'package:sd_flutter_base/module/user/UserInfo.dart';
import 'package:sd_flutter_storage/SDStorage.dart';

class MyCloseAccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        constraints: BoxConstraints.expand(height: 61),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Container(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              SDAlert.show(
                context,
                title: "是否确认注销账户",
                desc: "注销账户后，您的账户信息无法找回。",
                confirmCallBack: () async {
                  UserInfo? userInfo = await UserHelper.getUserInfo();
                  List<String> touristList = await SDStorage.instance().getList("touristList");
                  List<String> target = [];
                  if (touristList.isNotEmpty) {
                    touristList.map((e) {
                      if (!e.contains(userInfo == null ? "" : (userInfo.phone ?? ""))) {
                        target.add(e);
                      }
                    });
                  }
                  SDStorage.instance().setList("touristList", target);
                  LoginHelper.logout();
                },
                cancelCallBack: () {},
              );
            },
            child: Text(
              "注销账户",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
