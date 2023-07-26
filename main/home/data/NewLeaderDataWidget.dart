import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/pages/bean/Statistics.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/main/home/data/viewModel/SDDataViewModel.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/DetailDataWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/GroupErrorWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/GroupItemWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDCDetailDataFooterWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDCDetailDataHeaderWidget.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';

import 'SDDataChartView.dart';

// 团队数据控件
class NewLeaderDataWidget extends StatefulWidget {
  Statistics? statistics;

  NewLeaderDataWidget({Statistics? statistics});

  @override
  State<StatefulWidget> createState() {
    return _NewLeaderDataWidgetState();
  }
}

class _NewLeaderDataWidgetState extends State<NewLeaderDataWidget> {
  final String data_day = Tools.DAY_0.toString();
  final String data_week = Tools.DAY_7.toString();
  final String data_month = Tools.DAY_30.toString();
  String? dayType;
  String? errorStatus;
  bool canShow = true;
  String? startTime, endTime;

  double? fontsize;

  bool isShowNewClewCount = false;

  bool isShowOfflineTotalCfCount = false;

  double contentMargin = 8;
  double contentPadding = 16;
  double betweenDistance = 16;

  bool isUnfold = false;

  @override
  void initState() {
    super.initState();
    errorStatus = GroupErrorWidget.status_loading;
    dayType = data_day;
    initNewLeaderData();
  }

  @override
  Widget build(BuildContext context) {
    int groupNum = widget.statistics?.cfCount ?? 0;
    List<CaseTrendList> groupCaseTrendList = widget.statistics?.caseTrendList ?? [];

    int donateTotalCount = widget.statistics?.donateTotalCount ?? 0;
    List<CaseTrendList> donateTrendList = widget.statistics?.donateTrendList ?? [];

    int newClewCount = widget.statistics?.newClewCount ?? 0;
    List<CaseTrendList> clewTrendList = widget.statistics?.clewTrendList ?? [];

    int offlineTotalCfCount = widget.statistics?.offlineTotalCfCount ?? 0;
    List<CaseTrendList> offlineCaseTrendList = widget.statistics?.offlineCaseTrendList ?? [];

    double screenW = ScreenUtil.getScreenW(context);
    double collectionWidth = 0.33 * (screenW - 2 * (contentMargin + contentPadding) - 2 * contentMargin) - 1;

    return canShow
        ? Container(
            margin: EdgeInsets.only(top: 8, left: contentMargin, right: contentMargin),
            padding: EdgeInsets.only(left: contentPadding, right: contentPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: const Text(
                        "今日团队数据",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return SimpleDialog(
                                title: Text(""),
                                titlePadding: EdgeInsets.all(10),
                                backgroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                children: <Widget>[
                                  ListTile(
                                    title: Center(
                                      child: Text(
                                        "请填写完整信息！请填写完整信息！请填写完整信息！请填写完整信息！请填写完整信息！请填写完整信息！请填写完整信息！请填写完整信息！",
                                        style: TextStyle(color: Colors.black, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  ListTile(
                                    title: Center(
                                        child: Container(
                                      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                                      width: 100,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: Colors.red),
                                      child: Text(
                                        "知道了",
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                    )),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: SDTipsWidget(
                        title: '对比数据更新于08:00',
                      ),
                    ))
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 0.5,
                  color: Color(0xFFEDEDED),
                ),
                SizedBox(height: 13),
                dataWrap(collectionWidth, donateTotalCount, donateTrendList, groupNum, groupCaseTrendList, newClewCount, clewTrendList, offlineTotalCfCount,
                    offlineCaseTrendList),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  height: 1,
                  color: SDColor.gray1,
                ),
                SDCDetailDataHeaderWidget(),
                DetailDataWidget(isUnfold: isUnfold),
                isUnfold
                    ? Container()
                    : SDCDetailDataFooterWidget(onPressedBlock: () {
                        setState(() {
                          isUnfold = !isUnfold;
                        });
                      })
              ],
            ),
          )
        : Container();
  }

  /// 生成团队数据汇总控件
  buildOrgDataSummary() {}

  Wrap dataWrap(double collectionWidth, int donateTotalCount, List<CaseTrendList> donateTrendList, int groupNum, List<CaseTrendList> groupCaseTrendList,
      int newClewCount, List<CaseTrendList> clewTrendList, int offlineTotalCfCount, List<CaseTrendList> offlineCaseTrendList) {
    return Wrap(
      spacing: contentMargin,
      runSpacing: contentMargin,
      direction: Axis.horizontal,
      children: <Widget>[
        Container(
          width: collectionWidth,
          height: 80,
          child: GroupItemWidget(
            title: "团队捐单",
            number: Tools.formatHomeData(donateTotalCount),
            lineColor: Color(0xFF0071FE),
            caseTrendList: donateTrendList,
            fontSize: fontsize,
            isUp: true,
            isHotCake: false,
            clickCallback: () {
              SDDataViewModel.clickDonate(widget.statistics, dayType, startTime, endTime);
            },
          ),
        ),
        Container(
          width: collectionWidth,
          height: 80,
          child: GroupItemWidget(
            title: "团队发起",
            number: Tools.formatHomeData(groupNum),
            lineColor: Color(0xFF0071FE),
            caseTrendList: groupCaseTrendList,
            fontSize: fontsize,
            isUp: true,
            isHotCake: false,
            clickCallback: () {
              // 点击团队发起
              SDDataViewModel.clickCf(widget.statistics, dayType, dayType);
            },
          ),
        ),
        Container(
          width: collectionWidth,
          height: 80,
          child: GroupItemWidget(
            title: "团队有效发起",
            number: Tools.formatHomeData(groupNum),
            lineColor: Color(0xFF0071FE),
            caseTrendList: groupCaseTrendList,
            fontSize: fontsize,
            isUp: true,
            isHotCake: false,
            clickCallback: () {
              // 点击团队发起
              SDDataViewModel.clickCf(widget.statistics, dayType, dayType);
            },
          ),
        ),
        Container(
          width: collectionWidth,
          height: 80,
          child: GroupItemWidget(
            title: "爆款潜力",
            number: Tools.formatHomeData(groupNum),
            lineColor: Color(0xFF0071FE),
            caseTrendList: groupCaseTrendList,
            fontSize: fontsize,
            isUp: false,
            isHotCake: true,
            clickCallback: () {
              // 点击团队发起
              SDDataViewModel.clickCf(widget.statistics, dayType, dayType);
            },
          ),
        ),
        isShowNewClewCount
            ? Container(
                width: collectionWidth,
                height: 80,
                child: GroupItemWidget(
                  title: "团队线索",
                  title2: "",
                  number: Tools.formatHomeData(newClewCount),
                  lineColor: Color(0xFF0071FE),
                  caseTrendList: clewTrendList,
                  fontSize: fontsize,
                  isUp: false,
                  isHotCake: false,
                  clickCallback: () {
                    SDDataViewModel.clickTeamNewClew(dayType);
                  },
                ),
              )
            : Container(),
        isShowOfflineTotalCfCount
            ? Container(
//                        color: Colors.blue,
                width: collectionWidth,
                height: 80,
                child: GroupItemWidget(
                  title: "线下总发起",
                  title2: "",
                  number: Tools.formatHomeData(offlineTotalCfCount),
                  lineColor: Color(0xFF0071FE),
                  caseTrendList: offlineCaseTrendList,
                  fontSize: fontsize,
                  clickCallback: () {
                    SDDataViewModel.clickOfflineTotalRaise(dayType, startTime, endTime);
                  },
                ),
              )
            : Container(),
      ],
    );
  }

  initNewLeaderData() async {
    SDUserHelper.getUserInfo().then((userInfo) async {
      isShowNewClewCount = userInfo?.roleCode == SDUserInfo.ROLE_SUPER ||
          userInfo?.roleCode == SDUserInfo.ROLE_BUSINESS ||
          userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_ZONE_MANAGER ||
          userInfo?.roleCode == SDUserInfo.ROLE_PROVINCES ||
          userInfo?.roleCode == SDUserInfo.ROLE_ADVANCED_CHANNEL ||
          userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION ||
          userInfo?.roleCode == SDUserInfo.ROLE_OPERATION;

      isShowOfflineTotalCfCount = userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION ||
          userInfo?.roleCode == SDUserInfo.ROLE_SUPER;

      if ((userInfo?.roleCode == SDUserInfo.ROLE_SUPER) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_OPERATION)) {
        fontsize = 15;
      } else {
        fontsize = 20;
      }

      if (userInfo?.roleCode == SDUserInfo.ROLE_BUSINESS ||
          userInfo?.roleCode == SDUserInfo.ROLE_ZONE_MANAGER ||
          userInfo?.roleCode == SDUserInfo.ROLE_PROVINCES ||
          userInfo?.roleCode == SDUserInfo.ROLE_ADVANCED_CHANNEL ||
          userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
          userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION ||
          userInfo?.roleCode == SDUserInfo.ROLE_SUPER ||
          userInfo?.roleCode == SDUserInfo.ROLE_OPERATION) {
        canShow = true;
        endTime = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd, ""]);
        if (dayType == data_day) {
          startTime = endTime;
        } else if (dayType == data_week) {
          startTime = formatDate(DateTime.fromMicrosecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch * 1000), [yyyy, "-", mm, "-", dd, ""]);
          startTime = formatDate(
              DateTime.fromMicrosecondsSinceEpoch((DateTime.now().millisecondsSinceEpoch - 6 * 24 * 60 * 60 * 1000) * 1000), [yyyy, "-", mm, "-", dd, ""]);
        } else if (dayType == data_month) {
          startTime = formatDate(
              DateTime.fromMicrosecondsSinceEpoch((DateTime.now().millisecondsSinceEpoch - 29 * 24 * 60 * 60 * 1000) * 1000), [yyyy, "-", mm, "-", dd, ""]);
        } else {
          startTime = endTime;
        }

        setState(() {});
      } else {}
    });
  }
}
