import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabItemWidget extends StatefulWidget {
  String? title;
  String? iconDefault;
  String? iconChoiced;
  Color? titleDefaultColor;
  Color? titleChoiceColor;
  bool? isChoice;
  VoidCallback? clickCallback;

  TabItemWidget(
      {this.title,
      this.iconDefault,
      this.iconChoiced,
      this.titleDefaultColor = Colors.black,
      this.titleChoiceColor = Colors.deepOrange,
      this.isChoice = false,
      this.clickCallback});

  @override
  State<StatefulWidget> createState() {
    return _TabItemWidgetState();
  }
}

class _TabItemWidgetState extends State<TabItemWidget> {
  Color? getTitleColor() {
    return (widget.isChoice ?? false) ? widget.titleChoiceColor : widget.titleDefaultColor;
  }

  getIcon() {
    return (widget.isChoice ?? false) ? widget.iconChoiced : widget.iconDefault;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.clickCallback != null) {
          widget.clickCallback!();
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Image.asset(
              getIcon(),
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                widget.title ?? "",
                style: TextStyle(
                  color: getTitleColor(),
                  fontSize: 11,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
