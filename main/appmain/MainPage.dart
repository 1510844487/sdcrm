import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/Engine/SDWhaleEngine.dart';
import 'package:fluttercrmmodule/event/IconClickEvent.dart';
import 'package:fluttercrmmodule/event/MessageRefreshEvent.dart';
import 'package:fluttercrmmodule/pages/bean/AppViewModel.dart';
import 'package:fluttercrmmodule/pages/common/AppVersionHelper.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/MainPageConfigConstant.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:fluttercrmmodule/pages/floating_guide/events/GuideEvent.dart';
import 'package:fluttercrmmodule/pages/main/home/CrmHomeWidget.dart';
import 'package:fluttercrmmodule/pages/main/message/MessageWidget.dart';
import 'package:fluttercrmmodule/pages/main/my/MyWidget.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/native2flutter/Native2Flutter.dart';
import 'package:sd_flutter_base/module/native2flutter/bean/NativeMessage.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/permission/PermissionHelper.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

import '../message/index/MessageIndex.dart';
import '../workgroup/WorkGroupWidget.dart';
import 'TabItemWidget.dart';
import 'messageCountHelper/MessageCountHelper.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with SDPageVisibileObserver {
  // 首页
  static const int typeHome = 0;

  // 消息
  static const int typeMessage = 1;

  // 工作台
  static const int typeWorkGroup = 2;

  // 我的
  static const int typeMine = 3;

  // 待录入快接入口
  static const int typeDLRQuick = 5;

  bool isTop = true;

  /// 选中的页面类型
  int choicedPageType = typeHome;
  Widget? homePage, messagePage, workSpacePage, minePage;
  List<Widget> pageList = [];
  PageController? pageController;
  bool showRedNum = false;
  int badgeNum = 0;

  // 是否展示底部快速待录入功能
  bool isShowQuickDlr = false;


  @override
  void initState() {
    super.initState();

    Native2Flutter.init();
    pageController = PageController(keepPage: true);
    // 拉去页面配置数据
    ConfigHelper.fetchConfigData((bool fetchSuccess, List<AppViewModel> appViewModelList) {
      createPage();
    });

    // 注册打开消息模块监听
    Native2Flutter.registeMessageReceiver("open_main_message", openMessageReceiver);

    // 注册打开首页模块监听
    Native2Flutter.registeMessageReceiver("open_main_home", openHomeReceiver);

    eventBus.on<IconClickEvent>().listen((event) {
      if (event.iconId == WorkSpaceConfigConstant.MORE) {
        if (!mounted) return;
        setState(() {
          turnToPage(typeWorkGroup);
        });
      }
    });

    guideEventBus.on<ChangeGuideEvent>().listen((event) {
      if (event.isClose == true) {
        if (!mounted) return;
        setState(() {
          // isShowFloatingGuide = false;
        });
      }
    });
    getUnReadMessageNum();

    ConfigHelper.fetchConfigData((fetchSuccess, appViewModelList) {
      AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.XJDLRKJRK);
      if (!mounted) return;
      setState(() {
        isShowQuickDlr = appViewModel != null && appViewModel.visible;
      });
    });

    OpenNative.noticeHomeLoad();
    OpenNative.checkLocationService();
    OpenNative.reportLocationService("shouye");
    AppVersionHelper.checkAppVersion(context);
    reportCode(ElementCode.CODE_HOME);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听页面生命周期
    SDPageLifecycler.instance.addObserver(this, context);
  }
  
  @override
  void dispose() {
    // 移除页面生命周期
    SDPageLifecycler.instance.removeObserver(this);
    super.dispose();
    pageController?.dispose();
    Native2Flutter.unRegisteMessageReceiver("openMessageReceiver", openMessageReceiver);
    Native2Flutter.unRegisteMessageReceiver("open_main_home", openHomeReceiver);
  }


  @override
  void onPageShow() {
    // 监听页面前台可见刷新未读消息数
    getUnReadMessageNum();
  }

  @override
  void onForeground() {
    // 监听APP前台展示刷新未读消息数
    getUnReadMessageNum();
  }

  openMessageReceiver(NativeMessage message) {
    if (isTop) {
      // readChangeBadgeNum();
      messageRefreshEventBus.fire(MessageRefreshEvent());
      if (!mounted) return;
      setState(() {
        turnToPage(typeMessage);
      });
    } else {
      OpenNative.openMsgView("");
    }
  }

  openHomeReceiver(NativeMessage message) {
    getUnReadMessageNum();
    if (!mounted) return;
    setState(() {
      turnToPage(typeHome);
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    bool isBack = ModalRoute.of(context)?.isCurrent ?? false;
    if (isBack) {
      isTop = true;
    } else {
      isTop = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    itemBuilder: (context, position) {
                      if (position < 0 || position >= pageList.length) {
                        return Container();
                      }
                      return pageList[position];
                    },
                    controller: pageController,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      getTabWidget(typeHome),
                      getTabWidget(typeMessage),
                      getTabWidget(typeDLRQuick),
                      getTabWidget(typeWorkGroup),
                      getTabWidget(typeMine),
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil.getBottomBarH(context),
                  color: Colors.white,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 生成页面
  createPage() {
    AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.HOME);
    if (appViewModel != null && appViewModel.visible) {
      if (homePage == null) {
        homePage = CrmHomeWidge();
      }
      pageList.add(homePage!);
    }

    // 消息
    appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.MESSAGE);
    if (appViewModel != null && appViewModel.visible) {
      if (messagePage == null) {
        messagePage = MessageIndexWidget();
      }
      pageList.add(messagePage!);
    }

    // 工作台
    appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.WORKSPACE);
    if (appViewModel != null && appViewModel.visible) {
      if (workSpacePage == null) {
        workSpacePage = WorkGroupWidget();
      }
      pageList.add(workSpacePage!);
    }

    // 我的
    appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.MINE);
    if (appViewModel != null && appViewModel.visible) {
      if (minePage == null) {
        minePage = MyWidget(title: '我的',);
      }
      pageList.add(minePage!);
    }
    if(mounted){
      setState(() {});
    }
  }

  /// 获取tab widget
  getTabWidget(int type) {
    switch (type) {
      case typeHome:
        AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.HOME);
        if (appViewModel == null || !appViewModel.visible) {
          break;
        }
        return Expanded(
          child: TabItemWidget(
            title: "首页",
            isChoice: choicedPageType == typeHome,
            titleChoiceColor: Color(0xFF0071FE),
            titleDefaultColor: Color(0xFFB1B1B1),
            iconDefault: "images/crm_main_home_default.png",
            iconChoiced: "images/crm_main_home.png",
            clickCallback: () {
              SDWhaleEngine().selectPageName = "home";
              getUnReadMessageNum();
              if (mounted) {
                setState(() {
                  turnToPage(typeHome);
                });
              }
              OpenNative.checkLocationService();
              OpenNative.reportLocationService("shouye");
              AppVersionHelper.checkAppVersion(context);
              reportCode(ElementCode.CODE_HOME);
            },
          ),
        );
      case typeMessage:
        AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.MESSAGE);
        if (appViewModel == null || !appViewModel.visible) {
          break;
        }
        return Expanded(
            child: Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            TabItemWidget(
              title: "消息",
              isChoice: choicedPageType == typeMessage,
              titleChoiceColor: Color(0xFF0071FE),
              titleDefaultColor: Color(0xFFB1B1B1),
              iconDefault: "images/crm_main_message_default.png",
              iconChoiced: "images/crm_main_message.png",
              clickCallback: () {
                SDWhaleEngine().selectPageName = "message";
                // readChangeBadgeNum();
                if (mounted) {
                  setState(() {
                    turnToPage(typeMessage);
                  });
                }
                AppVersionHelper.checkAppVersion(context);
                reportCode(ElementCode.CODE_MESSAGE);
                OpenNative.reportLocationService("xiaoxi");
              },
            ),
            (badgeNum ?? 0) > 0
                ? Positioned(
                    top: 5,
                    right: isShowQuickDlr ? 15 : 25,
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(minHeight: 20, maxHeight: 20, minWidth: 20),
                      padding: EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Text(
                        badgeNum >= 100 ? "99+" : badgeNum.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  )
                : Container(),
          ]),
        ));
      case typeWorkGroup:
        AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.WORKSPACE);
        if (appViewModel == null || !appViewModel.visible) {
          break;
        }
        return Expanded(
          child: TabItemWidget(
            title: "工作台",
            isChoice: choicedPageType == typeWorkGroup,
            titleChoiceColor: Color(0xFF0071FE),
            titleDefaultColor: Color(0xFFB1B1B1),
            iconDefault: "images/crm_main_workgroup_default.png",
            iconChoiced: "images/crm_main_workgroup.png",
            clickCallback: () async {
              SDWhaleEngine().selectPageName = "workGroup";
              getUnReadMessageNum();
              if (mounted) {
                setState(() {
                  turnToPage(typeWorkGroup);
                });
              }
              AppVersionHelper.checkAppVersion(context);
              reportCode(ElementCode.CODE_WORK_GROUP);
            },
          ),
        );
      case typeMine:
        AppViewModel appViewModel = ConfigHelper.getAppViewModel(MainPageConfigConstant.MINE);
        if (appViewModel == null || !appViewModel.visible) {
          break;
        }
        return Expanded(
          child: TabItemWidget(
            title: "我的",
            isChoice: choicedPageType == typeMine,
            titleChoiceColor: Color(0xFF0071FE),
            titleDefaultColor: Color(0xFFB1B1B1),
            iconDefault: "images/crm_main_mine_default.png",
            iconChoiced: "images/crm_main_mine.png",
            clickCallback: () {
              SDWhaleEngine().selectPageName = "my";
              getUnReadMessageNum();
              if (mounted) {
                setState(() {
                  turnToPage(typeMine);
                });
              }
              AppVersionHelper.checkAppVersion(context);
              OpenNative.reportLocationService("wode");
            },
          ),
        );
      case typeDLRQuick:
        return isShowQuickDlr
            ? Expanded(
                child: InkWell(
                  onTap: () async {
                    SDWhaleEngine().selectPageName = "luru";
                    // 打开待录入
                    bool? permissionList = await PermissionHelper.checkSinglePermission(PermissionHelper.permission_record_audio);
                    if (Platform.isIOS || (permissionList != null && permissionList)) {
                      OpenNative.openWebView("https://www.shuidichou.com/bd/report/creat?fromHomePage=1", "");
                    } else {
                      ToastHelper.showLongCenter("需要打开录音权限，请打开录音权限");
                      PermissionHelper.toPermissionSetting();
                    }

                    AppVersionHelper.checkAppVersion(context);
                    reportCode(ElementCode.CODE_CREAT_FOR_ENTRY);
                  },
                  child: Image.asset(
                    "images/crm_main_new_clew.png",
                    width: 44,
                    height: 44,
                  ),
                ),
              )
            : Container();
    }
    return Container();
  }

  /// 开启对应tab页面
  turnToPage(int type) {
    switch (type) {
      case typeHome:
        int position = pageList.indexOf(homePage ?? Container());
        if (position > -1) {
          choicedPageType = typeHome;
          pageController?.jumpToPage(position);
        }
        break;
      case typeMessage:
        int position = pageList.indexOf(messagePage ?? Container());
        if (position > -1) {
          choicedPageType = typeMessage;
          pageController?.jumpToPage(position);
        }
        break;
      case typeWorkGroup:
        int position = pageList.indexOf(workSpacePage ?? Container());
        if (position > -1) {
          choicedPageType = typeWorkGroup;
          pageController?.jumpToPage(position);
        }
        break;
      case typeMine:
        int position = pageList.indexOf(minePage ?? Container());
        if (position > -1) {
          choicedPageType = typeMine;
          pageController?.jumpToPage(position);
        }
        break;
    }
    if(mounted){
      setState(() {});
    }
  }

  static Future<void> reportCode(String code) async {
    //埋点上报
    Map<String, String> reportParams = await Tools.buildCommonParams();
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, code, customParams: reportParams);
  }

  /// 获取维度消息数
  getUnReadMessageNum() async {
    int count = await MessageCountHelper.requestUnReadMessageCount();
    if (count < 0) {
      return;
    }
    if (!mounted) return;
    setState(() {
      badgeNum = count;
    });
  }

  /// 设置维度消息都未已读
  readChangeBadgeNum() async {
    bool count = await MessageCountHelper.requestReadedAllMessage();
    if (!mounted) return;
    setState(() {
      if (count != null && count) {
        badgeNum = 0;
      }
    });
  }
}
