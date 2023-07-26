import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/Statistics.dart';

class GroupItemWidget extends StatelessWidget {
  String? number;
  String? title;
  String? title2;
  List<CaseTrendList>? caseTrendList;
  Color? lineColor;
  VoidCallback? clickCallback;
  double? fontSize;
  double? textFontSize;
  bool? isUp = false;
  bool? isHotCake = false;

  GroupItemWidget(
      {this.number,
      this.title,
      this.title2,
      this.clickCallback,
      this.caseTrendList,
      this.lineColor,
      this.fontSize,
      this.textFontSize,
      this.isUp,
      this.isHotCake});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickCallback != null) {
          clickCallback!();
        }
      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (isUp ?? false) ? Color(0xFFF9EAEB) : Color(0xFFE9F4F1),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                (isHotCake ?? false)
                    ? Container(
                        child: Image.asset("images/home_data_fire.png",
                            width: 10, height: 12))
                    : Container(), //
                Container(
                  child: Text(
                    title ?? "",
                    style: TextStyle(color: Color(0xFF333333), fontSize: 12),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 6),
              child: Text(number ?? "",
                  style: TextStyle(
                    color: (isUp ?? false) ? Color(0xFFD33F42) : Color(0xFF459678),
                    fontSize: fontSize ?? 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Container(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "-20(-4%)",
                style: TextStyle(
                  color: (isUp ?? false) ? Color(0xFFD33F42) : Color(0xFF459678),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
