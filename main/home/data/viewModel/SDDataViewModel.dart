import 'package:fluttercrmmodule/pages/bean/Statistics.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/UrlConstant.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/user/UserHelper.dart';
import 'package:sd_flutter_base/module/user/UserInfo.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

class SDDataViewModel {
  static configDataType2Code(String? dataType) {
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

  /// 点击发起
  static clickCf(Statistics? statistics, String? dataType, String? dayType) {
    UserHelper.getUserInfo().then((userinfo) {
      String url = UrlConstant.URL_STATISTICS_PROVINCIAL_CASES;

      OpenNative.openWebView(url + "?timeType=${dayType}", "");
      Map<String, String> reportParams = Map();
      reportParams["home_time_dimension"] = SDDataViewModel.configDataType2Code(dataType);
      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_GROUP_FAQI, customParams: reportParams);
    });
  }

  /// 点击捐单
  static clickDonate(Statistics? statistics, String? dataType, String? startTime, String? endTime) {
    UserHelper.getUserInfo().then((userinfo) {
      String url = UrlConstant.URL_STATISTICS_REGIONAL_DONATE;
      switch (userinfo?.roleCode) {
        case UserInfo.ROLE_OPERATION:
          url = UrlConstant.URL_STATISTICS_OPERATION_DONATE;
          break;
          break;
        case UserInfo.ROLE_ZONE_MANAGER:
        case UserInfo.ROLE_PROVINCES:
          url = UrlConstant.URL_STATISTICS_ZONE_MANAGER_DONATE;
          break;
        case UserInfo.ROLE_REGIONAL:
          url = UrlConstant.URL_STATISTICS_REGIONAL_DONATE;
          break;
        case UserInfo.ROLE_BIG_REGION:
          url = UrlConstant.URL_STATISTICS_BIG_REGION_DONATE;
          break;
        case UserInfo.ROLE_SUPER:
          url = UrlConstant.URL_STATISTICS_SUPER_DONATE;
          break;
      }
      OpenNative.openWebView("${url}?startTime=${startTime}&endTime=${endTime}", "");

      Map<String, String> reportParams = Map();
      reportParams["home_time_dimension"] = SDDataViewModel.configDataType2Code(dataType);
      SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_GROUP_JD, customParams: reportParams);
    });
  }

  /// 点击团队新增线索
  static clickTeamNewClew(String? dataType) {
    String url = UrlConstant.URL_STATISTICS_TEAM_CLEW;
    OpenNative.openWebView(url + "?timeType=" + (dataType ?? ''), "");

    Map<String, String> reportParams = Map();
    reportParams["home_time_dimension"] = SDDataViewModel.configDataType2Code(dataType);
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_NEW_CLEW, customParams: reportParams);
  }

  /// 点击线下总发起数、捐单数
  static clickOfflineTotalRaise(String? dataType, String? startTime, String? endTime) {
    String url = UrlConstant.URL_STATISTICS_OFFLINE_TOTAL_RAISE;
    OpenNative.openWebView(url + "?startTime=${startTime}&endTime=${endTime}", "");
    Map<String, String> reportParams = Map();
    reportParams["home_time_dimension"] = SDDataViewModel.configDataType2Code(dataType);
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_OFFLINE_TOTAL_RAISE, customParams: reportParams);
  }
}
