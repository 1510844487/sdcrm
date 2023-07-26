import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/CheckTotalNumberOfCustomersBean.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/user/UserHelper.dart';
import 'package:sd_flutter_base/module/user/UserInfo.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

//GR客户数、初始化数
String provinceCustomerNumberlink = "https://www.shuidichou.com/bd/customer/list?selectOrgStatus=1";
String consultanCustomerNumbertlink = "https://www.shuidichou.com/bd/customer/list";

String provinceInitlink = "https://www.shuidichou.com/bd/customer/list?selectOrgStatus=1&selectStatus=0";
String consultantInitlink = "https://www.shuidichou.com/bd/customer/list?selectStatus=0";

class CustomersCountWidget extends StatefulWidget {
  CheckTotalNumberOfCustomersBean? info;

  CustomersCountWidget({this.info});

  @override
  State<StatefulWidget> createState() {
    return _CustomersCountWidgetState();
  }
}

class _CustomersCountWidgetState extends State<CustomersCountWidget> {
  bool canShow = false;
  UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    String customerNumber = (widget.info == null) ? '0' : '${widget.info!.customerNum}';
    String initNumber = (widget.info == null) ? '0' : '${widget.info!.initNum}';

    if (userInfo == null) {
      return Container();
    }

    return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: canShow
                ? Container(
                    child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                tapCustomerNumberLink();
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
                                      child: Container(
                                          // padding: EdgeInsets.only(left: 16),
                                          child: const Text("客户数",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold))))))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                tapInitializeLink();
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
                                      child: Container(
                                          // padding: EdgeInsets.only(left: 16),
                                          child: const Text("初始化",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)))))))
                    ]),
                    Row(children: <Widget>[
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                tapCustomerNumberLink();
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
                                      child: Container(
                                          // padding: EdgeInsets.only(left: 16),
                                          child: Text(customerNumber,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.bold))))))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                tapInitializeLink();
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
                                      child: Container(
                                          // padding: EdgeInsets.only(left: 16),
                                          child: Row(
                                        children: <Widget>[
                                          Text(initNumber,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(0xFF333333), fontSize: 21, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 4),
                                          const Text("待初步沟通",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(0xFF999999),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal))
                                        ],
                                      ))))))
                    ])
                  ]))
                : Container()));
  }

  tapCustomerNumberLink() {
    if (userInfo?.roleCode == UserInfo.ROLE_PROVINCIAL_GR) {
      OpenNative.openWebView(provinceCustomerNumberlink, "");
    } else if (userInfo?.roleCode == UserInfo.ROLE_NORMAL_GR) {
      OpenNative.openWebView(consultanCustomerNumbertlink, "");
    }
  }

  tapInitializeLink() async {
    if (userInfo?.roleCode == UserInfo.ROLE_PROVINCIAL_GR) {
      OpenNative.openWebView(provinceInitlink, "");
    } else if (userInfo?.roleCode == UserInfo.ROLE_NORMAL_GR) {
      OpenNative.openWebView(consultantInitlink, "");
    }

    Map<String, String> reportParams = await Tools.buildCommonParams();
    reportParams["pagename"] = "homePage";
    reportParams["channel"] = "count";
    SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_KEHUGUANLI, customParams: reportParams);
  }

  initData() async {
    userInfo = await UserHelper.getUserInfo();

    if(userInfo == null){
      return;
    }

    canShow = userInfo?.roleCode == UserInfo.ROLE_PROVINCIAL_GR || userInfo?.roleCode == UserInfo.ROLE_NORMAL_GR;

    if (canShow) {
      SDResponse<CheckTotalNumberOfCustomersBean> response = await NetImp.fetchTotalNumberOfCustomers();
      if (response.isSuccess()) {
        widget.info = response.module;
        if (mounted) {
          setState(() {});
        }
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    } else {}
  }
}
