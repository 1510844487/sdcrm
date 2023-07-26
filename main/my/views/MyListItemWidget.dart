import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/CheckPerformanceBean.dart';
import 'package:fluttercrmmodule/pages/bean/CheckVersionBean.dart';
import 'package:fluttercrmmodule/pages/main/my/viewModel/MyViewModel.dart';

class MyListItemWidget extends StatelessWidget {
  const MyListItemWidget({
    super.key,
    required this.type,
    required this.version,
    required this.versionBean,
    required this.personInfo,
    required this.teamInfo,
  });

  final MyIconType type;
  final String? version;
  final CheckVersionBean? versionBean;
  final CheckPerformanceBean? personInfo;
  final CheckPerformanceBean? teamInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 64,
      child: configRowItem(type),
    );
  }

  Widget configRowItem(MyIconType type) {
    switch (type) {
      case MyIconType.appversion:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Image(
              image: AssetImage(MyViewModel.getIconImage(type)),
              width: 20,
              height: 20,
            ),
            SizedBox(width: 16.0),
            Text(
              MyViewModel.getNameItem(type),
              style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
            Expanded(
              child: Text(
                "V" + (version ?? ""),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ),
            SizedBox(width: 8.0),
            _versionRedPoint(),
            SizedBox(width: 3.0),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Image(
                image: AssetImage("images/my_gray_arrow.png"),
                width: 12,
                height: 12,
              ),
            ),
          ],
        );
      case MyIconType.myinfo:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Image(
              image: AssetImage(MyViewModel.getIconImage(type)),
              width: 20,
              height: 20,
            ),
            SizedBox(width: 16.0),
            Text(
              MyViewModel.getNameItem(type),
              style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
            Expanded(child: Container()),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image(
                  image: AssetImage("images/my_gray_arrow.png"),
                  width: 12,
                  height: 12,
                ),
              ),
            )
          ],
        );
      case MyIconType.performance:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Image(
              image: AssetImage(MyViewModel.getIconImage(type)),
              width: 20,
              height: 20,
            ),
            SizedBox(width: 16.0),
            Text(
              MyViewModel.getNameItem(type),
              style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
            SizedBox(width: 16.0),
            Expanded(child: buildPersonInfoContent()),
            SizedBox(width: 8.0),
            buildPersonInfoFlag(),
            SizedBox(width: 3.0),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Image(
                image: AssetImage("images/my_gray_arrow.png"),
                width: 12,
                height: 12,
              ),
            ),
          ],
        );
      case MyIconType.teamPerformance:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Image(
              image: AssetImage(MyViewModel.getIconImage(type)),
              width: 20,
              height: 20,
            ),
            SizedBox(width: 16.0),
            Text(
              MyViewModel.getNameItem(type),
              style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
            SizedBox(width: 16.0),
            Expanded(child: buildTeamInfoContent()),
            SizedBox(width: 8.0),
            buildTeamInfoFlag(),
            SizedBox(width: 3.0),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Image(
                image: AssetImage("images/my_gray_arrow.png"),
                width: 12,
                height: 12,
              ),
            )
          ],
        );
      default:
        return Row(children: <Widget>[Container()]);
    }
  }

  Widget buildPersonInfoContent() {
    String? content = personInfo?.content;
    if (content != null && content.isNotEmpty) {
      return Text(
        content,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildPersonInfoFlag() {
    if (personInfo?.flag == true) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: new Container(
          width: 8,
          height: 8,
          color: Colors.red,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildTeamInfoContent() {
    String? content = teamInfo?.content;
    if (content != null && content.isNotEmpty) {
      return Text(
        content,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildTeamInfoFlag() {
    if (teamInfo?.flag == true) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: new Container(
          width: 8,
          height: 8,
          color: Colors.red,
        ),
      );
    } else {
      return Container();
    }
  }

  _versionRedPoint() {
    if (versionBean == null) {
      return Container();
    }

    bool? latest = versionBean?.latest;
    if (latest != null) {
      if (!latest) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: new Container(
            width: 8,
            height: 8,
            color: Colors.red,
          ),
        );
      }
    }

    return Container();
  }
}
