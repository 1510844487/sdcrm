import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/GlobalConst/SDString.dart';
import 'package:fluttercrmmodule/pages/common/NoSplashFactory.dart';

class SDCDetailDataFooterWidget extends StatelessWidget {
  final VoidCallback? onPressedBlock;

  SDCDetailDataFooterWidget({this.onPressedBlock});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      child: Center(
        child: TextButton(
          onPressed: () {
            if (onPressedBlock != null){
              onPressedBlock!();
            }
          },
          style: ButtonStyle(splashFactory: NoSplashFactory()),
          child: Container(
              alignment: Alignment.center,
              height: 24,
              width: 89,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: SDColor.gray,
              ),
              // minWidth: double.infinity,
              child: Text(SDString.unfold_more,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.normal,
                      color: SDColor.black))),
        ),
      ),
    );
  }
}
