import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/CurrentWeekObjective.dart';
import 'package:fluttercrmmodule/pages/bean/ObjectiveOrg.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/user/UserInfo.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

// 目标模块
class TargetWidget extends StatefulWidget {
  CurrentWeekObjective? targetInfo;
  final ValueChanged<String>? block;

  TargetWidget({this.targetInfo, this.block});

  @override
  State<StatefulWidget> createState() {
    return _TargetWidgetState();
  }
}

class _TargetWidgetState extends State<TargetWidget> {
  bool canShow = false;
  bool canShowDetail = false;

  List<ObjectiveOrg>? orgList;
  ObjectiveOrg? choicedOrg;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    SDUserHelper.getUserInfo().then((userInfo) async {
      canShow = userInfo?.roleCode != UserInfo.ROLE_PROVINCIAL_GR && userInfo?.roleCode != UserInfo.ROLE_NORMAL_GR;
      canShowDetail = canShow &&
          userInfo?.roleCode != SDUserInfo.ROLE_BD &&
          userInfo?.roleCode != SDUserInfo.ROLE_ASSISTANT &&
          userInfo?.roleCode != SDUserInfo.ROLE_AGENT_MEMBER &&
          userInfo?.roleCode != SDUserInfo.ROLE_PART_TIME;
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// 是否可以展示时间进度
  bool canShowObjectiveCycle() {
    if (widget.targetInfo == null) {
      return false;
    } else {
      return widget.targetInfo!.cfBdCrmObjectiveCycleVO != null;
    }
  }

  /// 是否可以展示目标项
  bool canShowObjectiveIndicatorModelList() {
    return widget.targetInfo != null && widget.targetInfo!.objectiveIndicatorModelList != null && widget.targetInfo!.objectiveIndicatorModelList!.length > 0;
  }

  double getTimeProgress() {
    if (widget.targetInfo == null) {
      return 0.0;
    }
    if (widget.targetInfo!.cfBdCrmObjectiveCycleVO == null) {
      return 0.0;
    }
    double val = widget.targetInfo!.cfBdCrmObjectiveCycleVO.dayIndex / widget.targetInfo!.cfBdCrmObjectiveCycleVO.totalDay;
    return val;
  }

  Widget getObjectWidget() {
    if (canShowObjectiveCycle()) {
      if (canShowObjectiveIndicatorModelList()) {
        return Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 0, crossAxisSpacing: 0, childAspectRatio: 178.5 / 158),
            itemBuilder: (context, position) {
              ObjectiveIndicatorModelList objIndicator = widget.targetInfo!.objectiveIndicatorModelList[position];
              double current = widget.targetInfo!.cfBdCrmObjectiveCycleVO.dayIndex.toDouble() / widget.targetInfo!.cfBdCrmObjectiveCycleVO.totalDay;

              double progress = 0.0;
              if (objIndicator.realValue == null || objIndicator.objectiveValue == null) {
                progress = 0.0;
              } else {
                progress = objIndicator.realValue.toDouble() / objIndicator.objectiveValue;
              }
              var pre = Tools.formatValue(objIndicator.realValue);
              var sen = Tools.formatValue(objIndicator.objectiveValue);
              bool isSame = progress >= current;
              return InkWell(
                onTap: () {
                  if (canShowDetail) {
                    openTargetDetail();
                  }
                },
                child: DataItemWidget(
                  title: "${objIndicator.name ?? ""}(${objIndicator.unitDesc ?? ""})",
                  desc: "${pre}/${sen}",
                  progress: progress,
                  progressColor: Color(isSame ? 0xFF0071FE : 0xFFFF6E11),
                  bgColor: Color(isSame ? 0xFF0071FE : 0xFFFF6E11).withOpacity(0.1),
                ),
              );
            },
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.targetInfo!.objectiveIndicatorModelList == null ? 0 : widget.targetInfo!.objectiveIndicatorModelList.length,
          ),
        );
      } else {
        return Container(
          padding: EdgeInsets.only(top: 30, bottom: 20),
          child: const Text(
            "本周期未设置目标项",
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 15,
            ),
          ),
        );
      }
    } else {
      return Container(
        padding: EdgeInsets.only(top: 30, bottom: 20),
        child: const Text(
          "目标周期未开始",
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 15,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return canShow && widget.targetInfo != null
        ? Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 8, top: 16),
                          child: const Text(
                            "本月目标",
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // TODO 展示时间进度
                      Container(
                        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                        height: 41,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2),
                                child: const Text(
                                  "时间进度",
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                "${(getTimeProgress() * 100).toStringAsFixed(0)}%",
                                style: TextStyle(color: Color(0xFF333333), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: CircularPercentIndicator(
                                radius: 10,
                                lineWidth: 3.0,
                                percent: getTimeProgress(),
                                center: Text(""),
                                progressColor: Color(0xFF0071FE),
                                backgroundColor: Color(0xFFEDEDED),
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                animationDuration: 1000,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Color(0xFFEDEDED),
                  height: 0.5,
                  margin: EdgeInsets.only(left: 16, right: 16),
                ),
                getObjectWidget(),
                canShowDetail
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              //  跳转目标详细
                              openTargetDetail();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text(
                                    "目标详情",
                                    style: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          )
        : Container();
  }

  Future<void> reportCode(String code) async {
    //埋点上报
    Map<String, String> reportParams = await Tools.buildCommonParams();
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, code, customParams: reportParams);
  }

  void openTargetDetail() {
    reportCode(ElementCode.CODE_HOME_TARGET_DETAIL);
    int? orgId;
    if (widget.targetInfo != null && widget.targetInfo!.orgId != null) {
      orgId = widget.targetInfo!.orgId;
    }
    int? objectiveCycleVoId;
    if (widget.targetInfo != null && widget.targetInfo!.cfBdCrmObjectiveCycleVO != null && widget.targetInfo!.cfBdCrmObjectiveCycleVO!.id != null) {
      objectiveCycleVoId = widget.targetInfo!.cfBdCrmObjectiveCycleVO!.id;
    }
    OpenNative.openWebView("https://www.shuidichou.com/bd/target/detail?orgId=${orgId ?? ""}&cycleId=${objectiveCycleVoId ?? ""}", "");
  }
}

class DataItemWidget extends StatelessWidget {
  String? title;
  String? desc;
  double? progress;
  Color? bgColor;
  Color? progressColor;
  bool? showDivider;

  DataItemWidget({this.title, this.desc, this.progress, this.bgColor, this.progressColor, this.showDivider = true});

  getProgress() {
    if (progress == null) {
      return 0.0;
    } else if (progress! > 1) {
      return 1.0;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 3.0,
                percent: getProgress(),
                center: Text(
                  "${((progress ?? 0) * 100).toInt()}%",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: progressColor ?? Color(0xFF0071FE),
                backgroundColor: bgColor ?? Color(0xFF0071FE).withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1000,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        title ?? "",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        desc ?? "",
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          showDivider ?? false
              ? Positioned(
                  top: 19,
                  bottom: 19,
                  right: 0,
                  child: Container(
                    width: 0.5,
                    decoration: BoxDecoration(
                      color: Color(0xFFEDEDED),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
