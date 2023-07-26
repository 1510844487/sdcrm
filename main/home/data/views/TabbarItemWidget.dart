import 'package:flutter/material.dart';

class TabbarItemWidget extends StatelessWidget {
  String? title;
  bool? isChoiced;
  VoidCallback? clickListener;
  Color? titleColorDef;
  Color? titleColorChoiced;
  double? titleSizeDef;
  double? titleSizeChoiced;
  EdgeInsetsGeometry? titlePadding;
  MainAxisAlignment? contentAlign;

  TabbarItemWidget(
      {this.title,
      this.isChoiced,
      this.clickListener,
      this.titleColorDef,
      this.titleColorChoiced,
      this.titleSizeDef,
      this.titleSizeChoiced,
      this.titlePadding,
      this.contentAlign}) {
    if (titlePadding == null) {
      titlePadding = EdgeInsets.only(top: 6, bottom: 6);
    }
    if (contentAlign == null) {
      contentAlign = MainAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickListener != null) {
          clickListener!();
        }
      },
      child: Container(
        child: Column(
          mainAxisAlignment: contentAlign!,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: titlePadding!,
              child: Text(
                title ?? "",
                style: TextStyle(
                  color: (isChoiced ?? false) ? (titleColorChoiced ?? Color(0xFF333333)) : (titleColorDef ?? Color(0xFFB1B1B1)),
                  fontSize: (isChoiced ?? false) ? (titleSizeChoiced ?? 16) : (titleSizeDef ?? 16),
                  fontWeight: (isChoiced ?? false) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: (isChoiced ?? false) ? Color(0xFF0071FE) : Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }
}
