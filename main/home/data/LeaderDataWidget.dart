import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/Statistics.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/UrlConstant.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/main/home/RefreshListener.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/TrendChartWidget.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/user/UserHelper.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

import '../HomeBaseState.dart';

// 管理角色数据控件
class LeaderDataWidget extends StatefulWidget {
  RefreshListener? refreshListener;
  Function? loadingCallback;

  LeaderDataWidget({this.refreshListener, this.loadingCallback});

  @override
  State<StatefulWidget> createState() {
    return _LeaderDataWidgetState(refreshListener);
  }
}

class _LeaderDataWidgetState extends HomeBaseState<LeaderDataWidget> {
  final String data_day = Tools.DAY_0.toString();
  final String data_week = Tools.DAY_7.toString();
  final String data_month = Tools.DAY_30.toString();
  String? dayType;
  Statistics? statistics;
  String? errorStatus;
  bool canShow = false;
  String? startTime, endTime;

  double? _fontsize;

  bool isShowNewClewCount = false;

  bool isShowOfflineTotalCfCount = false;

  _LeaderDataWidgetState(RefreshListener? refreshListener) : super(refreshListener);

  @override
  void initState() {
    super.initState();
    errorStatus = ErrorWidget.status_loading;
    dayType = data_day;
  }

  @override
  getData() async {
    UserHelper.getUserInfo().then((userInfo) async {
      isShowNewClewCount = userInfo != null &&
          (userInfo.roleCode == SDUserInfo.ROLE_SUPER ||
              userInfo.roleCode == SDUserInfo.ROLE_BUSINESS ||
              userInfo.roleCode == SDUserInfo.ROLE_CHANNEL ||
              userInfo.roleCode == SDUserInfo.ROLE_AGENT_LEADER ||
              userInfo.roleCode == SDUserInfo.ROLE_AGENT_BOOS ||
              userInfo.roleCode == SDUserInfo.ROLE_REGIONAL ||
              userInfo.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
              userInfo.roleCode == SDUserInfo.ROLE_ZONE_MANAGER ||
              userInfo.roleCode == SDUserInfo.ROLE_PROVINCES ||
              userInfo.roleCode == SDUserInfo.ROLE_ADVANCED_CHANNEL ||
              userInfo.roleCode == SDUserInfo.ROLE_BIG_REGION ||
              userInfo.roleCode == SDUserInfo.ROLE_OPERATION);

      isShowOfflineTotalCfCount = userInfo != null &&
          (userInfo.roleCode == SDUserInfo.ROLE_REGIONAL || userInfo.roleCode == SDUserInfo.ROLE_BIG_REGION || userInfo.roleCode == SDUserInfo.ROLE_SUPER);

      if ((userInfo?.roleCode == SDUserInfo.ROLE_SUPER) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL) ||
          (userInfo?.roleCode == SDUserInfo.ROLE_OPERATION)) {
        _fontsize = 15;
      } else {
        _fontsize = 20;
      }

      if (userInfo != null &&
          (userInfo.roleCode == SDUserInfo.ROLE_BUSINESS ||
              userInfo.roleCode == SDUserInfo.ROLE_CHANNEL ||
              userInfo.roleCode == SDUserInfo.ROLE_AGENT_LEADER ||
              userInfo.roleCode == SDUserInfo.ROLE_AGENT_BOOS ||
              userInfo.roleCode == SDUserInfo.ROLE_ZONE_MANAGER ||
              userInfo.roleCode == SDUserInfo.ROLE_PROVINCES ||
              userInfo.roleCode == SDUserInfo.ROLE_ADVANCED_CHANNEL ||
              userInfo.roleCode == SDUserInfo.ROLE_REGIONAL ||
              userInfo.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
              userInfo.roleCode == SDUserInfo.ROLE_BIG_REGION ||
              userInfo.roleCode == SDUserInfo.ROLE_SUPER ||
              userInfo.roleCode == SDUserInfo.ROLE_OPERATION)) {
        canShow = true;
        endTime = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd, ""]);
        int trendType = 0;
        if (dayType == data_day) {
          startTime = endTime;
          trendType = 0;
        } else if (dayType == data_week) {
          startTime = formatDate(DateTime.fromMicrosecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch * 1000), [yyyy, "-", mm, "-", dd, ""]);
          startTime = formatDate(
              DateTime.fromMicrosecondsSinceEpoch((DateTime.now().millisecondsSinceEpoch - 6 * 24 * 60 * 60 * 1000) * 1000), [yyyy, "-", mm, "-", dd, ""]);
          trendType = 0;
        } else if (dayType == data_month) {
          startTime = formatDate(
              DateTime.fromMicrosecondsSinceEpoch((DateTime.now().millisecondsSinceEpoch - 29 * 24 * 60 * 60 * 1000) * 1000), [yyyy, "-", mm, "-", dd, ""]);
          trendType = 1;
        } else {
          startTime = endTime;
          trendType = 0;
        }

        SDResponse<Statistics> response = await NetImp.getLeaderStatistics(startTime, endTime, trendType);
        if (response.isSuccess()) {
          if (widget.loadingCallback != null) {
            widget.loadingCallback!(false);
          }
          setState(() {
            statistics = response.module;
          });
          refreshComplete(true);
        } else {
          errorStatus = ErrorWidget.status_error;
          statistics = null;
          refreshComplete(false);
        }
      } else {
        if (widget.loadingCallback != null) {
          widget.loadingCallback!(false);
        }
        refreshComplete(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int groupNum = statistics?.cfCount ?? 0;
    List<CaseTrendList> groupCaseTrendList = statistics?.caseTrendList ?? [];

    int donateTotalCount = statistics?.donateTotalCount ?? 0;
    List<CaseTrendList> donateTrendList = statistics?.donateTrendList ?? [];

    int newClewCount = statistics?.newClewCount ?? 0;
    List<CaseTrendList> clewTrendList = statistics?.clewTrendList ?? [];

    int offlineTotalCfCount = statistics?.offlineTotalCfCount ?? 0;
    List<CaseTrendList> offlineCaseTrendList = statistics?.offlineCaseTrendList ?? [];

    double contentMargin = 8;
    double contentPadding = 16;
    double betweenDistance = 16;

    double screenW = ScreenUtil.getScreenW(context);
    double collectionWidth = 0.5 * (screenW - 2 * contentMargin - 2 * contentPadding) - 1;

    return canShow
        ? Container(
            margin: EdgeInsets.only(top: 8, left: contentMargin, right: contentMargin),
            padding: EdgeInsets.only(left: contentPadding, right: contentPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white,
            ),
            height: (isShowNewClewCount || isShowOfflineTotalCfCount) ? 214 : 126,
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "主要数据",
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TabbarItemWidget(
                      title: "今日",
                      isChoiced: dayType == data_day,
                      titleSizeDef: 13,
                      titleSizeChoiced: 13,
                      clickListener: () {
                        setState(() {
                          dayType = data_day;
                          errorStatus = ErrorWidget.status_loading;
                        });
                        if (widget.loadingCallback != null) {
                          widget.loadingCallback!(true);
                        }
                        getData();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: TabbarItemWidget(
                        title: "7日",
                        titleSizeDef: 13,
                        titleSizeChoiced: 13,
                        isChoiced: dayType == data_week,
                        clickListener: () {
                          setState(() {
                            // LoadState.loading = true;
                            dayType = data_week;
                            errorStatus = ErrorWidget.status_loading;
                          });
                          if (widget.loadingCallback != null) {
                            widget.loadingCallback!(true);
                          }
                          getData();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: TabbarItemWidget(
                        title: "30日",
                        titleSizeDef: 13,
                        titleSizeChoiced: 13,
                        isChoiced: dayType == data_month,
                        clickListener: () {
                          setState(() {
                            dayType = data_month;
                            errorStatus = ErrorWidget.status_loading;
                          });
                          if (widget.loadingCallback != null) {
                            widget.loadingCallback!(true);
                          }
                          getData();
                        },
                      ),
                    )
                  ],
                ),
                Container(
                  height: 0.5,
                  color: Color(0xFFEDEDED),
                ),
                Expanded(
                  child: Wrap(
                    children: <Widget>[
                      Container(
                        width: collectionWidth,
                        height: 80,
                        child: Padding(
                          padding: EdgeInsets.only(right: betweenDistance),
                          child: DataItemWidget(
                            title: "团队发起",
                            number: Tools.formatHomeData(groupNum),
                            lineColor: Color(0xFF0071FE),
                            caseTrendList: groupCaseTrendList,
                            fontSize: _fontsize ?? 15,
                            clickCallback: () {
                              // 点击团队发起
                              clickCf(statistics, dayType);
                            },
                          ),
                        ),
                      ),
                      Container(
//                        color: Colors.blue,
                        width: collectionWidth,
                        height: 80,
                        child: Padding(
                          padding: EdgeInsets.only(left: betweenDistance),
                          child: DataItemWidget(
                            title: "团队捐单",
                            number: Tools.formatHomeData(donateTotalCount),
                            lineColor: Color(0xFF0071FE),
                            caseTrendList: donateTrendList,
                            fontSize: _fontsize ?? 15,
                            clickCallback: () {
                              clickDonate(statistics, dayType);
                            },
                          ),
                        ),
                      ),
                      isShowNewClewCount
                          ? Container(
//                        color: Colors.red,
                              width: collectionWidth,
                              height: 80,
                              child: Padding(
                                padding: EdgeInsets.only(right: betweenDistance),
                                child: DataItemWidget(
                                  title: "团队线索",
                                  title2: "",
                                  number: Tools.formatHomeData(newClewCount),
                                  lineColor: Color(0xFF0071FE),
                                  caseTrendList: clewTrendList,
                                  fontSize: _fontsize ?? 15,
                                  clickCallback: () {
                                    clickTeamNewClew(dayType);
                                  },
                                ),
                              ),
                            )
                          : Container(),
                      isShowOfflineTotalCfCount
                          ? Container(
//                        color: Colors.blue,
                              width: collectionWidth,
                              height: 80,
                              child: Padding(
                                padding: EdgeInsets.only(left: betweenDistance),
                                child: DataItemWidget(
                                  title: "线下总发起",
                                  title2: "",
                                  number: Tools.formatHomeData(offlineTotalCfCount),
                                  lineColor: Color(0xFF0071FE),
                                  caseTrendList: offlineCaseTrendList,
                                  fontSize: _fontsize ?? 15,
                                  clickCallback: () {
                                    clickOfflineTotalRaise(dayType);
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  fetchFontSize() {
    return 20; //: 15
  }

  /// 点击发起
  clickCf(Statistics? statistics, String? dataType) {
    UserHelper.getUserInfo().then((userinfo) {
      String url = UrlConstant.URL_STATISTICS_PROVINCIAL_CASES;

      OpenNative.openWebView(url + "?timeType=${dayType}", "");
      Map<String, String> reportParams = Map();
      reportParams["home_time_dimension"] = configDataType2Code(dataType);
      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_GROUP_FAQI, customParams: reportParams);
    });
  }

  /// 点击捐单
  clickDonate(Statistics? statistics, String? dataType) {
    UserHelper.getUserInfo().then((userinfo) {
      String url = UrlConstant.URL_STATISTICS_REGIONAL_DONATE;
      switch (userinfo?.roleCode) {
        case SDUserInfo.ROLE_OPERATION:
          url = UrlConstant.URL_STATISTICS_OPERATION_DONATE;
          break;
          break;
        case SDUserInfo.ROLE_ZONE_MANAGER:
        case SDUserInfo.ROLE_PROVINCES:
        case SDUserInfo.ROLE_ADVANCED_CHANNEL:
          url = UrlConstant.URL_STATISTICS_ZONE_MANAGER_DONATE;
          break;
        case SDUserInfo.ROLE_REGIONAL:
        case SDUserInfo.ROLE_CHANNEL_REGIONAL:
          url = UrlConstant.URL_STATISTICS_REGIONAL_DONATE;
          break;
        case SDUserInfo.ROLE_BIG_REGION:
          url = UrlConstant.URL_STATISTICS_BIG_REGION_DONATE;
          break;
        case SDUserInfo.ROLE_SUPER:
          url = UrlConstant.URL_STATISTICS_SUPER_DONATE;
          break;
      }
      OpenNative.openWebView("${url}?startTime=${startTime}&endTime=${endTime}", "");

      Map<String, String> reportParams = Map();
      reportParams["home_time_dimension"] = configDataType2Code(dataType);
      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_GROUP_JD, customParams: reportParams);
    });
  }

  configDataType2Code(String? dataType) {
    if (dataType == null) {
      return "0";
    }

    switch (dataType) {
      case "1":
        return "0";
        break;
      case "7":
        return "1";
        break;
      case "30":
        return "2";
        break;
      default:
        return "0";
    }
  }

  /// 点击团队新增线索
  clickTeamNewClew(String? dataType) {
    String url = UrlConstant.URL_STATISTICS_TEAM_CLEW;
    OpenNative.openWebView(url + "?timeType=" + (dataType ?? ''), "");

    Map<String, String> reportParams = Map();
    reportParams["home_time_dimension"] = configDataType2Code(dataType);
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_NEW_CLEW, customParams: reportParams);
  }

  /// 点击线下总发起数、捐单数
  clickOfflineTotalRaise(String? dataType) {
    String url = UrlConstant.URL_STATISTICS_OFFLINE_TOTAL_RAISE;
    OpenNative.openWebView(url + "?startTime=${startTime}&endTime=${endTime}", "");

    // Navigator.of(context).pushNamed(SDRouter.pageRaiseTotal,
    //     arguments: {"startTime": startTime, "endTime": endTime});

    Map<String, String> reportParams = Map();
    reportParams["home_time_dimension"] = configDataType2Code(dataType);
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_OFFLINE_TOTAL_RAISE, customParams: reportParams);
  }
}

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

class DataItemWidget extends StatelessWidget {
  String? number;
  String? title;
  String? title2;
  List<CaseTrendList>? caseTrendList;
  Color? lineColor;
  VoidCallback? clickCallback;
  double? fontSize;
  double? textFontSize;

  DataItemWidget({this.number, this.title, this.title2, this.clickCallback, this.caseTrendList, this.lineColor, this.fontSize, this.textFontSize});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickCallback != null) {
          clickCallback!();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  number ?? "",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: fontSize ?? 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    title ?? "",
                    style: TextStyle(color: Color(0xFF999999), fontSize: textFontSize ?? 13),
                  ),
                ),
                // title2 == null
                //     ? Container()
                //     : Text(
                //         title2 ?? "",
                //         style: TextStyle(
                //             color: Color(0xFF999999),
                //             fontSize: textFontSize ?? 13),
                //       ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: TrendChartWidget(
              caseTrendList: caseTrendList,
              paintColor: lineColor,
            ),
          )
        ],
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  static final String status_loading = "loading";
  static final String status_error = "error";
  String? status = status_loading;
  VoidCallback? clickCallback;

  ErrorWidget({this.status, this.clickCallback});

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
