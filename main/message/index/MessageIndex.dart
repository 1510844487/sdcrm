import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/data/net/SDNetInterface.dart';
import 'package:sd_flutter_base/module/base/SimplePage.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';
import 'package:sd_flutter_base/widgets/SdRefreshWidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

import '../../../../SDRouter.dart';
import '../../../../data/net/SDNetProvider.dart';
import '../../../../utils/Tools.dart';
import '../../../../widgets/SdImageLoadView.dart';
import '../../../bean/MessageIconInfo.dart';

/// 消息模块首页
class MessageIndexWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessageIndexWidgetState();
  }
}

class MessageIndexWidgetState extends State<MessageIndexWidget> with SDPageVisibileObserver, AutomaticKeepAliveClientMixin {
  RefreshController? _refreshController;
  List<MessageIconInfo>? _iconList;
  bool? _showLoading;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _showLoading = true;
    requestData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SDPageLifecycler.instance.addObserver(this, context);
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    SDPageLifecycler.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onForeground() {
    super.onForeground();
    // 监听app前台展示刷新列表数据
    requestData(forceUpdateUi: true);
  }

  @override
  void onPageShow() {
    super.onPageShow();
    // 监听页面前台可见刷新列表数据
    requestData(forceUpdateUi: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SimplePage(
      getContentWidget(),
      actionBarLeftShow: false,
      actionBarCentTitle: '消息中心',
      showLoading: _showLoading ?? false,
    );
  }

  getContentWidget() {
    return SdRefreshWidget(
      _refreshController!,
      onRefresh: () {
        requestData();
      },
      enablePullDown: true,
      enablePullUp: false,
      child: ListView.separated(
          itemBuilder: (context, position) {
            MessageIconInfo messageIconInfo = _iconList![position];
            return InkWell(
              child: MessageItemWidget(
                image: messageIconInfo.iconUrl ?? '',
                title: messageIconInfo.categoryName ?? '',
                desc: Tools.isEmpty(messageIconInfo.recentlyMsg) ? '暂无相关消息' : messageIconInfo.recentlyMsg,
                date: messageIconInfo.recentlyMsgTime ?? '',
                redNum: messageIconInfo.unReadCount ?? 0,
              ),
              onTap: () {
                SDRouter.push(SDRouter.pageMessageIndex, params: {"categoryId": messageIconInfo.categoryId, "categoryTitle": messageIconInfo.categoryName});
              },
            );
          },
          separatorBuilder: (context, position) {
            return Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              height: 1,
              color: Color(0xFFF1F1F1),
            );
          },
          itemCount: _iconList?.length ?? 0),
    );
  }

  requestData({forceUpdateUi: false}) async {
    SDResponse<List<MessageIconInfo>> netResult = await NetImp.requestMessageCategoryList();
    if (netResult.isSuccess()) {
      if (forceUpdateUi || (_showLoading ?? false) || (_refreshController?.isRefresh ?? false)) {
        _refreshController?.refreshCompleted(resetFooterState: true);
        if(mounted){
          setState(() {
            _iconList = netResult.module;
            _showLoading = false;
          });
        }
      }
    } else {
      if (_refreshController?.isRefresh ?? false) {
        _refreshController?.refreshCompleted();
      }
      if(mounted){
        setState(() {
          _showLoading = false;
        });
      }
      ToastHelper.showLong(netResult.msg ?? "发生错误，请刷新下试试");
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class MessageItemWidget extends StatelessWidget {
  final String? image;
  final String? title;
  final String? desc;
  final String? date;
  final int? redNum;

  MessageItemWidget({this.image, this.title, this.desc, this.date, this.redNum});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 22),
            child: Row(
              children: [
                SdImageLoadView(
                  image ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: "images/icon_message_placeholder.png",
                ),
                Expanded(
                    child: Container(
                  margin: EdgeInsets.only(left: 16),
                  height: 50,
                  child: Stack(
                    children: [
                      Text(
                        title ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Positioned(
                        child: Text(
                          desc ?? '',
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        bottom: 0,
                      ),
                      Positioned(
                        child: Text(
                          date ?? '',
                          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
                          maxLines: 1,
                        ),
                        right: 0,
                      )
                    ],
                  ),
                ))
              ],
            ),
          ),
          Positioned(
              top: 14,
              left: 70 - getRedWidth(),
              child: Visibility(
                visible: isShowRed(),
                child: Container(
                  padding: EdgeInsets.only(top: 2),
                  alignment: Alignment.center,
                  constraints: BoxConstraints(minHeight: 16, maxHeight: 16, minWidth: 16, maxWidth: getRedWidth()),
                  child: Text(
                    getRedStr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Color(0xFFFF2F27)),
                ),
              ))
        ],
      ),
    );
  }

  double getRedWidth() {
    if (redNum == null || redNum! <= 0) {
      return 16;
    }
    if (redNum! < 10) {
      return 16;
    }
    if (redNum! >= 10 && redNum! <= 99) {
      return 20;
    }
    if (redNum! > 99) {
      return 26;
    }
    return 16;
  }

  String getRedStr() {
    if (redNum == null || redNum! <= 0) {
      return '0';
    }
    if (redNum! < 10) {
      return '${redNum}';
    }
    if (redNum! >= 10 && redNum! <= 99) {
      return '${redNum}';
    }
    if (redNum! > 99) {
      return '99+';
    }
    return '0';
  }

  bool isShowRed() {
    if (redNum == null || redNum! <= 0) {
      return false;
    }
    if (redNum! < 10) {
      return true;
    }
    if (redNum! >= 10 && redNum! <= 99) {
      return true;
    }
    if (redNum! > 99) {
      return true;
    }
    return false;
  }
}
