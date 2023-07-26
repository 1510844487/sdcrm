import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/data/DataHelper.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/BdHomePageVo.dart';
import 'package:fluttercrmmodule/pages/bean/CheckPerformanceBean.dart';
import 'package:fluttercrmmodule/pages/bean/CheckVersionBean.dart';
import 'package:fluttercrmmodule/pages/bean/MyInfoBean.dart';
import 'package:fluttercrmmodule/pages/bean/MyInfoProgressBean.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/MineConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/my/views/MyCloseAccountWidget.dart';
import 'package:fluttercrmmodule/pages/main/my/views/MyHeaderWidget.dart';
import 'package:fluttercrmmodule/pages/main/my/views/MyListWidget.dart';
import 'package:fluttercrmmodule/pages/main/my/views/MyLogoutWidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sd_flutter_base/module/base/BasePage.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';
import 'package:sd_flutter_base/widgets/SdRefreshWidget.dart';
import 'package:sd_flutter_storage/SDStorage.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key, required this.title});

  final String title;

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with AutomaticKeepAliveClientMixin, SDPageVisibileObserver {
  MyInfoBean? myInfo;
  MyInfoProgressBean? progressInfo;
  CheckPerformanceBean? personInfo;
  CheckPerformanceBean? teamInfo;
  RefreshController refreshController = RefreshController(initialRefresh: false);
  String? version;
  String? headUrl;
  CheckVersionBean? versionBean;
  bool showNewPage = false;

  // 个人主页
  bool my_page_visible = false;

  // 我的绩效
  bool my_performance_visible = false;

  // 团队绩效
  bool team_performance_visible = false;

  // 当前版本
  bool version_visible = false;

  // 完善信息
  bool complete_info_visible = false;

  // 退出登录
  bool log_out_visible = false;

  // 注销账户(仅iOS)
  bool close_account_visible = false;

  @override
  void initState() {
    super.initState();
    ConfigHelper.fetchConfigData((fetchSuccess, appViewModelList) async {
      if (fetchSuccess) {
        // 个人主页
        final my_page = ConfigHelper.getAppViewModel(MineConfigConstant.MY_PAGE);
        if (my_page != null) {
          my_page_visible = my_page.visible;
        }
        // 我的绩效
        final my_performance = ConfigHelper.getAppViewModel(MineConfigConstant.MY_PERFORMANCE);
        if (my_performance != null) {
          my_performance_visible = my_performance.visible;
        }
        // 团队绩效
        final team_performance = ConfigHelper.getAppViewModel(MineConfigConstant.TEAM_PERFORMANCE);
        if (my_performance != null) {
          team_performance_visible = team_performance.visible;
        }
        // 当前版本
        final version = ConfigHelper.getAppViewModel(MineConfigConstant.CURRENT_VERSION);
        if (version != null) {
          version_visible = version.visible;
        }
        // 完善信息
        final complete_info = ConfigHelper.getAppViewModel(MineConfigConstant.COMPLETE_INFO);
        if (complete_info != null) {
          complete_info_visible = complete_info.visible;
        }
        // 退出登录
        final log_out = ConfigHelper.getAppViewModel(MineConfigConstant.LOG_OUT);
        if (log_out != null) {
          log_out_visible = log_out.visible;
        }
        // 注销账户
        final platform_iOS = Platform.isIOS;
        bool apple_checking = await SDStorage.instance().getBool("appleChecking");
        close_account_visible = platform_iOS && apple_checking;
        requestAllIn();
      }
    });
  }

  @override
  void dispose() {
    refreshController.dispose();
    SDPageLifecycler.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BasePage(
      Container(
        color: Color(0xFFF2F2F2),
        child: SdRefreshWidget(
          refreshController,
          enablePullUp: false,
          enablePullDown: true,
          onRefresh: () {
            requestAllIn();
          },
          onLoadmore: () {},
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            child: Material(
              color: Color(0xFFF2F2F2),
              child: Padding(
                padding: EdgeInsets.only(top: 64),
                child: Column(
                  children: buildColumnChildren(),
                ),
              ),
            ),
          ),
        ),
      ),
      showLoading: false,
      backgroundColor: Color(0xFFF2F2F2),
    );
  }

  List<Widget> buildColumnChildren() {
    if (myInfo != null) {
      return [
        MyHeaderWidget(
          myInfo: myInfo,
          progressInfo: progressInfo,
          headUrl: headUrl ?? '',
          completeInfoVisible: complete_info_visible,
        ),
        MyListWidget(
          personInfo: personInfo,
          teamInfo: teamInfo,
          version: version,
          versionBean: versionBean,
          showNewPage: showNewPage,
          myPageVisible: my_page_visible,
          myPerformanceVisible: my_performance_visible,
          teamPerformanceVisible: team_performance_visible,
          versionVisible: version_visible,
          myInfo: null,
        ),
        log_out_visible ? MyLogoutWidget() : Container(),
        close_account_visible ? MyCloseAccountWidget() : Container(),
      ];
    } else {
      return [Container()];
    }
  }

  getData() async {
    SDResponse<MyInfoBean> response = await NetImp.fetchMyDataInfo();
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted(resetFooterState: true);
    }

    MyInfoBean? module = response.module;
    if (response.isSuccess()) {
      myInfo = module;
      if (mounted) {
        setState(() {});
      }
    }
  }

  getABTestData() async {
    SDResponse<int> response = await NetImp.fetchABTestData();
    if (response.isSuccess()) {
      if (response.data != null) {
        int version = response.data;
        showNewPage = (version == 2) ? true : false;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  getProgressData() async {
    SDResponse<MyInfoProgressBean> response = await NetImp.fetchFillInfoProgress();
    MyInfoProgressBean? module = response.module;
    if (response.isSuccess()) {
      progressInfo = module;
      if (mounted) {
        setState(() {});
      }
    }
  }

  updatePersonPerformance() async {
    SDResponse<CheckPerformanceBean> response = await NetImp.updatePersonPerformance();
    CheckPerformanceBean? module = response.module;
    if (response.isSuccess()) {
      personInfo = module;
      if (mounted) {
        setState(() {});
      }
    }
  }

  updateTeamPerformance() async {
    SDResponse<CheckPerformanceBean> response = await NetImp.updateTeamPerformance();
    CheckPerformanceBean? module = response.module;
    if (response.isSuccess()) {
      teamInfo = module;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void getVersion() async {
    version = await NetImp.getVersion();
  }

  Future<void> fetchUserInfo() async {
    DataHelper.instant().getClientUserInfo((response) {
      if (response.isSuccess()) {
        BdHomePageVo? userInfo = response.module;
        if (userInfo != null) {
          headUrl = userInfo.headUrl ?? '';
        }
      } else {
        String? msg = response.msg;
        if (msg != null && msg.isNotEmpty) {
          ToastHelper.showShort(msg);
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  checkAppVersion() async {
    SDResponse<CheckVersionBean> response = await NetImp.fetchNewAPPVersion();
    if (response.isSuccess()) {
      versionBean = response.module;
    }
  }

  void requestAllIn() {
    if (my_page_visible) {
      getABTestData();
    }
    if (my_performance_visible) {
      updatePersonPerformance();
    }
    if (team_performance_visible) {
      updateTeamPerformance();
    }
    if (complete_info_visible) {
      getProgressData();
    }
    if (version_visible) {
      getVersion();
      checkAppVersion();
    }
    getData();
    fetchUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SDPageLifecycler.instance.addObserver(this, context);
  }

  @override
  void onPageShow() {
    super.onPageShow();
    requestAllIn();
  }

  @override
  bool get wantKeepAlive => true;
}
