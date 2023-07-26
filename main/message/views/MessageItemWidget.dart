import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/SDRouter.dart';
import 'package:fluttercrmmodule/data/DataHelper.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/BdcrmCurrentStatusBean.dart';
import 'package:fluttercrmmodule/pages/bean/ExamInfo.dart';
import 'package:fluttercrmmodule/pages/bean/MessageBean.dart';
import 'package:fluttercrmmodule/pages/bean/MineInfoBean.dart';
import 'package:fluttercrmmodule/pages/main/message/viewModel/MessageViewModel.dart';
import 'package:fluttercrmmodule/pages/mine/UploadType.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';

class MessageItemWidget extends StatefulWidget {
  const MessageItemWidget({super.key, this.title, this.model});

  final String? title;
  final MessageBean? model;

  @override
  _MessageItemWidgetState createState() {
    return _MessageItemWidgetState();
  }
}

class _MessageItemWidgetState extends State<MessageItemWidget> {
  String _headUrl = '', _rejectReason = '';

  @override
  Widget build(BuildContext context) {
    List<RichTextModel> array = [];
    String? content = widget.model?.content;
    if (content != null) {
      array = MessageViewModel.transformRichContent(content);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.zero,
          child: buildCreateTime(),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRich(array),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ], // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildCreateTime() {
    MessageBean? model = widget.model;
    if (model != null) {
      return Text(
        Tools.toYRSF(model.createTime ?? 0),
        style: TextStyle(fontSize: 13, color: Color(0xFFB1B1B1)),
      );
    } else {
      return Container();
    }
  }

  Widget buildRich(List<RichTextModel> models) {
    if (models.length > 0) {
      return Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[Expanded(child: setRichWidget(models))],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _clickItem(String? linkText) {
    _fetchUserInfo();
    if (linkText == null) return;
    if (linkText.contains("flutter://")) {
      if (linkText == "flutter://manager/todolist") {
        OpenNative.openWebView("https://www.shuidichou.com/bd/wait-processing", "");
      } else if (linkText == "flutter://user/personinfopage") {
        Navigator.of(context).pushNamed(SDRouter.pagePersonInfo);
      } else if (linkText.contains("flutter://university/examdetailpage")) {
        if (linkText.contains('?')) {
          int index = linkText.indexOf("?id=");
          if (index < 0) {
            return;
          }
          ExamInfo info = ExamInfo();
          info.id = int.parse(linkText.substring(index + 4));
          Navigator.of(context).pushNamed(SDRouter.pageExamDetailPage, arguments: {"id": info.id});
        }
      } else if (linkText.contains("flutter://manager/headiconreviewpage")) {
        _configUserInfo();
      } else if (linkText.contains("flutter://manager/honorreviewpage")) {
        Navigator.of(context).pushNamed(SDRouter.pageUploadHonorPhoto);
      }
      return;
    }

    // 物料消息
    if (linkText.contains(".going-link.com")) {
      getCertificateCodeData(linkText);
      return;
    }

    // 去修改的地址为 "https://www.shuidichou.com/bd/reject/2295/edit"
    int index = linkText.indexOf('.com/bd/reject/');
    if (index > 0) {
      var startIndex = index + 15;
      var rejectId = "";
      try {
        String endString = linkText.substring(startIndex);
        List array = endString.split("/");
        if (array.isNotEmpty) {
          rejectId = array[0];
          fetchBdcrmReplaceWriteStatus(int.parse(rejectId), linkText);
        }
      } catch (e) {
      }
    } else {
      OpenNative.openWebView(linkText, "");
    }
  }

  fetchBdcrmReplaceWriteStatus(int rejectId, String linkText) async {
    SDResponse<BdcrmCurrentStatusBean> response = await NetImp.fetchBdcrmReplaceWriteStatus(rejectId);
    BdcrmCurrentStatusBean? infoBean = response.module;
    if (response.isSuccess() && infoBean != null) {
      if (infoBean.status == 3) {
        OpenNative.openWebView(linkText, "");
      } else {
        ToastHelper.showLong("当前状态不允许修改");
      }
    }
  }

  static getCertificateCodeData(String? linkText) async {
    var url = "https://mobile.going-link.com/WxCover/?state=wdvtGoldFish-731cf711f8d845d69dda20f150a259d6&code=";
    if (linkText != null) {
      if (linkText.contains("&code=")) {
        url = linkText;
      } else {
        url = linkText + "&code=";
      }
    }

    SDResponse<String> response = await NetImp.fetchCertificateCode();
    if (response.isSuccess()) {
      String code = response.module ?? "";
      var endUrl = url + code;
      OpenNative.openWebView(endUrl, "");
    }
  }

  RichText setRichWidget(List<RichTextModel> array) {
    List<TextSpan> list = [];
    array.forEach((model) {
      if (model.isRich) {
        var richWidget = TextSpan(
          text: model.content ?? "",
          style: TextStyle(fontSize: 14, color: Color(0xFF0071FE), decoration: TextDecoration.underline, height: 1.5),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _clickItem(model.link);
            },
        );
        list.add(richWidget);
      } else {
        var widget = TextSpan(text: model.content ?? "", style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5));
        list.add(widget);
      }
    });

    return RichText(
      text: TextSpan(style: TextStyle(fontSize: 18), children: list),
      textDirection: TextDirection.ltr,
    );
  }

  void _fetchUserInfo() {
    DataHelper.instant().getUserInfo((response) {
      if (response.isSuccess()) {
        MineInfoBean? userInfo = response.module;
        if (userInfo != null) {
          _headUrl = userInfo.headUrl ?? '';
          _rejectReason = userInfo.rejectReason ?? '';
        }
      } else {
        ToastHelper.showShort(response.msg);
      }
    });
  }

  void _configUserInfo() {
    DataHelper.instant().getUserInfo((response) {
      if (response.isSuccess()) {
        MineInfoBean? userInfo = response.module;
        if (userInfo != null) {
          _headUrl = userInfo.headUrl ?? '';
          _rejectReason = userInfo.rejectReason ?? '';
          Map paramMap = Map();
          paramMap['headUrl'] = _headUrl;
          paramMap['auditingStatus'] = 2;
          paramMap['uploadType'] = UploadType.HEAD;
          paramMap['rejectReason'] = _rejectReason;

          if (_headUrl.isNotEmpty) {
            Navigator.of(context).pushNamed(SDRouter.pageUploadHeadOrCodePage, arguments: paramMap);
          } else {
            DataHelper.instant().getUserInfo((response) {
              if (response.isSuccess()) {
                MineInfoBean? userInfo = response.module;
                if (userInfo != null) {
                  _headUrl = userInfo.headUrl ?? "";
                  paramMap['headUrl'] = _headUrl;
                  Navigator.of(context).pushNamed(SDRouter.pageUploadHeadOrCodePage, arguments: paramMap);
                }
              }
            });
          }
        }
      } else {
        ToastHelper.showShort(response.msg);
      }
    });
  }
}
