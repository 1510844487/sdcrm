import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/dialog/HomePageDialogHelper.dart';
import 'package:fluttercrmmodule/pages/bean/TrendModel.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDChartWidget.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

/// 趋势图控件
class SDDataChartView extends StatefulWidget {
  List<TrendModel>? trendModelList;

  SDDataChartView(this.trendModelList);

  @override
  _SDDataChartViewState createState() => _SDDataChartViewState();
}

class _SDDataChartViewState extends State<SDDataChartView> {
  bool isUnfold = false;

  // 捐单 今天
  List<TrendModelList>? jdToday;

  // 捐单 8周均值
  List<TrendModelList>? jd8Weeks;

  // 案例 今天
  List<TrendModelList>? alToday;

  // 案例 8周均值
  List<TrendModelList>? al8Weeks;

  @override
  void initState() {
    super.initState();
    if (widget.trendModelList != null) {
      for (TrendModel model in widget.trendModelList!) {
        switch (model.interestedItem) {
          case 50:
            jdToday = model.trendModelList;
            break;
          case 51:
            jd8Weeks = model.trendModelList;
            break;
          case 52:
            alToday = model.trendModelList;
            break;
          case 53:
            al8Weeks = model.trendModelList;
            break;
        }
      }
      Tools.reportHomeChartDataPoint(widget.trendModelList!, Tools.HOME_CHART_TYPE_INIT);
    }
  }

  @override
  Widget build(BuildContext context) {
    double contentMargin = 8;
    double contentPadding = 12;

    return widget.trendModelList == null
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 8, left: contentMargin, right: contentMargin),
            padding: EdgeInsets.only(left: contentPadding, right: contentPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white,
            ),
            child: Column(children: <Widget>[
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "今日捐单趋势",
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: SDTipsWidget(
                    clickListener: () {
                      HomePageDialogHelper.showDataTipsDialog(
                          context,
                          "数据说明",
                          [
                            DialogLable("今日捐单", "截止到当前的捐单量。"),
                            DialogLable("今日案例发起", "今日0点截止到当前的发起量（过预审的案例量）。"),
                          ],
                          "默认对比近8周同时段均值，也可在「数据配置」中设置为对比近8周同时段峰值。对比值每小时整点更新。\n举例：如周一早9:30，对比前8周的周一9:00的均值或峰值。");
                    },
                    title: '数据说明',
                  )),
                ],
              ),
              SizedBox(height: 6),
              StateRowView(),
              SizedBox(height: 16),
              LineChartSample2(jdToday, jd8Weeks),
              SizedBox(height: 16),
              StateTapGestureDetector(),
              SizedBox(height: isUnfold ? 6 : 0),
              isUnfold ? StateRowView() : Container(),
              SizedBox(height: 12),
              isUnfold ? LineChartSample2(alToday, al8Weeks) : Container(),
              SizedBox(height: isUnfold ? 12 : 0),
            ]),
          );
  }

  GestureDetector headerTapGestureDetector(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return SimpleDialog(
                  title: Text(""),
                  titlePadding: EdgeInsets.all(10),
                  backgroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                  children: <Widget>[
                    ListTile(
                      title: Center(
                        child: Text(
                          "请填写完整信息！",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    ListTile(
                      title: Center(
                          child: Container(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.red),
                        child: Text(
                          "知道了",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        },
        child: Container());
  }

  GestureDetector StateTapGestureDetector() {
    return GestureDetector(
        onTap: () async {
          Map<String, String> reportParams = await Tools.buildCommonParams();
          SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_TREND_CASE,
              customParams: reportParams);
          if (mounted) {
            setState(() {
              isUnfold = !isUnfold;
            });
          }
        },
        child: Container(
          margin: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(top: 4, left: 8, bottom: 4, right: 8),
          decoration: BoxDecoration(color: SDColor.lightGreen, borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: const Text(
                  "今日案例发起",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(child: Container()),
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.only(bottom: 4),
                child: Image.asset(
                  isUnfold ? "images/data_arrow_up.png" : "images/data_arrow_down.png",
                  width: 12.5,
                  height: 7.5,
                ),
              ),
            ],
          ),
        ));
  }

  Row StateRowView() {
    return Row(
      children: [
        Container(height: 1, width: 12, color: Color(0xFF0071FE)),
        Container(
            margin: EdgeInsets.only(left: 4),
            child: Text("今日数据", style: TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)))),
        Container(margin: EdgeInsets.only(left: 12), height: 1, width: 12, color: Color(0xFFFE6600)),
        Container(
            margin: EdgeInsets.only(left: 4),
            child: Text("近8周同时段数据", style: TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)))),
      ],
    );
  }
}

class SDTipsWidget extends StatelessWidget {
  final String? title;
  final VoidCallback? clickListener;

  const SDTipsWidget({Key? key, this.title, this.clickListener}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickListener != null) {
          clickListener!();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "$title",
            style: TextStyle(color: Color(0xFFC0C0C0), fontSize: 12),
          ),
          SizedBox(
            width: 2,
          ),
          Image.asset(
            "images/question_circle.png",
            width: 12,
            height: 12,
          ),
        ],
      ),
    );
  }
}
