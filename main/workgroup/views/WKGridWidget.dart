import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/Engine/SDWhaleEngine.dart';
import 'package:fluttercrmmodule/pages/bean/WorkGroupBean.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconConstant.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconPush.dart';
import 'package:fluttercrmmodule/pages/common/PageName.dart';
import 'package:fluttercrmmodule/pages/config/WorkSpaceConfigConstant.dart';
import 'package:fluttercrmmodule/pages/main/home/icontips/IconTipsHelper.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

class WKGridWidget extends StatefulWidget {
  const WKGridWidget({super.key, required this.data});

  final List<AppIconModelList> data;

  @override
  _WKGridWidgetState createState() => _WKGridWidgetState();
}

class _WKGridWidgetState extends State<WKGridWidget> with SDPageVisibileObserver {
  bool showEdit = false;
  bool isShowProgress = false;

  // 客服消息数
  int? kefuNum;

  // 官宣消息数
  int? gxNum;

  // 武器库消息状态
  bool? wqStatus;

  // 营销海报状态
  int? yxhbStatus;

  // 案例运营消息数据
  int? alyyNum;

  // 待办小数
  int? dbNum;

  @override
  void initState() {
    super.initState();
    IconTipsHelper.registTipsListener(iconTipsListener);
    IconTipsHelper.fetchIconTipsData(widget.data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SDPageLifecycler.instance.addObserver(this, context);
  }

  @override
  void dispose() {
    SDPageLifecycler.instance.removeObserver(this);
    super.dispose();
    IconTipsHelper.unRegistTipsListener(iconTipsListener);
  }

  @override
  void onPageShow() {
    super.onPageShow();
    if (SDWhaleEngine().selectPageName == "workGroup") {
      IconTipsHelper.fetchIconTipsData(widget.data);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    bool? isBack = ModalRoute.of(context)?.isCurrent;
    if (isBack == true) {
      IconTipsHelper.fetchIconTipsData(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 359 / 4 / 88.5,
      ),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        AppIconModelList iconModelList = widget.data[index];
        bool showRedNum = false;
        bool showRedDot = false;
        int? num;
        if (iconModelList.iconCode == WorkSpaceConfigConstant.KF) {
          showRedNum = kefuNum != null && kefuNum! > 0;
          num = kefuNum;
        } else if (iconModelList.iconCode == WorkSpaceConfigConstant.GX) {
          showRedNum = gxNum != null && gxNum! > 0;
          num = gxNum;
        } else if (iconModelList.iconCode == WorkSpaceConfigConstant.WQK) {
          showRedDot = wqStatus ?? false;
        } else if (iconModelList.iconCode == WorkSpaceConfigConstant.YXHB) {
          showRedDot = yxhbStatus == 1;
        } else if (iconModelList.iconCode == WorkSpaceConfigConstant.ALYY) {
          showRedNum = alyyNum != null && alyyNum! > 0;
          num = alyyNum;
        } else if (iconModelList.iconCode == WorkSpaceConfigConstant.DB) {
          showRedNum = dbNum != null && dbNum! > 0;
          num = dbNum;
        }

        String numStr = "";
        if (num == null) {
          num = 0;
        }
        if (num > 99) {
          numStr = '99+';
        } else {
          numStr = num.toString();
        }

        return InkWell(
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
                      padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                      child: Image(
                        image: AssetImage(IconConstant.fetchImageName(widget.data[index].iconCode)),
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                    showRedNum
                        ? Positioned(
                            top: 0,
                            right: 15,
                            child: Container(
                              alignment: Alignment.center,
                              constraints: BoxConstraints(minHeight: 20, maxHeight: 20, minWidth: 20),
                              padding: EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Text(
                                numStr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 13),
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
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.data[index].iconDesc,
                    style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            onItemClick(index);
          },
        );
      },
    );
  }

  onItemClick(int index) {
    var model = widget.data[index];
    IconPush.pushToPage(model, PageName.WorkGroupPage, context);
  }

  iconTipsListener(IconTips iconTips) {
    if (iconTips.iconId == WorkSpaceConfigConstant.KF) {
      if (mounted) {
        setState(() {
          kefuNum = iconTips.data;
        });
      }
    } else if (iconTips.iconId == WorkSpaceConfigConstant.GX) {
      if (mounted) {
        setState(() {
          gxNum = iconTips.data;
        });
      }
    } else if (iconTips.iconId == WorkSpaceConfigConstant.WQK) {
      if (mounted) {
        setState(() {
          wqStatus = iconTips.data;
        });
      }
    } else if (iconTips.iconId == WorkSpaceConfigConstant.YXHB) {
      if (mounted) {
        setState(() {
          yxhbStatus = iconTips.data;
        });
      }
    } else if (iconTips.iconId == WorkSpaceConfigConstant.ALYY) {
      if (mounted) {
        setState(() {
          alyyNum = iconTips.data;
        });
      }
    } else if (iconTips.iconId == WorkSpaceConfigConstant.DB) {
      if (mounted) {
        setState(() {
          dbNum = iconTips.data;
        });
      }
    }
  }
}
