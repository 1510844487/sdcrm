import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/CfBdcrmOfficialAnnounceVO.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

// 官宣 tips 控件
class TipsWidget extends StatefulWidget {
  List<CfBdcrmOfficialAnnounceVO>? dataList;

  TipsWidget({this.dataList});

  @override
  State<StatefulWidget> createState() {
    return _TipsWidgetState();
  }
}

class _TipsWidgetState extends State<TipsWidget> {
  SwiperController? _tipsSwiperController;
  bool? canLoop;

  ///是否是兼职顾问
  bool isPartner = false;

  @override
  void initState() {
    super.initState();
    _tipsSwiperController = new SwiperController();
  }

  @override
  void dispose() {
    super.dispose();
    _tipsSwiperController?.dispose();
    _tipsSwiperController = null;
  }

  /// 是否可以轮播
  bool _canLoop() {
    return widget.dataList != null && widget.dataList!.length > 1 && widget.dataList![0].readStatus == 1;
  }

  @override
  Widget build(BuildContext context) {
    return widget.dataList == null || widget.dataList!.length <= 0
        ? Container()
        : Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            height: 76,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "images/crm_home_tips_guanxuan.png",
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Swiper(
                    key: ValueKey(widget.dataList),
                    autoplayDelay: 5000,
                    scrollDirection: Axis.vertical,
                    loop: _canLoop(),
                    index: 0,
                    itemCount: widget.dataList == null ? 0 : widget.dataList!.length,
                    itemBuilder: (context, position) {
                      CfBdcrmOfficialAnnounceVO officialAnnounceVO = widget.dataList![position];
                      String title = officialAnnounceVO.title;
                      bool readed = officialAnnounceVO.readStatus == 1;
                      int mis = officialAnnounceVO.createTime;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(0, -1),
                              child: Container(
                                  height: 46,
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      readed
                                          ? TextSpan(text: "")
                                          : WidgetSpan(
                                              child: Container(
                                                margin: EdgeInsets.only(right: 5),
                                                height: 18,
                                                width: 2 * 11.0 + 11,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(color: Color(0xFFFF3C10), borderRadius: BorderRadius.all(Radius.circular(4))),
                                                child: const Text(
                                                  "未读",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      TextSpan(
                                          text: title ?? "",
                                          style: TextStyle(
                                            height: 1.8,
                                            color: Colors.black,
                                            fontSize: 13,
                                          ))
                                    ]),
                                  )),
                            ),
                          ),
                          Container(
                            height: 46,
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              mis == null ? "" : Tools.sdFormatDate(mis),
                              style: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    controller: _tipsSwiperController,
                    onTap: (position) {
                      CfBdcrmOfficialAnnounceVO? officialAnnounceVO = widget.dataList?[position];
                      if (officialAnnounceVO != null &&
                          officialAnnounceVO.officialAnnounceModels != null &&
                          officialAnnounceVO.officialAnnounceModels!.length > 0) {
                        int knowledgeId = officialAnnounceVO.officialAnnounceModels[0].knowledgeId;
                        // 设置官宣详情为已读
                        NetImp.officialAnnounceReadKnowledge(knowledgeId);

                        //  跳转官宣详情页
                        OpenNative.openWebView("https://www.shuidichou.com/bd/knowledge/detail?id=${knowledgeId}", "");

                        Map<String, String> reportParams = Map();
                        SDBuried.instance().reportImmediately(SDBuriedEvent.click, ElementCode.CODE_HOME_GUANXUAN, customParams: reportParams);
                      }
                    },
                    onIndexChanged: (position) {},
                    autoplay: _canLoop(),
                    autoplayDisableOnInteraction: true,
                  ),
                )
              ],
            ),
          );
  }
}
