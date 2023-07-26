import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/CrmBdHomePageStatistics.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/UrlConstant.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';


import 'package:sd_flutter_buriedpoint/SDBuried.dart';

/// BD 数据控件
class BdDataWidget extends StatefulWidget {

  CrmBdHomePageStatistics? homePageStatistics;


  BdDataWidget(this.homePageStatistics);

  @override
  State<StatefulWidget> createState() {
    return _BdDataWidgetState();
  }
}

class _BdDataWidgetState extends State<BdDataWidget> {
  @override
  void initState() {
    super.initState();
  }

  configDataType2Code(String dataType) {
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

  @override
  Widget build(BuildContext context) {
    return widget.homePageStatistics == null
        ? Container()
        : Row(
            children: <Widget>[
              Expanded(
                flex: 246,
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 4, top: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white),
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "发起案例",
                        style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: DataItemWidget(
                              title: "今日",
                              number: Tools.formatHomeData(
                                  widget.homePageStatistics!.dayCaseNum),
                              clickListener: () {
                                OpenNative.openWebView(
                                    Tools.makeHomeDataUrl(
                                        UrlConstant.URL_STATISTICS_BD_CASES,
                                        Tools.DAY_0),
                                    "");

                                Map<String, String> reportParams = Map();
                                reportParams["home_time_dimension"] =
                                    configDataType2Code(Tools.DAY_0.toString());
                                SDBuried.instance().reportImmediately(SDBuriedEvent.click,
                                    ElementCode.CODE_HOME_STATICS_CASE,
                                    customParams: reportParams);
                              },
                            )),
                            Expanded(
                              child: DataItemWidget(
                                title: "7日",
                                number: Tools.formatHomeData(
                                    widget.homePageStatistics!.weekCaseNum),
                                clickListener: () {
                                  OpenNative.openWebView(
                                      Tools.makeHomeDataUrl(
                                          UrlConstant.URL_STATISTICS_BD_CASES,
                                          Tools.DAY_7),
                                      "");

                                  Map<String, String> reportParams = Map();
                                  reportParams["home_time_dimension"] =
                                      configDataType2Code(
                                          Tools.DAY_7.toString());
                                  SDBuried.instance().reportImmediately(
                                      SDBuriedEvent.click,
                                      ElementCode.CODE_HOME_STATICS_CASE,
                                      customParams: reportParams);
                                },
                              ),
                              // padding: EdgeInsets.only(left: 15),
                            ),
                            Expanded(
                              child: DataItemWidget(
                                title: "30日",
                                number: Tools.formatHomeData(
                                    widget.homePageStatistics!.monthCaseNum),
                                clickListener: () {
                                  OpenNative.openWebView(
                                      Tools.makeHomeDataUrl(
                                          UrlConstant.URL_STATISTICS_BD_CASES,
                                          Tools.DAY_30),
                                      "");

                                  Map<String, String> reportParams = Map();
                                  reportParams["home_time_dimension"] =
                                      configDataType2Code(
                                          Tools.DAY_30.toString());
                                  SDBuried.instance().reportImmediately(
                                      SDBuriedEvent.click,
                                      ElementCode.CODE_HOME_STATICS_CASE,
                                      customParams: reportParams);
                                },
                              ),
                              // padding: EdgeInsets.only(left: 15),
                              // )
                            )
                          ],
                        ),
                        padding: EdgeInsets.only(top: 18, bottom: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 112,
                child: InkWell(
                  onTap: () {
                    OpenNative.openWebView(
                        Tools.makeHomeDataUrl(
                            UrlConstant.URL_STATISTICS_BD_CLEW, Tools.DAY_0),
                        "");

                    Map<String, String> reportParams = Map();
                    SDBuried.instance().reportImmediately(
                        SDBuriedEvent.click, ElementCode.CODE_HOME_STATICS_CLEW,
                        customParams: reportParams);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.white),
                    margin: EdgeInsets.only(left: 4, right: 8, top: 8),
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "线索",
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 18, bottom: 16),
                          child: DataItemWidget(
                            title: "待跟进",
                            number: Tools.formatHomeData(
                                widget.homePageStatistics!.newClewCount),
                            clickListener: () {
                              OpenNative.openWebView(
                                  Tools.makeHomeDataUrl(
                                      UrlConstant.URL_STATISTICS_BD_CLEW,
                                      Tools.DAY_0),
                                  "");

                              Map<String, String> reportParams = Map();
                              SDBuried.instance().reportImmediately(SDBuriedEvent.click,
                                  ElementCode.CODE_HOME_STATICS_CLEW,
                                  customParams: reportParams);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}

class DataItemWidget extends StatelessWidget {
  String? title;
  String? number;
  VoidCallback? clickListener;

  DataItemWidget({this.title, this.number, this.clickListener});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickListener != null) {
          clickListener!();
        }
      },
      child: Container(
          child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number ?? "0",
              style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 21,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                title ?? "",
                style: TextStyle(color: Color(0xFF999999), fontSize: 13),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
