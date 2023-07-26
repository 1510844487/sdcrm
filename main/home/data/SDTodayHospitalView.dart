import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDCDetailDataFooterWidget.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDTodayHospitalDataHeader.dart';
import 'package:fluttercrmmodule/pages/main/home/data/views/SDTodayHospitalDataListView.dart';

/// 医院发起控件
class SDTodayHospitalView extends StatefulWidget {
  final VoidCallback? onTapBlock;
  SDTodayHospitalView({this.onTapBlock});
  @override
  _SDTodayHospitalViewState createState() => _SDTodayHospitalViewState();
}

class _SDTodayHospitalViewState extends State<SDTodayHospitalView> {
  double contentMargin = 8;
  double contentPadding = 16;
  bool isUnfold = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
            EdgeInsets.only(top: 8, left: contentMargin, right: contentMargin),
        padding: EdgeInsets.only(left: contentPadding, right: contentPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white,
        ),
        //     (isShowNewClewCount || isShowOfflineTotalCfCount) ? 214 : 126,
        child: Column(children: <Widget>[
          SizedBox(height: 16),
          headerRow(),
          SDTodayHospitalDataHeader(),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            height: 1,
            color: SDColor.gray1,
          ),
          SDTodayHospitalDataListView(isUnfold: isUnfold),
          isUnfold
              ? Container()
              : SDCDetailDataFooterWidget(
                  onPressedBlock: () {
                    setState(() {
                      isUnfold = !isUnfold;
                    });
                  },
                ),
        ]));
  }

  Row headerRow() {
    return Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            child: const Text(
              "今日医院发起",
              style: TextStyle(
                color: SDColor.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Container()),
          seletctCityInkWell()
        ]);
  }

  InkWell seletctCityInkWell() {
    return InkWell(
      onTap: () {
        if(this.widget.onTapBlock != null){
          this.widget.onTapBlock!();
        }
      },
      child: Row(
        children: [
          Container(
            child: Text(
              "全部城市",
              style: TextStyle(fontSize: 13, color: SDColor.gray2),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            child: Image.asset(
              "images/pengfang_arrow_down.png",
              width: 12.5,
              height: 7.5,
            ),
          ),
        ],
      ),
    );
  }
}
