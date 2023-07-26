import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconConstant.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconPush.dart';
import 'package:fluttercrmmodule/pages/common/PageName.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/home/icontips/IconTipsHelper.dart';

// 功能控件
class FunsWidget extends StatefulWidget {
  List<AppIconModelList>? iconList;

  FunsWidget({this.iconList});

  @override
  State<StatefulWidget> createState() {
    return _FunsWidgetState();
  }
}

class _FunsWidgetState extends State<FunsWidget>
// with WidgetsBindingObserver
{
  // 客服消息数
  int? kefuNum;

  // 官宣消息数
  int? gxNum;

  // 武器库消息状态
  bool? wqStatus;

  // 营销海报状态
  int? yxhbStatus;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    IconTipsHelper.registTipsListener(iconTipsListener);
    initData();
  }

  @override
  void dispose() {
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    IconTipsHelper.unRegistTipsListener(iconTipsListener);
  }

  iconTipsListener(IconTips iconTips) {
    if(mounted){
      if (iconTips.iconId == WorkSpaceConfigConstant.KF) {
        setState(() {
          kefuNum = iconTips.data;
        });
      } else if (iconTips.iconId == WorkSpaceConfigConstant.GX) {
        setState(() {
          gxNum = iconTips.data;
        });
      } else if (iconTips.iconId == WorkSpaceConfigConstant.WQK) {
        setState(() {
          wqStatus = iconTips.data;
        });
      } else if (iconTips.iconId == WorkSpaceConfigConstant.YXHB) {
        setState(() {
          yxhbStatus = iconTips.data;
        });
      }
    }
  }

  initData() async {
    IconTipsHelper.fetchIconTipsData(widget.iconList);
  }

  @override
  void deactivate() {
    super.deactivate();
    bool isBack = ModalRoute.of(context)?.isCurrent ?? false;
    if (isBack) {
      IconTipsHelper.fetchIconTipsData(widget.iconList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.iconList == null
        ? Container()
        : Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white,
            ),
            child: GridView.builder(
              padding: EdgeInsets.only(left: 0, right: 0, top: 12, bottom: 12),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 359 / 4 / 88.5),
              itemBuilder: (context, position) {
                AppIconModelList iconModelList = widget.iconList![position];

                bool showRedNum = false;
                bool showRedDot = false;
                int num = 0;
                if(iconModelList.iconCode == WorkSpaceConfigConstant.KF){
                  showRedNum = kefuNum != null && kefuNum! > 0;
                  num = kefuNum ?? 0;
                }else if(iconModelList.iconCode == WorkSpaceConfigConstant.GX){
                  showRedNum = gxNum != null && gxNum! > 0;
                  num = gxNum ?? 0;
                }else if(iconModelList.iconCode == WorkSpaceConfigConstant.WQK){
                  showRedDot = wqStatus ?? false;
                }else if(iconModelList.iconCode == WorkSpaceConfigConstant.YXHB){
                  showRedDot = yxhbStatus == 1;
                }

                return InkWell(
                  onTap: () {
                    // 功能按键点击
                    IconPush.pushToPage(
                        iconModelList, PageName.HomePage, context);
                  },
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 5, right: 5, top: 5),
                              child: Image.asset(
                                IconConstant.fetchImageName(iconModelList.iconCode),
                                width: 44,
                                height: 44,
                              ),
                            ),
                            showRedNum
                                ? Positioned(
                                    top: 0,
                                    right: 15,
                                    child: Container(
                                      alignment: Alignment.center,
                                      constraints: BoxConstraints(
                                          minHeight: 20,
                                          maxHeight: 20,
                                          minWidth: 20),
                                      padding: EdgeInsets.only(
                                          left: 2, right: 2, top: 2, bottom: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                      child: Text(
                                        "${num ?? 0}",
//                                        "${num ?? 0}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                  )
                                : Container(),
                            showRedDot
                                ? Positioned(
                                    top: 5,
                                    right: 20,
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            iconModelList.iconDesc ?? "",
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 13,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: widget.iconList!.length,
            ),
          );
  }
}
