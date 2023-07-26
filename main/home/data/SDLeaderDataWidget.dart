import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercrmmodule/dialog/HomePageDialogHelper.dart';
import 'package:fluttercrmmodule/pages/bean/AppViewModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignMemberDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignOrgDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/TodayBdStaticsData.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/HomeConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/home/data/SDDataChartView.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

/// 首页 团队数据部分 控件
class SDLeaderDataWidget extends StatefulWidget {
  TodayBdStaticsData? todayBdStaticsData;
  List<CampaignMemberDetailModel>? memberDetailList;
  List<CampaignOrgDetailModel>? orgDetailList;

  SDLeaderDataWidget(this.todayBdStaticsData, this.memberDetailList, this.orgDetailList);

  @override
  State<StatefulWidget> createState() {
    return SDLeaderDataWidgetState();
  }
}

class SDLeaderDataWidgetState extends State<SDLeaderDataWidget> {
  SDUserInfo? userInfo;

  bool canShow() {
    return hasBDStaticsData() || hasOrgData();
  }

  /// 统计主数据不为空
  bool hasBDStaticsData() {
    return widget.todayBdStaticsData != null;
  }

  // 统计组织数据不为空
  bool hasOrgData() {
    return (widget.memberDetailList != null && widget.memberDetailList!.length > 0) || (widget.orgDetailList != null && widget.orgDetailList!.length > 0);
  }

  @override
  Widget build(BuildContext context) {
    return canShow()
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "今日团队数据",
                        style: TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                          child: SDTipsWidget(
                        title: "对比数据更新于${widget.todayBdStaticsData?.dataUpdateTime}",
                        clickListener: () {
                          // 展示弹框
                          HomePageDialogHelper.showDataTipsDialog(
                              context,
                              "数据说明",
                              [
                                DialogLable("团队捐单", "今天截止现在的捐单量。"),
                                DialogLable("团队发起", "通过预审的案例量。"),
                                DialogLable("团队有效", "今天筹款金额达到2000的案例量。"),
                              ],
                              "默认对比近8周同时段均值，也可在「数据配置」中设置为对比近8周同时段峰值。对比值每小时整点更新。\n举例：如周一早9:30，对比前8周的周一9:00的均值或峰值。");
                        },
                      ))
                    ],
                  ),
                ),
                Container(
                  color: Color(0xFFEDEDED),
                  height: 0.5,
                  margin: EdgeInsets.only(left: 12, right: 12),
                ),
                SDLeaderDataSummaryWidget(widget.todayBdStaticsData, userInfo),
                hasBDStaticsData()
                    ? Container(
                        color: Color(0xFFEDEDED),
                        height: 0.5,
                        margin: EdgeInsets.only(top: 16),
                      )
                    : Container(),
                hasOrgData() ? SDLeaderDataOrgWidget(widget.memberDetailList, widget.orgDetailList, userInfo) : Container(),
              ],
            ),
          )
        : Container();
  }

  @override
  void initState() {
    SDUserHelper.getUserInfo().then((value) {
      if (mounted) {
        setState(() {
          userInfo = value;
        });
      }
    });
  }
}

/// 团队数据  汇总区域控件
class SDLeaderDataSummaryWidget extends StatelessWidget {
  TodayBdStaticsData? todayBdStaticsData;
  SDUserInfo? sdUserInfo;
  List<_LeaderData> data = [];

  SDLeaderDataSummaryWidget(this.todayBdStaticsData, this.sdUserInfo) {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_TDJD);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_JD, "团队捐单", url: "https://www.shuidichou.com/bd/battle-map/overview?selectType=orgData"));
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_TDCKJE);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_CKJE, "团队筹款金额(万元)", url: "https://www.shuidichou.com/bd/battle-map/overview?selectType=orgData"));
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_TDFQ);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_FQ, "团队发起", url: "https://www.shuidichou.com/bd/manage-tree/case?timeType=1&numType=1"));
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_TDYXFQ);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_YXFQ, "团队有效发起", url: "https://www.shuidichou.com/bd/manage-tree/case?timeType=1&numType=1"));
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_TDXS);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_XS, "团队线索", url: "https://www.shuidichou.com/bd/manage-tree/clew"));
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_XXZFQ);
    if (appViewModel != null && appViewModel.visible) {
      if (todayBdStaticsData != null && todayBdStaticsData!.offlineTotalShow == 1) {
        data.add(
            new _LeaderData(_LeaderData.TYPE_ZFQ, todayBdStaticsData!.offlineTotalRole ?? "线下总发起", url: "https://www.shuidichou.com/bd/donation-data/list?"));
      }
    }
    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_FWFSR);
    if (appViewModel != null && appViewModel.visible) {
      data.add(new _LeaderData(_LeaderData.TYPE_FWFSR, "服务费收入(万元)", url: "https://www.shuidichou.com/bd/battle-map/overview?selectType=orgData"));
    }
  }

  /// 数字去取整，万 单位
  String formatIntByWan(int? count) {
    if (count == null) {
      return "";
    }
    if (count <= 10000) {
      return "${count}";
    }
    return "${(count.toDouble() / 10000).toStringAsFixed(2)}万";
  }

  /// 数字去取整，万 单位
  String formatDoubleByWan(double count) {
    if (count == null) {
      return "";
    }
    return "${(count.toDouble() / 10000).toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return todayBdStaticsData == null
        ? Container()
        : Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 11),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 106.toDouble() / 78,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, position) {
                _LeaderData _leaderData = data[position];

                String title = _leaderData.title;
                String? count;
                String? pre;
                bool? isAdd = false;

                switch (_leaderData.id) {
                  case _LeaderData.TYPE_JD:
                    count = formatIntByWan(todayBdStaticsData!.donateTotalCount);
                    pre = Tools.formatIntByPre(todayBdStaticsData!.donateTotalCountAdd, todayBdStaticsData!.donateTotalCountAddCom);
                    isAdd = todayBdStaticsData!.donateTotalCountAddCom >= 0;
                    break;
                  case _LeaderData.TYPE_CKJE:
                    count = formatDoubleByWan(todayBdStaticsData!.donateAmount == null ? 0 : (todayBdStaticsData!.donateAmount.toDouble() / 100));
                    pre = Tools.formatDoubleByPre((todayBdStaticsData!.donateAmountAdd?.toDouble() ?? 0) / 1000000, todayBdStaticsData!.donateAmountAddCom);
                    isAdd = (todayBdStaticsData!.donateAmountAddCom ?? 0) >= 0;
                    break;
                  case _LeaderData.TYPE_FQ:
                    count = formatIntByWan(todayBdStaticsData!.cfCount);
                    pre = Tools.formatIntByPre(todayBdStaticsData!.cfCountAdd, todayBdStaticsData!.cfCountAddCom);
                    isAdd = (todayBdStaticsData!.cfCountAddCom ?? 0) >= 0;
                    break;
                  case _LeaderData.TYPE_YXFQ:
                    count = formatIntByWan(todayBdStaticsData!.cfValidCount);
                    pre = Tools.formatIntByPre(todayBdStaticsData!.cfValidCountAdd, todayBdStaticsData!.cfValidCountAddCom);
                    isAdd = (todayBdStaticsData!.cfValidCountAddCom ?? 0) >= 0;
                    break;
                  case _LeaderData.TYPE_ZFQ:
                    count = formatIntByWan(todayBdStaticsData!.offlineTotalCfCount);
                    pre = Tools.formatIntByPre(todayBdStaticsData!.offlineTotalCfCountAdd, todayBdStaticsData!.offlineTotalCfCountAddCom);
                    isAdd = (todayBdStaticsData!.offlineTotalCfCountAddCom ?? 0) >= 0;
                    String start = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd]);
                    String end = start;
                    _leaderData.url = (_leaderData.url ?? '') + "startTime=${start}&endTime=${end}";
                    break;
                  case _LeaderData.TYPE_XS:
                    count = formatIntByWan(todayBdStaticsData!.newClewCount);
                    pre = Tools.formatIntByPre(todayBdStaticsData!.newClewCountAdd, todayBdStaticsData!.newClewCountAddCom);
                    isAdd = (todayBdStaticsData!.newClewCountAddCom ?? 0) >= 0;
                    break;
                  case _LeaderData.TYPE_FWFSR:
                    count = formatDoubleByWan(todayBdStaticsData!.serviceFee == null ? 0 : (todayBdStaticsData!.serviceFee.toDouble() / 100));
                    pre = Tools.formatDoubleByPre((todayBdStaticsData!.serviceFeeAdd?.toDouble() ?? 0) / 1000000, todayBdStaticsData!.serviceFeeAddCom);
                    isAdd = (todayBdStaticsData!.serviceFeeAddCom ?? 0) >= 0;
                    break;
                }

                return _SDLeaderDataSummaryItemWidget(title, count, pre, isAdd, () async {
                  OpenNative.openWebView(_leaderData.url ?? '', "");

                  switch (_leaderData.id) {
                    case _LeaderData.TYPE_JD:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_JD, customParams: reportParams);
                      break;
                    case _LeaderData.TYPE_FQ:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_FQ, customParams: reportParams);
                      break;
                    case _LeaderData.TYPE_YXFQ:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_YXFQ, customParams: reportParams);
                      break;
                    case _LeaderData.TYPE_ZFQ:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_XXFQ, customParams: reportParams);
                      break;
                    case _LeaderData.TYPE_XS:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_XS, customParams: reportParams);
                      break;
                    case _LeaderData.TYPE_CKJE:
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_CKJE, customParams: reportParams);
                      break;
                  }
                });
              },
              itemCount: data.length,
            ),
          );
  }
}

class _LeaderData {
  /// 团队捐单
  static const int TYPE_JD = 0;

  /// 团队发起
  static const int TYPE_FQ = 1;

  /// 团队筹款金额
  static const int TYPE_CKJE = 5;

  /// 有效发起
  static const int TYPE_YXFQ = 2;

  /// 线下发起
  static const int TYPE_ZFQ = 3;

  /// 线索
  static const int TYPE_XS = 4;

  /// 服务费收入
  static const int TYPE_FWFSR = 6;

  int id;
  String title;
  String? url;

  _LeaderData(this.id, this.title, {this.url});
}

/// 团队数据  汇总区域 item
class _SDLeaderDataSummaryItemWidget extends StatelessWidget {
  String? title;
  String? count;
  String? pre;
  bool? isAdd;
  VoidCallback? clickItemListener;

  _SDLeaderDataSummaryItemWidget(this.title, this.count, this.pre, this.isAdd, this.clickItemListener);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickItemListener != null) {
          clickItemListener!();
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 6, right: 6),
        decoration: BoxDecoration(color: Color(isAdd ?? false ? 0xFFFFF3F4 : 0xFFE9F4F1), borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                title ?? "",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                ),
                maxFontSize: 12,
                minFontSize: 5,
                maxLines: 1,
              ),
            )),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                count ?? "",
                style: TextStyle(
                  color: Color(isAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxFontSize: 20,
                minFontSize: 5,
                maxLines: 1,
              ),
            )),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                pre ?? "",
                style: TextStyle(
                  color: Color(isAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                  fontSize: 12,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

/// 团队数据  分组统计数据控件
class SDLeaderDataOrgWidget extends StatefulWidget {
  List<CampaignMemberDetailModel>? memberDetailList;
  List<CampaignOrgDetailModel>? orgDetailList;
  SDUserInfo? userInfo;

  SDLeaderDataOrgWidget(this.memberDetailList, this.orgDetailList, this.userInfo);

  @override
  State<StatefulWidget> createState() {
    return _SDLeaderDataOrgWidgetState();
  }
}

class _SDLeaderDataOrgWidgetState extends State<SDLeaderDataOrgWidget> {
  static const int num = 5;
  SDUserInfo? userInfo;
  bool? isShowServiceFee;

  int getItemCount() {
    if (userInfo == null) {
      return 0;
    }
    if (isBusiness(userInfo)) {
      if (widget.memberDetailList == null) {
        return 0;
      }
      return isShowMore && (widget.memberDetailList == null ? 0 : widget.memberDetailList!.length) > num ? num : (widget.memberDetailList?.length ?? 0);
    } else {
      if (widget.orgDetailList == null) {
        return 0;
      }
      return isShowMore && (widget.orgDetailList == null ? 0 : widget.orgDetailList!.length) > num ? num : (widget.orgDetailList?.length ?? 0);
    }
  }

  static bool isBusiness(SDUserInfo? userInfo) {
    return userInfo?.roleCode == SDUserInfo.ROLE_BUSINESS ||
        userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL ||
        userInfo?.roleCode == SDUserInfo.ROLE_AGENT_LEADER ||
        userInfo?.roleCode == SDUserInfo.ROLE_AGENT_BOOS;
  }

  // 展开更多按钮是否正在展示
  bool isShowMore = true;

  // 是否可以展示更多按钮
  bool canShowMore() {
    if (userInfo == null) {
      return false;
    }
    if (isBusiness(userInfo)) {
      return widget.memberDetailList != null && widget.memberDetailList!.length > num;
    } else {
      return widget.orgDetailList != null && widget.orgDetailList!.length > num;
    }
  }

  @override
  void initState() {
    super.initState();
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_FWFSR);
    isShowServiceFee = appViewModel != null && appViewModel.visible;
    SDUserHelper.getUserInfo().then((userInfoValue) {
      if (mounted) {
        setState(() {
          userInfo = userInfoValue;
          isShowMore = canShowMore();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          isBusiness(userInfo)
              ? _SDBDDataSubWidget(
                  userInfo: userInfo,
                  memberDetailList: getMemberListChild(),
                )
              : _SDLeaderDataOrgSubWidget(
                  orgDetailList: getOrgDetailListChild(),
                  isShowServiceFee: isShowServiceFee,
                ),
          canShowMore()
              ? InkWell(
                  onTap: () async {
                    if (isShowMore) {
                      Map<String, String> reportParams = await Tools.buildCommonParams();
                      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_DATA_EXPEND, customParams: reportParams);
                    }
                    // 点击展开更多按钮
                    if (mounted) {
                      setState(() {
                        isShowMore = !isShowMore;
                      });
                    }
                  },
                  child: Container(
                    height: 24,
                    width: 89,
                    margin: EdgeInsets.only(bottom: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Color(0xFFF8F8F8), borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Text(
                      isShowMore ? "展开更多" : "收起更多",
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  getOrgDetailListChild() {
    List<CampaignOrgDetailModel> data = [];
    for (int p = 0; p < getItemCount(); p++) {
      data.add(widget.orgDetailList![p]);
    }
    return data;
  }

  getMemberListChild() {
    List<CampaignMemberDetailModel> data = [];
    for (int p = 0; p < getItemCount(); p++) {
      data.add(widget.memberDetailList![p]);
    }
    return data;
  }
}

/// 团队数据  分组统计数 item
class _SDLeaderDataOrgItemWidget extends StatelessWidget {
  String? lable1;

  String? lable2Up;
  String? lable2Down;
  bool? lable2IsAdd = false;

  String? lable3Up;
  String? lable3Down;
  bool? lable3IsAdd = false;

  String? lable4Up;
  String? lable4Down;
  bool? lable4IsAdd = false;

  // 是否展示Down 标签
  bool? isShowDown;

  SDUserInfo? userInfo;

  String? lableCKJEUp;
  String? lableCKJEDown;
  bool? lableCKJEIsAdd = false;

  _SDLeaderDataOrgItemWidget(this.lable1, this.lable2Up, this.lable2Down, this.lable2IsAdd, this.lable3Up, this.lable3Down, this.lable3IsAdd, this.lable4Up,
      this.lable4Down, this.lable4IsAdd, this.lableCKJEUp, this.lableCKJEDown, this.lableCKJEIsAdd,
      {this.isShowDown = true, this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text(
                lable1 ?? "",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              padding: EdgeInsets.only(right: 8, top: 0),
              alignment: Alignment.topLeft,
            ),
            flex: 48 + 10,
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Text(
                    lable2Up ?? "",
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  isShowDown ?? false
                      ? Text(
                          lable2Down ?? "",
                          style: TextStyle(
                            color: Color(lable2IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                            fontSize: 10,
                          ),
                        )
                      : Container()
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              padding: EdgeInsets.only(top: 2),
            ),
            flex: 48 + 18,
          ),
          _SDLeaderDataOrgWidgetState.isBusiness(userInfo)
              ? Container()
              : Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          lableCKJEUp ?? "",
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        isShowDown ?? false
                            ? Text(
                                lableCKJEDown ?? "",
                                style: TextStyle(
                                  color: Color(lableCKJEIsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                                  fontSize: 10,
                                ),
                              )
                            : Container()
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    padding: EdgeInsets.only(top: 2),
                  ),
                  flex: 48 + 25,
                ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Text(
                    lable3Up ?? '',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  isShowDown ?? false
                      ? Text(
                          lable3Down ?? '',
                          style: TextStyle(
                            color: Color(lable3IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                            fontSize: 10,
                          ),
                        )
                      : Container()
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              padding: EdgeInsets.only(top: 2),
            ),
            flex: 48 + 19,
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Text(
                    lable4Up ?? '',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  isShowDown ?? false
                      ? Text(
                          lable4Down ?? '',
                          style: TextStyle(
                            color: Color(lable4IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                            fontSize: 10,
                          ),
                        )
                      : Container()
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              padding: EdgeInsets.only(top: 2),
            ),
            flex: 48 + 6,
          ),
        ],
      ),
    );
  }
}

// 非管理角色数据看板
class _SDBDDataSubWidget extends StatefulWidget {
  List<CampaignMemberDetailModel>? memberDetailList;
  SDUserInfo? userInfo;

  _SDBDDataSubWidget({this.memberDetailList, this.userInfo});

  @override
  State<StatefulWidget> createState() {
    return _SDBDDataSubWidgetState();
  }
}

class _SDBDDataSubWidgetState extends State<_SDBDDataSubWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: 12, right: 12, top: 15, bottom: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "顾问姓名",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                ),
                flex: 48 + 10,
              ),
              Expanded(
                child: Text(
                  "发起",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                ),
                flex: 48 + 15,
              ),
              Expanded(
                child: Text(
                  "有效发起",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                ),
                flex: 48 + 15,
              ),
              Expanded(
                child: Text(
                  "捐单",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                ),
                flex: 48 + 6,
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, position) {
            String lable1;

            String lable2Up;
            String lable2Down;
            bool lable2IsAdd = false;

            String lable3Up;
            String lable3Down;
            bool lable3IsAdd = false;

            String lable4Up;
            String lable4Down;
            bool lable4IsAdd = false;

            String? lableCKJEUp;
            String? lableCKJEDown;
            bool lableCKJEIsAdd = false;

            CampaignMemberDetailModel model = widget.memberDetailList![position];
            lable1 = model.volunteerName;

            // 发起
            lable2Up = "${model.campaignBaseModel.offlineCaseCount}";
            lable2Down = Tools.formatIntByPre(model.campaignBaseModel.offlineCaseCountAdd, model.campaignBaseModel.offlineCaseCountAddCom);
            lable2IsAdd = model.campaignBaseModel.offlineCaseCountAddCom >= 0;

            // 有效发起
            lable3Up = "${model.campaignBaseModel.offValidCaseCount}";
            lable3Down = Tools.formatIntByPre(model.campaignBaseModel.offValidCaseCountAdd, model.campaignBaseModel.offValidCaseCountAddCom);
            lable3IsAdd = model.campaignBaseModel.offValidCaseCountAddCom >= 0;

            // 捐单
            lable4Up = "${model.campaignBaseModel.donateCount}";
            lable4Down = Tools.formatIntByPre(model.campaignBaseModel.donateCountAdd, model.campaignBaseModel.donateCountAddCom);
            lable4IsAdd = model.campaignBaseModel.donateCountAddCom >= 0;

            return InkWell(
              onTap: () {
                //  跳转链接
                CampaignMemberDetailModel model = widget.memberDetailList![position];
                String currentOrgName = Uri.encodeComponent("${model.volunteerName}发起案例");
                String url = "https://www.shuidichou.com/bd/manage-tree/case/personal?orgId=${model.uniqueCode}&currentOrgName=${currentOrgName}";
                OpenNative.openWebView(url, "");
              },
              child: _SDLeaderDataOrgItemWidget(lable1, lable2Up, lable2Down, lable2IsAdd, lable3Up, lable3Down, lable3IsAdd, lable4Up, lable4Down, lable4IsAdd,
                  lableCKJEUp, lableCKJEDown, lableCKJEIsAdd,
                  isShowDown: false, userInfo: widget.userInfo),
            );
          },
          itemCount: widget.memberDetailList?.length ?? 0,
        ),
      ],
    );
  }
}

// 管理角色团队数据看板
class _SDLeaderDataOrgSubWidget extends StatefulWidget {
  List<CampaignOrgDetailModel>? orgDetailList;
  bool? isShowServiceFee;

  _SDLeaderDataOrgSubWidget({this.orgDetailList, this.isShowServiceFee = false});

  @override
  State<StatefulWidget> createState() {
    return _SDLeaderDataOrgSubWidgetState();
  }
}

class _SDLeaderDataOrgSubWidgetState extends State<_SDLeaderDataOrgSubWidget> {
  double leftRightMargin = 4;
  double? titleCellWidth;
  double? cellWidth;
  double? cellHeight;
  GlobalKey _titleKey = GlobalKey();
  GlobalKey _donateAmountKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      Size? size = _titleKey.currentContext?.findRenderObject()?.paintBounds.size;
      if (size != null) {
        titleCellWidth = size.width;
        cellWidth = (Tools.getScreenWidth(context) - 8 * 2 - 12 - leftRightMargin - (titleCellWidth ?? 0)) / 4 - ((widget.isShowServiceFee ?? false) ? 2 : 0);
      }
      Size? donateSize = _donateAmountKey.currentContext?.findRenderObject()?.paintBounds.size;
      if (donateSize != null) {
        cellHeight = donateSize.height;
      }
      if (size != null && donateSize != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 13),
                alignment: Alignment.center,
                height: cellHeight,
                child: Text(
                  "组织名称",
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                  key: _titleKey,
                ),
              ),
              Column(
                children: getOrgWidgets(),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: EdgeInsets.only(left: leftRightMargin),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: cellWidth,
                          height: cellHeight,
                          child: Text(
                            "团队捐单",
                            style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                          ),
                        ),
                        Container(
                          key: _donateAmountKey,
                          alignment: Alignment.centerLeft,
                          width: cellWidth,
                          height: cellHeight,
                          child: AutoSizeText(
                            "团队筹款\n金额(万元)",
                            style: TextStyle(
                              color: Color(0xFF999999),
                            ),
                            maxLines: 2,
                            maxFontSize: 12,
                            minFontSize: 6,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: cellWidth,
                          height: cellHeight,
                          child: AutoSizeText(
                            "团队发起",
                            style: TextStyle(color: Color(0xFF999999)),
                            maxFontSize: 12,
                            minFontSize: 6,
                            maxLines: 2,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: cellWidth,
                          height: cellHeight,
                          child: Text(
                            "有效发起",
                            style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                          ),
                        ),
                        (widget.isShowServiceFee ?? false)
                            ? Container(
                                alignment: Alignment.centerLeft,
                                width: cellWidth,
                                height: cellHeight,
                                child: AutoSizeText(
                                  "服务费收\n入(万元)",
                                  style: TextStyle(color: Color(0xFF999999)),
                                  maxFontSize: 12,
                                  minFontSize: 6,
                                  maxLines: 2,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Column(
                    children: getDataWidgets(
                        onTap: (model) {
                          String currentOrgName = Uri.encodeComponent("${model.orgName}");
                          String url = "https://www.shuidichou.com/bd/manage-tree/case/?orgId=${model.orgId}&currentOrgName=${currentOrgName}";
                          OpenNative.openWebView(url, "");
                        },
                        isShowServiceFee: widget.isShowServiceFee),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取组织widget
  getOrgWidgets() {
    double height = 37;
    List<Widget> children = [];
    if (cellWidth == null || cellWidth! <= 0) {
      return children;
    }
    widget.orgDetailList?.forEach((element) {
      children.add(Container(
        width: titleCellWidth,
        height: height,
        child: Text(
          element.orgName ?? "",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        margin: EdgeInsets.only(bottom: 12),
        alignment: Alignment.topLeft,
      ));
    });
    return children;
  }

  // 获取组织数据widget
  getDataWidgets({ValueChanged? onTap, bool? isShowServiceFee = false}) {
    double height = 37;

    List<Widget> children = [];
    if (cellWidth == null || cellWidth! <= 0) {
      return children;
    }
    widget.orgDetailList?.forEach((model) {
      // 捐单
      var lable2Up = "${model.campaignBaseModel.donateCount}";
      var lable2Down = Tools.formatIntByPre(model.campaignBaseModel.donateCountAdd, model.campaignBaseModel.donateCountAddCom);
      var lable2IsAdd = model.campaignBaseModel.donateCountAddCom >= 0;

      // 发起
      var lable3Up = "${model.campaignBaseModel.offlineCaseCount}";
      var lable3Down = Tools.formatIntByPre(model.campaignBaseModel.offlineCaseCountAdd, model.campaignBaseModel.offlineCaseCountAddCom);
      var lable3IsAdd = model.campaignBaseModel.offlineCaseCountAddCom >= 0;

      // 有效发起
      var lable4Up = "${model.campaignBaseModel.offValidCaseCount}";
      var lable4Down = Tools.formatIntByPre(model.campaignBaseModel.offValidCaseCountAdd, model.campaignBaseModel.offValidCaseCountAddCom);
      var lable4IsAdd = model.campaignBaseModel.offValidCaseCountAddCom >= 0;

      // 筹款金额
      var lableCKJEUp = "${((model.campaignBaseModel.donateAmount ?? 0) / 1000000).toStringAsFixed(2)}";
      var lableCKJEDown = Tools.formatDoubleByPre(model.campaignBaseModel.donateAmountAdd.toDouble() / 1000000, model.campaignBaseModel.donateAmountAddCom);
      var lableCKJEIsAdd = model.campaignBaseModel.donateAmountAddCom >= 0;

      // 服务费收入
      var lableServiceFeeUp = "${((model.campaignBaseModel.serviceFee ?? 0) / 1000000).toStringAsFixed(2)}";
      var lableServiceFeeDown = Tools.formatDoubleByPre((model.campaignBaseModel.serviceFeeAdd?.toDouble() ?? 0) / 1000000, model.campaignBaseModel.serviceFeeAddCom);
      var lableServiceFeeIsAdd = model.campaignBaseModel.serviceFeeAddCom >= 0;

      Widget child = GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap(model);
          }
        },
        child: Container(
          child: Row(
            children: [
              Container(
                width: cellWidth,
                height: height,
                child: Column(
                  children: [
                    Text(
                      lable2Up ?? "",
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      lable2Down ?? "",
                      style: TextStyle(
                        color: Color(lable2IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                        fontSize: 10,
                      ),
                      maxFontSize: 10,
                      minFontSize: 5,
                      maxLines: 1,
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              Container(
                width: cellWidth,
                height: height,
                child: Column(
                  children: [
                    Text(
                      lableCKJEUp ?? "",
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      lableCKJEDown ?? "",
                      style: TextStyle(
                        color: Color(lableCKJEIsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                        fontSize: 10,
                      ),
                      maxFontSize: 10,
                      minFontSize: 5,
                      maxLines: 1,
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              Container(
                width: cellWidth,
                height: height,
                child: Column(
                  children: [
                    Text(
                      lable3Up ?? '',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      lable3Down ?? '',
                      style: TextStyle(
                        color: Color(lable3IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                        fontSize: 10,
                      ),
                      maxFontSize: 10,
                      minFontSize: 5,
                      maxLines: 1,
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              Container(
                width: cellWidth,
                height: height,
                child: Column(
                  children: [
                    Text(
                      lable4Up ?? '',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      lable4Down ?? '',
                      style: TextStyle(
                        color: Color(lable4IsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                        fontSize: 10,
                      ),
                      maxFontSize: 10,
                      minFontSize: 5,
                      maxLines: 1,
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              (isShowServiceFee ?? false)
                  ? Container(
                      width: cellWidth,
                      height: height,
                      child: Column(
                        children: [
                          Text(
                            lableServiceFeeUp ?? '',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          AutoSizeText(
                            lableServiceFeeDown ?? '',
                            style: TextStyle(
                              color: Color(lableServiceFeeIsAdd ?? false ? 0xFFD33F42 : 0xFF459678),
                              fontSize: 10,
                            ),
                            maxFontSize: 10,
                            minFontSize: 5,
                            maxLines: 1,
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    )
                  : Container(),
            ],
          ),
          margin: EdgeInsets.only(bottom: 12),
        ),
      );

      children.add(child);
    });
    return children;
  }
}
