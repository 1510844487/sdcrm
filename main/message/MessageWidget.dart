import 'package:flutter/material.dart';
import 'package:flutter_exposure/list/exposure_widget.dart';
import 'package:flutter_exposure/list/scroll_detail_provider.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/event/MessageRefreshEvent.dart';
import 'package:fluttercrmmodule/pages/bean/MessageBean.dart';
import 'package:fluttercrmmodule/pages/main/message/views/MessageItemWidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sd_flutter_base/module/base/SimplePage.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/widgets/SdRefreshWidget.dart';
import 'package:sd_hybrid_base/sd_hybrid_base.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({super.key, this.title});

  final String? title;

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  int pageIndex = 1;
  List<MessageBean> list = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);

  // 消息分类id
  String? categoryId;

  // 消息分类标题
  String? categoryTitle;

  // 是否展示页面loading
  bool? showLoading;

  @override
  void initState() {
    super.initState();
    showLoading = true;
    messageRefreshEventBus.on<MessageRefreshEvent>().listen((event) {
      refreshController.requestRefresh();
    });
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    if (categoryId == null) {
      Map? paramsMap = SDNavigator.instance.getParmas(context);
      categoryId = paramsMap?["categoryId"];
      categoryTitle = paramsMap?["categoryTitle"];
      requestData();
    }

    return SimplePage(
      Container(
        color: Color(0xFFF2F2F2),
        child: ScrollDetailProvider(
          child: SdRefreshWidget(
            refreshController,
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: () {
              pageIndex = 1;
              requestData();
            },
            onLoadmore: () {
              pageIndex++;
              requestData();
            },
            child: buildList(),
          ),
        ),
      ),
      actionBarCentTitle: categoryTitle ?? "",
      showLoading: showLoading ?? false,
      backgroundColor: Color(0xFFF2F2F2),
      actionbarBgColor: Color(0xFFF2F2F2),
      actionBarLeftShow: true,
      clickActionBarLeftWidgetEvent: () {
        SDNavigator.instance.pop();
      },
    );
  }

  Widget buildList() {
    if (list.isNotEmpty) {
      return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return SizedBox(height: 1);
          },
          padding: EdgeInsets.only(bottom: 20),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return Exposure(
              exposeFactor: 1,
              onExpose: () {
                MessageBean messageBean = list[index];
                if (messageBean.readStatus == 0) {
                  // 消息未读状态时调用调用置为已读状态接口
                  NetImp.setReadedAllMessage(categoryId: categoryId ?? "", id: (messageBean.id ?? 0).toString());
                }
              },
              child: GestureDetector(
                onTap: () {},
                child: MessageItemWidget(model: list[index]),
              ),
            );
          });
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text(
          "暂无相关消息",
          style: TextStyle(
            color: Colors.black26,
            fontSize: 20,
          ),
        ),
      );
    }
  }

  Future<void> requestData() async {
    SDResponse<List<MessageBean>> response = await NetImp.fetchMessageList(pageIndex, categoryId: categoryId);

    if (response.isSuccess()) {
      List<MessageBean>? newList = response.module;
      if (newList != null) {
        if (refreshController.isRefresh) {
          list.clear();
          refreshController.refreshCompleted(resetFooterState: true);
        }

        list.addAll(newList);

        if (refreshController.isLoading) {
          refreshController.loadComplete();
        } else {
          refreshController.refreshCompleted(resetFooterState: true);
        }

        if (newList.isEmpty) {
          refreshController.loadNoData();
          if (pageIndex > 1) {
            pageIndex--;
          }
        }
      }

      if (mounted) {
        setState(() {
          showLoading = false;
        });
      }
    } else {
      if (refreshController.isLoading) {
        refreshController.loadComplete();
      } else {
        refreshController.refreshCompleted(resetFooterState: true);
        if (mounted) {
          setState(() {
            showLoading = false;
          });
        }
      }
    }
  }
}
