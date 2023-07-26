import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/Engine/SDWhaleEngine.dart';
import 'package:fluttercrmmodule/data/DataHelper.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/AppViewModel.dart';
import 'package:fluttercrmmodule/pages/bean/BacklogListBean.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignHospitalAreaDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignMemberDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignOrgDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CfBdcrmOfficialAnnounceVO.dart';
import 'package:fluttercrmmodule/pages/bean/CheckTotalNumberOfCustomersBean.dart';
import 'package:fluttercrmmodule/pages/bean/CrmBdHomePageStatistics.dart';
import 'package:fluttercrmmodule/pages/bean/CurrentWeekObjective.dart';
import 'package:fluttercrmmodule/pages/bean/HomeReward.dart';
import 'package:fluttercrmmodule/pages/bean/OrgList.dart';
import 'package:fluttercrmmodule/pages/bean/Organization.dart';
import 'package:fluttercrmmodule/pages/bean/TodayBdStaticsData.dart';
import 'package:fluttercrmmodule/pages/bean/TrendModel.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/GlobalManager.dart';
import 'package:fluttercrmmodule/pages/common/PageName.dart';
import 'package:fluttercrmmodule/pages/common/UrlConstant.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/HomeConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/home/reward/CrmHomeRewardWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/target/TargetWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/tips/TipsWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/todo/TodoWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/viewModel/HomeViewModel.dart';
import 'package:fluttercrmmodule/utils/SdEventBus.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sd_flutter_base/module/base/BasePage.dart';
import 'package:sd_flutter_base/module/base/SimplePage.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/user/UserHelper.dart';
import 'package:sd_flutter_base/widgets/SdRefreshWidget.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

import '../../../main.dart';
import '../../../widgets/sdesign_button.dart';
import 'customers/CustomersCountWidget.dart';
import 'data/BdDataWidget.dart';
import 'data/SDDataChartView.dart';
import 'data/SDHomeOrgTabWidget.dart';
import 'data/SDHospitalDataWidget.dart';
import 'data/SDLeaderDataWidget.dart';
import 'funtions/FunsWidget.dart';

/// 首页
class CrmHomeWidge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CrmHomeWidgeState();
  }
}

class _CrmHomeWidgeState extends State<CrmHomeWidge> with AutomaticKeepAliveClientMixin, RouteAware, SDPageVisibileObserver {
  RefreshController? _refreshController;
  int refreshFlag = 0;
  bool _showLoading = false;

  /// 是否展示签到按钮
  bool _showSignInButton = false;

  /// 用户数据
  SDUserInfo? sdUserInfo;

  /// 是否已经展示承诺书弹框
  bool _isShowLetter = false;

  /// 组织数据
  List<Organization>? orgList;

  /// 选中的组织(用户信息中的组织)
  Organization? chooseOrg;

  /// bd 发起案例、线索 统计数据
  CrmBdHomePageStatistics? bdHomePageStatistics;

  /// 待办数据
  List<BacklogBean>? backlogList;

  /// 官宣轮播数据
  List<CfBdcrmOfficialAnnounceVO>? tipsList;

  /// 目标数据
  CurrentWeekObjective? targetInfo;

  /// icon 功能 数据
  List<AppIconModelList>? iconList;

  /// TODO ？？？
  CheckTotalNumberOfCustomersBean? checkTotalNumberOfCustomersBean;

  /// 今日趋势图数据
  List<TrendModel>? trendModelList;

  ///  今日团队数据-汇总区域数据源
  TodayBdStaticsData? todayBdStaticsData;

  /// 今日团队数据-组织区域统计数据-业务经理
  List<CampaignMemberDetailModel>? memberDetailList;

  /// 今日团队数据-组织区域统计数据-管理角色（除业务经理）
  List<CampaignOrgDetailModel>? orgDetailList;

  /// 城市集合
  List<OrgList>? campaignCityDetailModelList;

  /// 今日医院数据
  List<CampaignHospitalAreaDetailModel>? hospitalAreaDetailList;

  /// 今日医院大区选中组织
  OrgList? choicedOrg;

  /// 今日医院大区选中城市
  List<CityList>? choicedCity;

  /// 奖励任务数据
  List<HomeReward>? homeRewardList;

  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    ModalRoute? modalRoute = ModalRoute.of(context);
    if(modalRoute != null){
      App.routeObserver.subscribe(this, modalRoute as PageRoute); //订阅
    }
    super.didChangeDependencies();
    SDPageLifecycler.instance.addObserver(this, context);
  }

  @override
  void onPageShow() {
    super.onPageShow();
    // showLetterCommitmentAlert();
    if (SDWhaleEngine().selectPageName == "home") {
      getData();
    }
  }

  @override
  void dispose() {
    if (_eventSubscription != null) {
      _eventSubscription!.cancel();
    }
    App.routeObserver.unsubscribe(this);
    SDPageLifecycler.instance.removeObserver(this);
    super.dispose();
  }

  startRefreshRequest() {
    refreshFlag += 1;
    print("startRefreshRequest = ${refreshFlag}");
  }

  refreshComplete() {
    refreshFlag -= 1;
    print("refreshComplete = ${refreshFlag}");
    if (refreshFlag == 0) {
      _refreshController?.refreshCompleted();
      _showLoading = false;
      if(mounted){
        setState(() {});
      }
    }
  }

  init() async {
    _showLoading = ConfigHelper.isFetchSuccess;
    _refreshController = RefreshController(initialRefresh: false);
    getData();
    showLetterCommitmentAlert();
    _eventSubscription = sdEventBus.listenEvent((EventFactory eventFactory) {
      if (eventFactory.type == EventType.homeloading) {
        setState(() {
          _showLoading = eventFactory.params;
        });
      } else if (eventFactory.type == EventType.updataHomeReward) {
        setState(() {
          homeRewardList = eventFactory.params;
        });
      }
    });
  }

  /// 获取主流程数据
  /// 必须参与刷新控件 刷新操作
  getData() async {
    ConfigHelper.fetchConfigData((fetchSuccess, appViewModelList) async {
      if (fetchSuccess) {
        getBussinessData();
      } else {
        if (_refreshController != null) {
          _refreshController!.refreshCompleted();
        }
      }
    });
  }

  /// 获取业务数据
  getBussinessData() async {
    // 获取用户数据
    SDUserInfo? userInfo = await getUserInfo();
    sdUserInfo = userInfo;
    SDUserHelper.saveUserInfo(userInfo);

    // 官宣tips
    getTipsData();
    // 功能区
    getKingKongSeniorData();
    // 奖励任务
    getRewardData();
    // 待办
    getTodoData();
    // 获取BD发起案例、线索数据
    getBdData();
    // 趋势图 、 团队数据 、 医院发起
    getChartViewData();
    // TODO ???
    getCustomersCountData();
    getSecondProcessData();
  }

  /// 获取非主流程数据
  /// 非主流程请求不必关联控制
  /// 刷新控件是否可以停止刷新
  getSecondProcessData() {
    // 获取签到按钮是否展示
    fetchSignInButtonSwitch();
  }

  /// 获取趋势图、团队数据、医院 数据
  getChartViewData() async {
    // 获取用户组织数据
    if (sdUserInfo != null) {
      orgList = sdUserInfo!.bdCrmOrganizationList;
      if (chooseOrg == null && orgList != null && orgList!.length > 0) {
        // 设置默认选中第一个
        chooseOrg = orgList![0];
      }
    }

    int? orgId = chooseOrg?.id;
    bool canShowOrg = false;

    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRJDQS);
    if (appViewModel != null && appViewModel.visible) {
      // 今日趋势图
      canShowOrg = true;
      startRefreshRequest();
      HomeViewModel.getTodayTrend(orgId).then((data) {
        trendModelList = data;
        refreshComplete();
        // 添加埋点监控
        if (trendModelList != null && trendModelList!.length > 0) {
          Tools.reportHomeChartDataPoint(trendModelList!, Tools.HOME_CHART_TYPE_API);
        }
      });
    }

    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ);
    if (appViewModel != null && appViewModel.visible) {
      // 今日数据-汇总数据
      canShowOrg = true;
      startRefreshRequest();
      HomeViewModel.getTodayBdStatistics(orgId).then((data) {
        todayBdStaticsData = data;
        refreshComplete();
      });

      if (sdUserInfo?.roleCode == SDUserInfo.ROLE_BUSINESS ||
          sdUserInfo?.roleCode == SDUserInfo.ROLE_CHANNEL ||
          sdUserInfo?.roleCode == SDUserInfo.ROLE_AGENT_LEADER ||
          sdUserInfo?.roleCode == SDUserInfo.ROLE_AGENT_BOOS) {
        // 今日数据-组织数据-业务经理
        startRefreshRequest();
        HomeViewModel.getListSubMemberTodayData(orgId).then((value) {
          memberDetailList = value;
          refreshComplete();
        });
      }

      // 今日数据-组织数据-非业务经理
      startRefreshRequest();
      HomeViewModel.getlistSubOrgTodayData(orgId).then((value) {
        orgDetailList = value;
        refreshComplete();
      });
    }

    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRYYFQ);
    if (appViewModel != null && appViewModel.visible) {
      // 医院数据
      canShowOrg = true;
      getTodayHospitalData();
    }

    appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.BYMB);
    if (appViewModel != null && appViewModel.visible) {
      // 目标数据
      canShowOrg = true;
      startRefreshRequest();
      HomeViewModel.getTargetData().then((value) {
        targetInfo = value;
        refreshComplete();
      });
    }

    if (!canShowOrg) {
      orgList = null;
    }
  }

  getTodayHospitalData() async {
    // 医院数据
    startRefreshRequest();
    HomeViewModel.getCityList(chooseOrg?.id).then((value) async {
      campaignCityDetailModelList = value;
      if (campaignCityDetailModelList == null) {
        campaignCityDetailModelList = [];
      }
      OrgList orgList = OrgList.fromJson({
        "provinceId": -1,
        "provinceName": "全部城市",
      });
      orgList.cityList = [
        CityList.fromJson({
          "cityId": -1,
          "cityName": "全部",
        })
      ];
      campaignCityDetailModelList!.insert(0, orgList);
      choicedOrg = campaignCityDetailModelList![0];
      choicedCity = choicedOrg?.cityList;
      List<int> cityIds = [];
      if (choicedCity != null) {
        for (CityList cityList in choicedCity!) {
          if (cityList.cityId == -1) {
            continue;
          }
          cityIds.add(cityList.cityId);
        }
      }
      hospitalAreaDetailList = await HomeViewModel.getLeaderHospitalTodayData(chooseOrg?.id, cityIds);
      refreshComplete();
    });
  }

  /// 获取BD发起案例、线索数据
  getBdData() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.FQALXS);
    if (appViewModel != null && appViewModel.visible) {
      startRefreshRequest();
      bdHomePageStatistics = await HomeViewModel.getBdData();
      refreshComplete();
    }
  }

  /// 获取待办区域数据
  getTodoData() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JRTDSJ_DB);
    if (appViewModel != null && appViewModel.visible) {
      startRefreshRequest();
      SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
      DataHelper.instant().getBacklogList(userInfo?.wxToken, (response) {
        if (response.isSuccess()) {
          if (mounted) {
            setState(() {
              backlogList = response.module;
            });
          }
        }
        refreshComplete();
      });
    }
  }

  /// 获取用户数据
  Future<SDUserInfo?> getUserInfo() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    SDResponse<SDUserInfo> response = await NetImp.getSDUserInfo();
    if (response.isSuccess() && response.module != null) {
      String wxToken = userInfo?.wxToken ?? "";
      userInfo = response.module;
      userInfo?.wxToken = wxToken;
    }
    return userInfo;
  }

  /// 获取官宣轮播tips数据
  getTipsData() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.GX);
    if (appViewModel != null && appViewModel.visible) {
      startRefreshRequest();
      tipsList = await HomeViewModel.getTipsData();
      refreshComplete();
    }
  }

  /// 获取功能区域数据
  getKingKongSeniorData() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.JGW);
    if (appViewModel != null && appViewModel.visible) {
      startRefreshRequest();
      iconList = await HomeViewModel.getKingKongSeniorData();
      refreshComplete();
    }
  }

  /// 奖励任务
  getRewardData() async {
    startRefreshRequest();
    SDResponse<List<HomeReward>> response = await NetImp.getHomePageList();
    homeRewardList = response.module;
    refreshComplete();
  }

  /// GR 角色相关数据
  getCustomersCountData() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.KHSCSH);
    if (appViewModel != null && appViewModel.visible) {
      startRefreshRequest();
      checkTotalNumberOfCustomersBean = await HomeViewModel.getCustomersCountData();
      refreshComplete();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    bool isBack = ModalRoute.of(context)?.isCurrent ?? false;
    if (isBack) {
      // showLetterCommitmentAlert();
      getData();
    }
  }

  showLetterCommitmentAlert() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    bool show = await SDWhaleEngine.readLetterCommitmentCacheData(userInfo);
    if (!show) {
      _showLetterCommitmentBacklogAlert(GlobalManager().sdGloobal.currentState?.overlay?.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SimplePage(
      Container(
        color: Color(0xFFF2F2F2),
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            Image.asset(
              "images/crm_home_top_bg.png",
              height: Tools.getScreenWidth(context) * 200 / 375,
              width: Tools.getScreenWidth(context),
              fit: BoxFit.fill,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: SdRefreshWidget(
                _refreshController!,
                enablePullUp: false,
                enablePullDown: true,
                textStyle: TextStyle(
                  color: Color(0xFF66A9FE),
                ),
                refreshingColor: Color(0xFF66A9FE),
                arrowUpwardColor: Color(0xFF66A9FE),
                doneColor: Color(0xFF66A9FE),
                errorColor: Color(0xFF66A9FE),
                downloadColor: Color(0xFF66A9FE),
                onRefresh: () {
                  if (mounted) {
                    setState(() {
                      orgList = null;
                      tipsList = null;
                      iconList = null;
                      backlogList = null;
                      checkTotalNumberOfCustomersBean = null;
                      todayBdStaticsData = null;
                      memberDetailList = null;
                      orgDetailList = null;
                      hospitalAreaDetailList = null;
                      targetInfo = null;
                      trendModelList = null;
                    });
                  }
                  getData();
                },
                onLoadmore: () {},
                child: ListView(
                  padding: EdgeInsets.only(bottom: 40),
                  children: <Widget>[
                    TipsWidget(
                      dataList: tipsList,
                    ),
                    FunsWidget(
                      iconList: iconList,
                    ),
                    CrmHomeRewardWidget(homeRewardList),
                    backlogList == null ? Container() : TodoWidget(backlogList),
                    SizedBox(height: 16),
                    orgList == null
                        ? Container()
                        : SDHomeOrgTabWidget(
                            orgList: orgList,
                            chooseOrg: chooseOrg,
                            clickTabListener: (org) {
                              chooseOrg = org;
                              if (mounted) {
                                setState(() {
                                  todayBdStaticsData = null;
                                  memberDetailList = null;
                                  orgDetailList = null;
                                  hospitalAreaDetailList = null;
                                  targetInfo = null;
                                  trendModelList = null;
                                });
                              }
                              getChartViewData();
                            },
                          ),
                    trendModelList == null ? Container() : SDDataChartView(trendModelList),
                    todayBdStaticsData == null ? Container() : SDLeaderDataWidget(todayBdStaticsData, memberDetailList, orgDetailList),
                    hospitalAreaDetailList == null
                        ? Container()
                        : SDHospitalDataWidget(hospitalAreaDetailList, campaignCityDetailModelList, choicedOrg, choicedCity, (choicedOrg) {
                            this.choicedOrg = choicedOrg;
                          }, (choicedCity) {
                            this.choicedCity = choicedCity;
                            List<int> cityIds = [];
                            if (choicedCity != null) {
                              for (CityList cityList in choicedCity) {
                                if (cityList.cityId == -1) {
                                  continue;
                                }
                                cityIds.add(cityList.cityId);
                              }
                            }
                            HomeViewModel.getLeaderHospitalTodayData(chooseOrg?.id, cityIds).then((value) {
                              hospitalAreaDetailList = value;
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          }),
                    BdDataWidget(bdHomePageStatistics),
                    targetInfo == null ? Container() : TargetWidget(targetInfo: targetInfo),
                    CustomersCountWidget(info: checkTotalNumberOfCustomersBean),
                  ],
                ),
              ),
            ),
            signInView(),
            _showLoading ? LoadingWidget() : Container()
          ],
        ),
      ),
      actionBarLeftShow: false,
      actionbarBgColor: Color(0xFF0071FE),
      actionBarCentWidget: const Text(
        "鲸小胖",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      showLoading: _showLoading,
      actionBarRightWidget: <Widget>[
        getKeFuWidget(),
      ],
    );
  }

  /// 获取标题客服组件
  getKeFuWidget() {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.KF);
    if (appViewModel != null && appViewModel.visible) {
      return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          OpenNative.reportLocationService("kefu");

          // 打开客服页面
          UserHelper.getUserInfo().then((userInfo) {
            Map<String, String> reportParams = HashMap();
            reportParams['bd_rank'] = userInfo?.roleCode?.toString() ?? '';
            reportParams['bd_name'] = userInfo?.volunteerName ?? '';
            reportParams['uniqueCode'] = userInfo?.uniqueCode ?? '';
            reportParams['bd_misid'] = userInfo?.mis ?? '';
            reportParams['reportName'] = PageName.HomePage;
            SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_KEFU, customParams: reportParams);
            OpenNative.openWebView(UrlConstant.URL_CUSTOMER_SERVICE + "${userInfo?.wxToken}", "");
          });
        },
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Image.asset(
            "images/crm_home_kefu.png",
            width: 20,
            height: 20,
          ),
        ),
      );
    }
    return Container();
  }

  Positioned signInView() {
    return Positioned(
        bottom: 64,
        right: 0,
        child: !_showSignInButton
            ? Container()
            : InkWell(
                child: Container(
                  width: 86,
                  height: 54,
                  child: Image.asset("images/home_hospital_sign.png"),
                ),
                onTap: () {
                  SDWhaleEngine.reportCode(ElementCode.CODE_SIGN_IN, PageName.HomePage);
                  OpenNative.openSignInView('');
                },
              ));
  }

  /// 获取BD 医院签到按钮是展示
  fetchSignInButtonSwitch() async {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(HomeConfigConstant.YYQD);
    if (appViewModel != null && appViewModel.visible) {
      SDResponse<int> response = await NetImp.fetchSignInSwitch();
      if (response.isSuccess()) {
        if (mounted) {
          setState(() {
            _showSignInButton = response.module == 2;
          });
        }
      }
    }
  }

  /// 展示承诺书弹框
  _showLetterCommitmentBacklogAlert(BuildContext? context) {

    if(context == null){
      return;
    }

    if (_isShowLetter) {
      return;
    }

    _isShowLetter = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Container(
              height: 360,
              padding: EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 20),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 28),
                    alignment: Alignment.center,
//                                        height: 44,
                    child: Text(
                      "承诺书",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    child: Text(
                      "鲸小胖将按照《用户协议》以及《承诺书》的内容为您提供服务。",
                      maxLines: 3,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    child: Text(
                      "如您不同意上述协议，您可以点击\"不同意\"后退出应用。",
                      maxLines: 3,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text.rich(TextSpan(children: [
                        // WidgetSpan(child: Icon(Icons.star)),
                        TextSpan(text: "如您同意", style: TextStyle(fontSize: 15, color: Colors.black)),
                        TextSpan(
                            text: "《承诺书》",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                String url = getLetterCommitment();
                                OpenNative.openWebView(url, "");
                              },
                            style: TextStyle(fontSize: 16, color: Color(0xFF0071FE))),
                        TextSpan(text: "，请点击\"同意并继续\"开始使用我们的产品和服务。", style: TextStyle(fontSize: 15, color: Colors.black)),
                      ]))),
                  SizedBox(height: 20),
                  Container(
                    child: Expanded(
                      flex: 1,
                      child: SDFlatButton(
                        color: Colors.white,
                        onPressed: () {
                          SDWhaleEngine.saveLetterCommitmentCacheData(sdUserInfo, false);
                          Navigator.of(context).pop();
                          exit(0);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.expand(),
                          child: Text(
                            "不同意",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF848484),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SDFlatButton(
                      color: Color(0xFF0056FE),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      onPressed: () {
                        _isShowLetter = false;
                        SDWhaleEngine.saveLetterCommitmentCacheData(sdUserInfo, true);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        constraints: BoxConstraints.expand(),
                        child: Text(
                          "同意并继续",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
//                                                                    backgroundColor: Color(0xFF0056FE),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// 获取承诺书链接
  getLetterCommitment() {
    int? roleCode = sdUserInfo?.roleCode;
    if (roleCode == SDUserInfo.ROLE_PART_TIME || sdUserInfo?.partnerTag == 1) {
      return "https://www.shuidichou.com/luban/ewfwy5h6357j/1";
    } else if (roleCode == SDUserInfo.ROLE_AGENT_BOOS || roleCode == SDUserInfo.ROLE_AGENT_LEADER || roleCode == SDUserInfo.ROLE_AGENT_MEMBER) {
      return "https://www.shuidichou.com/luban/xkis44yeh3zj/1";
    } else {
      return "https://www.shuidichou.com/luban/xm5zj3k5apkp/1";
    }
  }

  @override
  bool get wantKeepAlive => true;
}
