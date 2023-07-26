import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';

enum MyIconType {
  myinfo,
  performance,
  teamPerformance,
  appversion,
}

class MyViewModel {
  static Future<bool> getEditSelfInfo() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    switch (userInfo?.roleCode) {
      case SDUserInfo.ROLE_REGIONAL: //区域经理
      case SDUserInfo.ROLE_CHANNEL_REGIONAL: //区域经理
        return false;
      case SDUserInfo.ROLE_BUSINESS: //省级经理 == 业务经理
      case SDUserInfo.ROLE_CHANNEL: //省级经理 == 业务经理
      case SDUserInfo.ROLE_AGENT_LEADER:
      case SDUserInfo.ROLE_AGENT_BOOS:
      case SDUserInfo.ROLE_ADVANCED_CHANNEL: //省级经理 == 业务经理
        return true;
      case SDUserInfo.ROLE_BD: //筹款顾问
      case SDUserInfo.ROLE_PART_TIME: //筹款顾问
      case SDUserInfo.ROLE_ASSISTANT: //筹款顾问
      case SDUserInfo.ROLE_AGENT_MEMBER: //筹款顾问
        return false;
      case SDUserInfo.ROLE_OPERATION: //运营人员 ？老逻辑
        return false;
      case SDUserInfo.ROLE_SUPER: //超级管理员 不用编辑
        return false;
      case SDUserInfo.ROLE_ZONE_MANAGER: //分区经理
      case SDUserInfo.ROLE_PROVINCES: //省区经理
        return true;
      case SDUserInfo.ROLE_BIG_REGION: //大区经理 不用编辑
        return false;
    }
    return true;
  }

  ///获取编辑个人信息类型，有无编辑进度
  static Future<bool> getEditSelfInfoType() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();

    if (userInfo != null &&
        userInfo.roleCode != null &&
        (userInfo.roleCode == SDUserInfo.ROLE_BD ||
            userInfo.roleCode == SDUserInfo.ROLE_PART_TIME ||
            userInfo.roleCode == SDUserInfo.ROLE_ASSISTANT ||
            userInfo.roleCode == SDUserInfo.ROLE_AGENT_MEMBER)) {
      return true;
    }
    return false;
  }

  static String getPhoneNumberInfo(String? telephone) {
    if (telephone == null) return "";

    if (telephone.length != 11) {
      return telephone;
    }

    return telephone.replaceRange(3, 7, '*' * 4);
  }

  static String getIconImage(MyIconType type) {
    switch (type) {
      case MyIconType.myinfo:
        return icon_myinfo;
      case MyIconType.performance:
        return icon_performance;
      case MyIconType.teamPerformance:
        return icon_team_performance;
      case MyIconType.appversion:
        return icon_appversion;
    }
  }

  static String getNameItem(MyIconType type) {
    switch (type) {
      case MyIconType.myinfo:
        return name_myinfo;
      case MyIconType.performance:
        return name_performance;
      case MyIconType.teamPerformance:
        return name_team_performance;
      case MyIconType.appversion:
        return name_appversion;
    }
  }

  /**
   * 顾问	个人资料、我的绩效、当前版本
      省级经理	 我的绩效、团队绩效、当前版本
      分区经理	我的绩效、团队绩效、当前版本
      区域经理	我的绩效、团队绩效考核、当前版本
      大区经理	团队绩效、当前版本
      运营	当前版本
      超管	当前版本
   */
  static Future<List<MyIconType>> getListType() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    switch (userInfo?.roleCode) {
      case SDUserInfo.ROLE_REGIONAL: //区域经理
      case SDUserInfo.ROLE_CHANNEL_REGIONAL: //区域经理
      case SDUserInfo.ROLE_ZONE_MANAGER: //分区经理
      case SDUserInfo.ROLE_PROVINCES: //省区经理
        return [MyIconType.performance, MyIconType.teamPerformance, MyIconType.appversion];
      case SDUserInfo.ROLE_BUSINESS: //业务经理
      case SDUserInfo.ROLE_CHANNEL: //业务经理
      case SDUserInfo.ROLE_AGENT_LEADER:
      case SDUserInfo.ROLE_AGENT_BOOS:
        return [MyIconType.myinfo, MyIconType.performance, MyIconType.teamPerformance, MyIconType.appversion];
      case SDUserInfo.ROLE_ADVANCED_CHANNEL: //省级经理
        return [MyIconType.performance, MyIconType.teamPerformance, MyIconType.appversion];
      case SDUserInfo.ROLE_BD: //筹款顾问
        if (userInfo?.partnerTag == 1) {
          return [MyIconType.appversion];
        }
        return [MyIconType.myinfo, MyIconType.performance, MyIconType.appversion];
      case SDUserInfo.ROLE_PART_TIME: //筹款顾问
        return [MyIconType.appversion];
      case SDUserInfo.ROLE_ASSISTANT: //筹款顾问
      case SDUserInfo.ROLE_AGENT_MEMBER: //筹款顾问
        if (userInfo?.partnerTag == 1) {
          return [MyIconType.appversion];
        }
        return [MyIconType.myinfo, MyIconType.performance, MyIconType.appversion];
      case SDUserInfo.ROLE_OPERATION: //运营人员 ？老逻辑
        return [MyIconType.appversion];
      case SDUserInfo.ROLE_SUPER: //超级管理员 不用编辑
        return [MyIconType.appversion];
      case SDUserInfo.ROLE_BIG_REGION: //大区经理 不用编辑
        return [MyIconType.teamPerformance, MyIconType.appversion];
      case SDUserInfo.ROLE_PROVINCIAL_GR: //GR省级经理 不用编辑
        return [MyIconType.appversion];
      case SDUserInfo.ROLE_NORMAL_GR: //GR 不用编辑
        return [MyIconType.appversion];
    }
    return [MyIconType.appversion];
  }

  static const String icon_myinfo = "images/my_myinfo.png";
  static const String icon_performance = "images/my_wodejixiao.png";
  static const String icon_team_performance = "images/my_tunduijixiao.png";
  static const String icon_appversion = "images/my_dangqianbanben.png";
  static const String name_myinfo = "个人主页";
  static const String name_performance = "我的绩效";
  static const String name_team_performance = "团队绩效";
  static const String name_appversion = "当前版本";
  static const int TAG_PART_TIME = 1; //兼职顾问标识 0:普通顾问,1:兼职顾问

  static void requestClickKPI() {
    NetImp.fetchClickMyKPI();
  }
}
