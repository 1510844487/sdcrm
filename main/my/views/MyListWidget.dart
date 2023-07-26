import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/SDRouter.dart';
import 'package:fluttercrmmodule/pages/bean/CheckPerformanceBean.dart';
import 'package:fluttercrmmodule/pages/bean/CheckVersionBean.dart';
import 'package:fluttercrmmodule/pages/bean/MyInfoBean.dart';
import 'package:fluttercrmmodule/pages/common/AppVersionHelper.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/main/my/viewModel/MyViewModel.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';
import 'MyListItemWidget.dart';

class MyListWidget extends StatefulWidget {
  const MyListWidget({
    super.key,
    required this.myInfo,
    required this.showNewPage,
    required this.personInfo,
    required this.teamInfo,
    required this.versionBean,
    required this.myPageVisible,
    required this.myPerformanceVisible,
    required this.teamPerformanceVisible,
    required this.versionVisible,
    required this.version,
  });

  final MyInfoBean? myInfo;
  final bool showNewPage;
  final CheckPerformanceBean? personInfo;
  final CheckPerformanceBean? teamInfo;
  final String? version;
  final CheckVersionBean? versionBean;
  final bool myPageVisible;
  final bool myPerformanceVisible;
  final bool teamPerformanceVisible;
  final bool versionVisible;

  @override
  _MyListWidgetState createState() => _MyListWidgetState();
}

class _MyListWidgetState extends State<MyListWidget> {
  List<MyIconType> list = [];

  @override
  void initState() {
    super.initState();
    if (widget.myPageVisible) {
      list.add(MyIconType.myinfo);
    }
    if (widget.myPerformanceVisible) {
      list.add(MyIconType.performance);
    }
    if (widget.teamPerformanceVisible) {
      list.add(MyIconType.teamPerformance);
    }
    if (widget.versionVisible) {
      list.add(MyIconType.appversion);
    }
  }

  @override
  Widget build(BuildContext context) {
    var divider = Divider(
      indent: 16,
      endIndent: 16,
      height: 1.0,
      color: Color(0xFFEDEDED),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          color: Colors.white,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return divider;
            },
            padding: EdgeInsets.zero,
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _clickItem(index);
                },
                child: MyListItemWidget(
                  type: list[index],
                  version: widget.version,
                  versionBean: widget.versionBean,
                  personInfo: widget.personInfo,
                  teamInfo: widget.teamInfo,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _clickItem(int index) {
    if (index >= list.length) return;

    switch (list[index]) {
      case MyIconType.myinfo:
        reportCode(ElementCode.CODE_MY_PAGE);
        String pageName = widget.showNewPage ? SDRouter.pageCrmMineNew : SDRouter.pageCrmMine;
        Navigator.of(context).pushNamed(pageName);
        break;
      case MyIconType.teamPerformance:
        reportCode(ElementCode.CODE_TEAM_PERFORMANCE);
        String url = "https://www.shuidichou.com/bd/achievement/team";
        OpenNative.openWebView(url, "");
        break;
      case MyIconType.performance:
        reportCode(ElementCode.CODE_PERFORMANCE);
        MyViewModel.requestClickKPI();
        String url = "https://www.shuidichou.com/bd/achievement/mine";
        OpenNative.openWebView(url, "");
        break;
      case MyIconType.appversion:
        if (Platform.isAndroid) {
          AppVersionHelper.checkAppVersion(context, userTouchShow: true);
        }
        break;
    }
  }

  static Future<void> reportCode(String code) async {
    Map<String, String> reportParams = await Tools.buildCommonParams();
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, code, customParams: reportParams);
  }
}
