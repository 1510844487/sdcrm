import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconConstant.dart';
import 'package:fluttercrmmodule/pages/config/ConfigHelper.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/workgroup/views/WKGridWidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sd_flutter_base/module/base/SimplePage.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';
import 'package:sd_flutter_base/widgets/SdRefreshWidget.dart';

class WorkGroupWidget extends StatefulWidget {
  const WorkGroupWidget({super.key});

  @override
  _WorkGroupWidgetState createState() => _WorkGroupWidgetState();
}

class _WorkGroupWidgetState extends State<WorkGroupWidget> with AutomaticKeepAliveClientMixin {
  List<WorkGroupBean> infoArray = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    requestData();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SimplePage(
      Container(
        color: Color(0xFFF2F2F2),
        child: SdRefreshWidget(
          refreshController,
          enablePullUp: false,
          enablePullDown: true,
          onRefresh: () {
            requestData();
          },
          onLoadmore: () {},
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Material(
              color: Color(0xFFF2F2F2),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                  child: infoArray.isNotEmpty ? Column(children: getGroupWidgets()) : Container(),
                ),
              ),
            ),
          ),
        ),
      ),
      actionBarCentTitle: "工作台",
      showLoading: false,
      backgroundColor: Color(0xFFF2F2F2),
      actionbarBgColor: Color(0xFFF2F2F2),
      actionBarLeftShow: false,
      clickActionBarLeftWidgetEvent: () {},
    );
  }

  List<Widget> getGroupWidgets() {
    var list = <Widget>[];
    var newArray = <WorkGroupBean>[];
    for (int i = 0; i < infoArray.length; i++) {
      if (infoArray[i].appIconModelList.isEmpty) {
        continue;
      }
      newArray.add(infoArray[i]);
    }

    for (int j = 0; j < newArray.length; j++) {
      list.add(workUnit(newArray[j]));
      list.add(SizedBox(height: 10));
    }
    return list;
  }

  Widget workUnit(WorkGroupBean groupBean) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0),
          child: Text(
            groupBean.workBenchDesc,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
          ),
        ),
        WKGridWidget(
          data: groupBean.appIconModelList,
        ),
      ],
    );
  }

  void requestData() async {
    ConfigHelper.fetchConfigData(
      (fetchSuccess, appViewModelList) {
        if (fetchSuccess) {
          NetImp.fetchWorkGroupDataList().then((response) {
            if (refreshController.isRefresh) {
              refreshController.refreshCompleted(resetFooterState: true);
            }
            if (response.isSuccess()) {
              List<WorkGroupBean>? list = response.module;
              if (list != null && list.length > 0) {
                for (WorkGroupBean workGroupBean in list) {
                  if (workGroupBean.appIconModelList != null) {
                    workGroupBean.appIconModelList.removeWhere((element) {
                      return !IconConstant.canVisiable(element.id, ConfigHelper.getAppViewModel(WorkSpaceConfigConstant.GROUP_ID));
                    });
                    workGroupBean.appIconModelList.forEach((element) {
                      IconConstant.setUrl(element);
                    });
                  }
                }
              }
              infoArray = list ?? [];
              if (mounted) {
                setState(() {});
              }
            }
          });
        } else {
          ToastHelper.showShortCenter("数据获取失败，请刷新下试试");
          if (refreshController.isRefresh) {
            refreshController.refreshCompleted(resetFooterState: true);
          }
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
