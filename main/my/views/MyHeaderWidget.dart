import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/SDRouter.dart';
import 'package:fluttercrmmodule/pages/bean/MyInfoBean.dart';
import 'package:fluttercrmmodule/pages/bean/MyInfoProgressBean.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/User/SDUserInfo.dart';
import 'package:fluttercrmmodule/pages/main/my/viewModel/MyViewModel.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:fluttercrmmodule/widgets/SdImageLoadView.dart';
import 'package:fluttercrmmodule/widgets/sdesign_button.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

class MyHeaderWidget extends StatefulWidget {
  const MyHeaderWidget({
    super.key,
    required this.myInfo,
    required this.progressInfo,
    required this.headUrl,
    required this.completeInfoVisible,
  });

  final MyInfoBean? myInfo;
  final MyInfoProgressBean? progressInfo;
  final String headUrl;
  final bool completeInfoVisible;

  @override
  _MyHeaderWidgetState createState() => _MyHeaderWidgetState();
}

class _MyHeaderWidgetState extends State<MyHeaderWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String volunteerName = widget.myInfo?.volunteerName ?? "";
    String phone = widget.myInfo?.phone ?? "";
    int? _partnerTag = widget.myInfo?.partnerTag;
    int? _roleCode = widget.myInfo?.roleCode;
    return Padding(
      padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 24),
      child: Row(children: <Widget>[
        SDFlatButton(
          color: Colors.transparent,
          onPressed: () async {
            Map<String, String> reportParams = await Tools.buildCommonParams();
            SDBuried.instance().reportImmediately(
              SDBuriedEvent.click,
              ElementCode.CODE_MY_COMPLETE_LIST,
              customParams: reportParams,
            );
            Navigator.of(context).pushNamed(SDRouter.pagePersonInfo);
          },
          child: SdImageLoadView(
            widget.headUrl,
            fit: BoxFit.fill,
            width: 70,
            height: 70,
            shape: BoxShape.circle,
            placeholder: 'images/my_default_head_icon.png',
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              volunteerName,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Offstage(
              offstage: !(_partnerTag == MyViewModel.TAG_PART_TIME || _roleCode == SDUserInfo.ROLE_PART_TIME),
              child: Image.asset(
                _roleCode == SDUserInfo.ROLE_ASSISTANT || _roleCode == SDUserInfo.ROLE_AGENT_MEMBER
                    ? "images/crm_role_assistant.png"
                    : "images/img_part_job.png",
                width: 55,
                height: 35,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  MyViewModel.getPhoneNumberInfo(phone),
                  style: TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 50),
                showCompleteInfo(),
              ],
            ),
          ],
        ),
        Expanded(child: Container()),
        SizedBox(width: 12)
        // ),
      ]),
    );
  }

  showCompleteInfo() {
    if (!widget.completeInfoVisible) return Container();
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
      ),
      child: SDFlatButton(
        onPressed: () async {
          Navigator.of(context).pushNamed(SDRouter.pagePersonInfo);
          Map<String, String> reportParams = await Tools.buildCommonParams();
          SDBuried.instance().reportImmediately(
            SDBuriedEvent.click,
            ElementCode.CODE_MY_COMPLETE_LIST,
            customParams: reportParams,
          );
        },
        child: Text(
          makeProgressInfo(),
          style: TextStyle(
            color: Color(0xFF0071FE),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String makeProgressInfo() {
    if (widget.progressInfo != null) {
      return "完善信息" + "${widget.progressInfo?.hasFillItemCount}" + "/" + "${widget.progressInfo?.totalItemCount}";
    }
    return "完善信息";
  }
}
