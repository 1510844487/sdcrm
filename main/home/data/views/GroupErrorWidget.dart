import 'package:flutter/material.dart';

class GroupErrorWidget extends StatelessWidget {
  static final String status_loading = "loading";
  static final String status_error = "error";
  String? status = status_loading;
  VoidCallback? clickCallback;

  GroupErrorWidget({this.status, this.clickCallback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickCallback != null) {
          clickCallback!();
        }
      },
      child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              Visibility(
                visible: status == status_error,
                child: const Text(
                  "请求失败，点击重试",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ),
              Visibility(
                visible: status == status_loading,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
                ),
              ),
            ],
          )),
    );
  }
}
