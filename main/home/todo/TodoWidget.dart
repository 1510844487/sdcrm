import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/pages/bean/BacklogListBean.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/PageName.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

// 待办控件
class TodoWidget extends StatefulWidget {
  List<BacklogBean>? backlogList;
  TodoWidget(this.backlogList);

  @override
  State<StatefulWidget> createState() {
    return _TodoWidgetState();
  }
}

class _TodoWidgetState extends State<TodoWidget>
{
  bool canShow = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.backlogList != null && widget.backlogList!.length > 0
        ? InkWell(
            onTap: () async {
              //埋点上报

              OpenNative.openWebView(
                  "https://www.shuidichou.com/bd/wait-processing", "");
              Map<String, String> reportParams =
                  await Tools.buildCommonParams();
              reportParams['reportName'] = PageName.HomePage;
              SDBuried.instance().reportImmediately(
                  SDBuriedEvent.click, ElementCode.CODE_MY_TODO,
                  customParams: reportParams);
            },
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 8),
              margin: EdgeInsets.only(left: 8, right: 8, top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              height: 54.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "我的待办",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 3),
                          constraints: BoxConstraints(
                              minWidth: 20, maxHeight: 20, minHeight: 20),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          alignment: Alignment.center,
                          child: Text(
                            "${widget.backlogList == null ? 0 : widget.backlogList!.length}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "立即处理 ",
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 13,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFF999999),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
