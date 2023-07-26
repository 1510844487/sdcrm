import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/widgets/sdesign_button.dart';

class SDAlert {
  static show(
    BuildContext context, {
    required String title,
    required String desc,
    required void Function() confirmCallBack,
    void Function()? cancelCallBack,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          backgroundColor: Colors.white,
          child: Container(
            height: 180,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 28),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 12, left: 20, right: 20),
                  alignment: Alignment.center,
                  child: Text(
                    desc,
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: SDFlatButton(
                          color: Color(0xFFF1F1F1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          onPressed: () {
                            if (cancelCallBack != null) {
                              cancelCallBack();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints.expand(),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF848484),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 16,
                      ),
                      Expanded(
                        flex: 1,
                        child: SDFlatButton(
                          color: Color(0xFF0056FE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          onPressed: () {
                            Navigator.of(context).pop();
                            confirmCallBack();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints.expand(),
                            child: Text(
                              "确定",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
