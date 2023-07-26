import 'package:flutter/cupertino.dart';
import 'package:fluttercrmmodule/pages/bean/Organization.dart';
import 'package:fluttercrmmodule/pages/main/home/data/LeaderDataWidget.dart';

/// 首页组织 tab 控件
class SDHomeOrgTabWidget extends StatefulWidget {
  List<Organization>? orgList;
  Organization? chooseOrg;
  ValueChanged<Organization>? clickTabListener;

  SDHomeOrgTabWidget({List<Organization>? orgList, Organization? chooseOrg, ValueChanged<Organization>? clickTabListener}) {
    this.orgList = orgList;
    this.chooseOrg = chooseOrg;
    this.clickTabListener = clickTabListener;
  }

  @override
  State<StatefulWidget> createState() {
    return _SDHomeOrgTabWidgetState();
  }
}

class _SDHomeOrgTabWidgetState extends State<SDHomeOrgTabWidget> {
  @override
  void initState() {
    super.initState();
  }

  /// 是否已经选
  bool hasChoiced(Organization org) {
    return org == widget.chooseOrg;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orgList == null || widget.orgList!.isEmpty) {
      return Container();
    }
    return Container(
      height: 28,
      child: ListView.builder(
          itemBuilder: (context, position) {
            Organization org = widget.orgList![position];
            return Container(
              margin: EdgeInsets.only(left: 15),
              child: TabbarItemWidget(
                title: org.orgName ?? "",
                isChoiced: widget.chooseOrg == org,
                titleSizeChoiced: 13,
                titleSizeDef: 13,
                titlePadding: EdgeInsets.only(top: 0, bottom: 6),
                contentAlign: MainAxisAlignment.end,
                clickListener: () {
                  if (hasChoiced(org)) {
                    return;
                  }
                  widget.chooseOrg = org;
                  if (mounted) {
                    setState(() {});
                    if (widget.clickTabListener != null && widget.chooseOrg != null) {
                      widget.clickTabListener!(widget.chooseOrg!);
                    }
                  }
                },
              ),
            );
          },
          itemCount: widget.orgList!.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(right: 15),
          shrinkWrap: true),
    );
  }
}
