import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';

class IconTipsHelper {
  /// 获取 icon tips 数据
  static void fetchIconTipsData(List<AppIconModelList>? iconList) {
    if (iconList == null || iconList.length <= 0) {
      return;
    }

    for (AppIconModelList iconModelList in iconList) {
      if (iconModelList.iconCode == WorkSpaceConfigConstant.KF) {
        NetImp.offlineMsgCheck().then((response) {
          if (response.isSuccess()) {
            OpenNative.updataBadge(response.module ?? 0);
            _notify(IconTips<int>(iconModelList.iconCode, response.module ?? 0));
          }
        });
        continue;
      } else if (iconModelList.iconCode == WorkSpaceConfigConstant.GX) {
        NetImp.offlineAnnounceGetUnReadNum().then((response) {
          if (response.isSuccess()) {
            _notify(IconTips<int>(iconModelList.iconCode, response.module ?? 0));
          }
        });
        continue;
      } else if (iconModelList.iconCode == WorkSpaceConfigConstant.WQK) {
        NetImp.queryWeaponStatus().then((response) {
          if (response.isSuccess()) {
            _notify(IconTips<bool>(iconModelList.iconCode, response.module ?? false));
          }
        });
        continue;
      } else if (iconModelList.iconCode == WorkSpaceConfigConstant.YXHB) {
        NetImp.marketingPosterGetNewStatus().then((response) {
          if (response.isSuccess()) {
            _notify(IconTips<int>(iconModelList.iconCode, response.module ?? 0));
          }
        });
        continue;
      } else if (iconModelList.iconCode == WorkSpaceConfigConstant.ALYY) {
        NetImp.getNeedTaskCount().then((response) {
          if (response.isSuccess()) {
            _notify(IconTips<int>(iconModelList.iconCode, response.module ?? 0));
          }
        });
        continue;
      } else if (iconModelList.iconCode == WorkSpaceConfigConstant.DB) {
        /// 待办tips
        NetImp.getDBTaskCount().then((response) {
          if (response.isSuccess()) {
            _notify(IconTips<int>(iconModelList.iconCode, response.module ?? 0));
          }
        });
      }
    }
  }

  static List<ValueChanged<IconTips>> tipsListenerList = [];

  static void registTipsListener(ValueChanged<IconTips> listener) {
    tipsListenerList.add(listener);
  }

  static void unRegistTipsListener(ValueChanged<IconTips> listener) {
    tipsListenerList.remove(listener);
  }

  static _notify(IconTips iconTips) {
    for (ValueChanged<IconTips> listener in tipsListenerList) {
      listener(iconTips);
    }
  }
}

class IconTips<T> {
  String iconId;
  T data;

  IconTips(this.iconId, this.data);
}
