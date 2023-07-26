import 'package:date_format/date_format.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/data/net/SDNetInterface.dart';
import 'package:fluttercrmmodule/data/net/SDNetProvider.dart';
import 'package:fluttercrmmodule/pages/bean/BacklogListBean.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignHospitalAreaDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignMemberDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignOrgDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/CfBdcrmOfficialAnnounceVO.dart';
import 'package:fluttercrmmodule/pages/bean/CheckTotalNumberOfCustomersBean.dart';
import 'package:fluttercrmmodule/pages/bean/CrmBdHomePageStatistics.dart';
import 'package:fluttercrmmodule/pages/bean/CurrentWeekObjective.dart';
import 'package:fluttercrmmodule/pages/bean/ObjectiveOrg.dart';
import 'package:fluttercrmmodule/pages/bean/OrgList.dart';
import 'package:fluttercrmmodule/pages/bean/Statistics.dart';
import 'package:fluttercrmmodule/pages/bean/TodayBdStaticsData.dart';
import 'package:fluttercrmmodule/pages/bean/TrendModel.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconConstant.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserHelper.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/HomeConfigConstant.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';

class HomeViewModel {
  /// 今日趋势图
  static Future<List<TrendModel>?> getTodayTrend(int? orgId) async {
    SDResponse<List<TrendModel>> response = await NetImp.fetchTodayTrendData(orgId);
    if (response.isSuccess()) {
      return response.module;
    } else {
      return [];
    }
  }

  /// 今日团队数据
  static Future<TodayBdStaticsData?> getTodayBdStatistics(int? orgId) async {
    //SDResponse<TodayBdStaticsData> responseStaticsData = await NetImp.fetchTodayBdStatisticsData(orgId);
    SDNetResult<TodayBdStaticsData?> result = await SDNetInterface.fetchTodayBdStatisticsData(orgId);
    if (result.isSuccess()) {
      return result.module;
    } else {
      return null;
    }
  }

  /// 今日团队数据 - 业务经理组织数据
  static Future<List<CampaignMemberDetailModel>?> getListSubMemberTodayData(int? orgId) async {
    SDResponse<List<CampaignMemberDetailModel>> responseMemberDetail = await NetImp.fetchListSubMemberTodayData(orgId);
    if (responseMemberDetail.isSuccess()) {
      return responseMemberDetail.module;
    } else {
      return [];
    }
  }

  /// 今日团队数据 - 非业务经理组织数据
  static Future<List<CampaignOrgDetailModel>> getlistSubOrgTodayData(int? orgId) async {
    //SDResponse<List<CampaignOrgDetailModel>> responseOrgDetail = await NetImp.fetchListSubOrgTodayData(orgId);
    SDNetResult<List<CampaignOrgDetailModel>> result = await SDNetInterface.fetchListSubOrgTodayData(orgId);
    if (result.isSuccess()) {
      return result.module ?? [];
    } else {
      return [];
    }
  }

  /// 今日医院数据
  static Future<List<CampaignHospitalAreaDetailModel>?> getLeaderHospitalTodayData(int? orgId, List<int> cityIds) async {
    SDResponse<List<CampaignHospitalAreaDetailModel>> responseHospitalAreaDetail = await NetImp.fetchLeaderHospitalTodayData(orgId, cityIds);
    if (responseHospitalAreaDetail.isSuccess()) {
      return responseHospitalAreaDetail.module;
    } else {
      return [];
    }
  }

  /// 获取今日医院城市数据
  static Future<List<OrgList>?> getCityList(int? orgId) async {
    SDResponse<List<OrgList>> response = await NetImp.fetchListCityData(orgId);
    if (response.isSuccess()) {
      return response.module;
    } else {
      return [];
    }
  }

  static Future<List<ObjectiveOrg>?> getOrgListData() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();

    bool canShow = userInfo != null &&
        userInfo.roleCode != SDUserInfo.ROLE_PROVINCIAL_GR &&
        userInfo.roleCode != SDUserInfo.ROLE_NORMAL_GR &&
        userInfo.roleCode != SDUserInfo.ROLE_PART_TIME &&
        userInfo.roleCode != SDUserInfo.ROLE_ASSISTANT &&
        userInfo.roleCode != SDUserInfo.ROLE_AGENT_MEMBER &&
        userInfo.roleCode != SDUserInfo.ROLE_BD;

    if (canShow) {
      SDResponse<int> response = await NetImp.checkShowObjectiveManage();
      if (response.isSuccess()) {
        SDResponse<List<ObjectiveOrg>> response = await NetImp.objectiveGetOrgList();
        if (response.isSuccess()) {
          List<ObjectiveOrg>? orgList = response.module;
          return orgList;
        } else {
          // ignore: deprecated_member_use
          return <ObjectiveOrg>[];
        }
      } else {
        // ignore: deprecated_member_use
        return <ObjectiveOrg>[];
      }
    } else {
      // ignore: deprecated_member_use
      return <ObjectiveOrg>[];
    }
  }

  static Future<CrmBdHomePageStatistics?> getBdData() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();

    if (userInfo?.roleCode == SDUserInfo.ROLE_BD ||
        userInfo?.roleCode == SDUserInfo.ROLE_PART_TIME ||
        userInfo?.roleCode == SDUserInfo.ROLE_ASSISTANT ||
        userInfo?.roleCode == SDUserInfo.ROLE_AGENT_MEMBER) {
      SDResponse<CrmBdHomePageStatistics> response = await NetImp.getBdStatisticsV2();
      if (response.isSuccess()) {
        CrmBdHomePageStatistics? homePageStatistics = response.module;
        return homePageStatistics;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<Statistics?> getNewLeaderData() async {
    final String data_day = Tools.DAY_0.toString();
    final String data_week = Tools.DAY_7.toString();
    final String data_month = Tools.DAY_30.toString();

    String? dayType;
    String? startTime, endTime;

    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();

    if (userInfo?.roleCode == SDUserInfo.ROLE_BUSINESS ||
        userInfo?.roleCode == SDUserInfo.ROLE_ZONE_MANAGER ||
        userInfo?.roleCode == SDUserInfo.ROLE_PROVINCES ||
        userInfo?.roleCode == SDUserInfo.ROLE_ADVANCED_CHANNEL ||
        userInfo?.roleCode == SDUserInfo.ROLE_REGIONAL ||
        userInfo?.roleCode == SDUserInfo.ROLE_CHANNEL_REGIONAL ||
        userInfo?.roleCode == SDUserInfo.ROLE_BIG_REGION ||
        userInfo?.roleCode == SDUserInfo.ROLE_SUPER ||
        userInfo?.roleCode == SDUserInfo.ROLE_OPERATION) {
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
        Statistics? statistics = response.module;
        return statistics;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  // ignore: missing_return
  static Future<List<BacklogBean>?> getTodoData() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    if (userInfo != null &&
        userInfo.roleCode != SDUserInfo.ROLE_SUPER &&
        userInfo.roleCode != SDUserInfo.ROLE_OPERATION &&
        userInfo.roleCode != SDUserInfo.ROLE_BD &&
        userInfo.roleCode != SDUserInfo.ROLE_ASSISTANT &&
        userInfo.roleCode != SDUserInfo.ROLE_AGENT_MEMBER &&
        userInfo.roleCode != SDUserInfo.ROLE_PART_TIME &&
        userInfo.roleCode != SDUserInfo.ROLE_NORMAL_GR &&
        userInfo.roleCode != SDUserInfo.ROLE_PROVINCIAL_GR) {
      SDResponse<List<BacklogBean>> response = await NetImp.getBacklogListSync(userInfo.wxToken);
      if (response != null && response.isSuccess()) {
        List<BacklogBean>? backlogList = response.module;
        return backlogList;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<List<CfBdcrmOfficialAnnounceVO>?> getTipsData() async {
    SDResponse<List<CfBdcrmOfficialAnnounceVO>> response = await NetImp.homePageScroll();
    if (response.isSuccess()) {
      List<CfBdcrmOfficialAnnounceVO> dataList = [];
      for (int p = 0; p < 50; p++) {
        dataList.addAll(response.module ?? []);
      }
      return dataList;
    } else {
      return null;
    }
  }

  static Future<CurrentWeekObjective?> getTargetData() async {
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
    bool canShow = userInfo != null && userInfo!.roleCode != SDUserInfo.ROLE_PROVINCIAL_GR && userInfo!.roleCode != SDUserInfo.ROLE_NORMAL_GR;
    if (canShow) {
      SDResponse<int> response = await NetImp.checkShowObjectiveManage();
      if (response.isSuccess()) {
        SDUserInfo? userInfo = await SDUserHelper.getUserInfo();
        if (userInfo?.roleCode == SDUserInfo.ROLE_BD ||
            userInfo?.roleCode == SDUserInfo.ROLE_PART_TIME ||
            userInfo?.roleCode == SDUserInfo.ROLE_ASSISTANT ||
            userInfo?.roleCode == SDUserInfo.ROLE_AGENT_MEMBER) {
          CurrentWeekObjective? objective = await getObjectiveDetail(null);
          return objective;
        } else {
          SDResponse<List<ObjectiveOrg>> response = await NetImp.objectiveGetOrgList();
          if (response.isSuccess()) {
            String? orgId;
            List<ObjectiveOrg>? orgList = response.module;
            if (orgList != null && orgList.length > 0) {
              ObjectiveOrg choicedOrg = orgList[0];
              orgId = choicedOrg.uniqueKey;
            }
            CurrentWeekObjective? objective = await getObjectiveDetail(orgId);
            return objective;
          } else {
            return null;
          }
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<CurrentWeekObjective?> getObjectiveDetail(String? orgId) async {
    SDResponse<CurrentWeekObjective> response = await NetImp.getCurrentWeekObjective(orgId, "2");
    if (response.isSuccess()) {
      CurrentWeekObjective? currentWeekObjective = response.module;
      return currentWeekObjective;
    } else {
      return null;
    }
  }

  static Future<List<AppIconModelList>?> getKingKongSeniorData() async {
    SDResponse<List<AppIconModelList>> response = await NetImp.homePageIconList();

    List<AppIconModelList>? iconList;
    if (response.isSuccess()) {
      iconList = response.module;
      if (iconList == null) {
        iconList = [];
      }
      iconList.add(AppIconModelList(iconDesc: "更多", newModule: false, iconCode: WorkSpaceConfigConstant.MORE));
    } else {
      iconList = [];
      iconList.add(AppIconModelList(iconDesc: "更多", newModule: false, iconCode: WorkSpaceConfigConstant.MORE));
    }

    iconList.removeWhere((element) => !IconConstant.canVisiable(element.id, ConfigHelper.getAppViewModel(HomeConfigConstant.JGW)));
    iconList.forEach((element) {
      IconConstant.setUrl(element);
    });

    return iconList;
  }

  static Future<CheckTotalNumberOfCustomersBean?> getCustomersCountData() async {
    CheckTotalNumberOfCustomersBean? info;
    SDUserInfo? userInfo = await SDUserHelper.getUserInfo();

    bool canShow = userInfo != null && (userInfo.roleCode == SDUserInfo.ROLE_PROVINCIAL_GR || userInfo.roleCode == SDUserInfo.ROLE_NORMAL_GR);
    if (canShow) {
      SDResponse<CheckTotalNumberOfCustomersBean> response = await NetImp.fetchTotalNumberOfCustomers();
      if (response.isSuccess()) {
        info = response.module;
      } else {
        info = null;
      }
    } else {
      info = null;
    }
    return info;
  }
}
