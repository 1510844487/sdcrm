import 'dart:ui' as sdui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:fluttercrmmodule/pages/bean/HomeReward.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/pages/common/Icon/IconPush.dart';
import 'package:fluttercrmmodule/utils/SdEventBus.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';
import 'package:sd_flutter_base/module/opennative/OpenNative.dart';
import 'package:sd_flutter_base/module/toast/ToastHelper.dart';

/// 首页任务激励模块
class CrmHomeRewardWidget extends StatefulWidget {
  List<HomeReward>? homeRewardList;

  CrmHomeRewardWidget(this.homeRewardList);

  @override
  State<StatefulWidget> createState() {
    return CrmHomeRewardWidgetState();
  }
}

class CrmHomeRewardWidgetState extends State<CrmHomeRewardWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.homeRewardList == null || widget.homeRewardList!.length <= 0
        ? Container()
        : Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 20),
            decoration: BoxDecoration(color: Color(0xFFFDF2E9), borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Stack(
              children: [
                Positioned(
                    child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Image.asset(
                    "images/icon_home_rewart.png",
                    height: 44,
                  ),
                )),
                Positioned(
                  child: Image.asset(
                    "images/icon_home_reward_zq.png",
                    height: 18,
                  ),
                  left: 45,
                  top: 11,
                ),
                Positioned(
                    right: 12,
                    top: 11,
                    child: InkWell(
                      onTap: () {
                        _clickTewardAll();
                      },
                      child: Text(
                        "查看全部",
                        style: TextStyle(color: Color(0xFFFE6600), fontSize: 12),
                      ),
                    )),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      return _buildItem(context, position);
                    },
                    itemCount: widget.homeRewardList == null ? 0 : widget.homeRewardList!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  ),
                )
              ],
            ),
          );
  }

  _getUnitStr(ConfigModel configModel) {
    String progressUnit = "个";
    if (configModel != null) {
      if (configModel.ruleType == "SINGLE_CASE") {
        progressUnit = "个";
      } else if (configModel.ruleType == "DONATE_NUM") {
        progressUnit = "单";
      }
    }
    return progressUnit;
  }

  _buildItem(BuildContext context, int position) {
    if (widget.homeRewardList != null && widget.homeRewardList!.length > position) {
      HomeReward homeReward = widget.homeRewardList![position];
      String progressUnit = _getUnitStr(homeReward.configModel);

      if (homeReward.taskType == 0) {
        // 普通任务
        return HomeRewardNormalItemWidget(
          taskDesc: homeReward.taskDesc ?? "",
          data: "${homeReward.startDate}-${homeReward.endDate}",
          process: "完成进度：${homeReward.finishProgress}/${homeReward.needProgress}${progressUnit}",
          isShowTakeTask: homeReward.taskStatus != 0 && homeReward.taskDrawStatus == 0,
          isShowTasking: homeReward.taskStatus != 0 && (homeReward.taskDrawStatus == 1 || homeReward.taskDrawStatus == 2),
          isShowTaskDone: homeReward.taskStatus != 0 && homeReward.taskDrawStatus == 3,
          clickTakeTaskListener: () {
            _clickTakeTask(homeReward);
          },
          clickItemListener: () {
            _clickTaskItem(homeReward);
          },
        );
      } else if (homeReward.taskType == 1) {
        // 进阶任务

        return HomeRewardAdvancedItemWidget(
          taskDesc: homeReward.taskDesc ?? "",
          clickTakeTaskListener: () {
            _clickTakeTask(homeReward);
          },
          isShowTakeTask: homeReward.taskStatus != 0 && homeReward.taskDrawStatus == 0,
          isShowTasking: homeReward.taskStatus != 0 && (homeReward.taskDrawStatus == 1 || homeReward.taskDrawStatus == 2),
          isShowTaskDone: homeReward.taskStatus != 0 && homeReward.taskDrawStatus == 3,
          homeReward: homeReward,
          clickItemListener: () {
            _clickTaskItem(homeReward);
          },
        );
      } else {
        // 默认处理
        return Container();
      }
    }
  }

  /// 查看全部
  _clickTewardAll() {
    OpenNative.openWebView("https://www.shuidichou.com/bd/task-list", "");
    IconPush.reportCode(ElementCode.CODE_HOME_REWARD_ALL, "");
  }

  /// 领取任务点击
  _clickTakeTask(HomeReward homeReward) {
    sdEventBus.sendEvent(EventType.homeloading, true);
    NetImp.updateReceiveTask(homeReward.taskId).then((response) {
      if (response.isSuccess()) {
        NetImp.getHomePageList().then((SDResponse<List<HomeReward>> response) {
          sdEventBus.sendEvent(EventType.updataHomeReward, response.module);
          ToastHelper.showShortCenter("领取成功");
          sdEventBus.sendEvent(EventType.homeloading, false);
        });
      } else {
        ToastHelper.showShortCenter("领取失败");
        sdEventBus.sendEvent(EventType.homeloading, false);
      }
    });
  }

  /// 点击任务条目
  _clickTaskItem(HomeReward homeReward) {
    OpenNative.openWebView("https://www.shuidichou.com/bd/task-detail?taskId=${homeReward?.taskId}", "");
  }
}

/// 普通奖励任务
class HomeRewardNormalItemWidget extends StatelessWidget {
  /// 领取任务点击事件
  VoidCallback? clickTakeTaskListener;

  /// 任务描述
  String? taskDesc;

  /// 日期描
  String? data;

  /// 任务进度描述
  String? process;

  /// 是否展示领取任务
  bool? isShowTakeTask;

  /// 是否展示任务进行中
  bool? isShowTasking;

  /// 是否展示任务已完成
  bool? isShowTaskDone;

  VoidCallback? clickItemListener;

  HomeRewardNormalItemWidget(
      {this.clickTakeTaskListener,
      this.taskDesc,
      this.data,
      this.process,
      this.isShowTakeTask,
      this.isShowTasking,
      this.isShowTaskDone,
      this.clickItemListener});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickItemListener != null) {
          clickItemListener!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
                margin: EdgeInsets.only(left: 0, right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: (isShowTakeTask ?? false) || (isShowTaskDone ?? false) ? 70 : 0),
                      child: Text(
                        taskDesc ?? "",
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      data ?? "",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      process ?? "",
                      style: TextStyle(color: Color(0xFFFE6600), fontSize: 12),
                    ),
                  ],
                )),
            Positioned(
              child: Visibility(
                visible: isShowTakeTask ?? false,
                child: InkWell(
                  onTap: () {
                    if (clickTakeTaskListener != null) {
                      clickTakeTaskListener!();
                    }
                  },
                  child: Image.asset(
                    "images/icon_home_reward_task.png",
                    width: 70,
                  ),
                ),
              ),
              right: 12,
            ),
            Positioned(
              child: Visibility(
                visible: isShowTaskDone ?? false,
                child: Image.asset(
                  "images/icon_reward_done.png",
                  height: 26,
                ),
              ),
              right: 0,
              bottom: 0,
            ),
            Positioned(
              child: Visibility(
                visible: isShowTasking ?? false,
                child: Image.asset(
                  "images/icon_reward_ing.png",
                  height: 26,
                ),
              ),
              right: 0,
              bottom: 0,
            )
          ],
        ),
      ),
    );
  }
}

/// 进阶奖励任务
class HomeRewardAdvancedItemWidget extends StatelessWidget {
  /// 是否展示领取任务
  bool? isShowTakeTask;

  /// 是否展示任务进行中
  bool? isShowTasking;

  /// 是否展示任务已完成
  bool? isShowTaskDone;

  /// 领取任务点击事件
  VoidCallback? clickTakeTaskListener;

  /// 任务描述
  String? taskDesc;

  HomeReward? homeReward;

  VoidCallback? clickItemListener;

  HomeRewardAdvancedItemWidget(
      {this.isShowTakeTask, this.isShowTasking, this.isShowTaskDone, this.clickTakeTaskListener, this.taskDesc, this.homeReward, this.clickItemListener});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (clickItemListener != null) {
          clickItemListener!();
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: 12, top: 16, bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Text(
                  taskDesc ?? "",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
                )),
                Visibility(
                  visible: isShowTakeTask ?? true,
                  child: InkWell(
                    onTap: () {
                      if (clickTakeTaskListener != null) {
                        clickTakeTaskListener!();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Image.asset(
                        "images/icon_home_reward_task.png",
                        width: 70,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowTaskDone ?? false,
                  child: Image.asset(
                    "images/icon_reward_done.png",
                    height: 26,
                  ),
                ),
                Visibility(
                  visible: isShowTasking ?? false,
                  child: Image.asset(
                    "images/icon_reward_ing.png",
                    height: 26,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              "${homeReward?.startDate}-${homeReward?.endDate}",
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
            SizedBox(
              height: 6,
            ),
            HomeRewardProgressWidget(
              configModel: homeReward?.configModel,
              isComplete: homeReward?.taskDrawStatus == 3,
              homeReward: homeReward,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeRewardProgressWidget extends StatelessWidget {
  ConfigModel? configModel;
  double? progress;
  bool? isComplete;
  HomeReward? homeReward;

  HomeRewardProgressWidget({this.configModel, this.isComplete, this.homeReward});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      margin: EdgeInsets.only(right: 0),
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: ListView(
                padding: EdgeInsets.only(right: 12),
                scrollDirection: Axis.horizontal,
                children: creatGradientList(context),
              )),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )),
              ))
        ],
      ),
    );
  }

  creatGradientList(BuildContext context) {
    int position = 0;
    List<Widget> list = [];
    if (configModel != null && configModel!.configModelList != null) {
      int finishProgress = homeReward?.finishProgress ?? 0;
      int preProgress = 0;
      for (ConfigModelList configModelList in configModel!.configModelList) {
        if (finishProgress >= configModelList.standardValue) {
          progress = 1;
          preProgress = configModelList.standardValue;
        } else if (finishProgress > preProgress) {
          progress = 0.5;
          preProgress = configModelList.standardValue;
        } else {
          progress = 0;
        }

        String progressUnit = _getUnitStr(configModel);

        list.add(createGradient(position == 0, progress ?? 0, configModelList.standardValue.toString(), progressUnit, configModelList.awardAmount.toString(),
            progress == 1, "累计${homeReward?.finishProgress}${_getUnitStr(configModel)}", context, configModel!.configModelList.length));
        position += 1;
      }
    }
    return list;
  }

  _getUnitStr(ConfigModel? configModel) {
    String progressUnit = "个";
    if (configModel != null) {
      if (configModel.ruleType == "SINGLE_CASE") {
        progressUnit = "个";
      } else if (configModel.ruleType == "DONATE_NUM") {
        progressUnit = "单";
      }
    }
    return progressUnit;
  }

  /// 生成红包梯度
  /// isShowTopTakeTask 是否展示顶部速领任务icon
  /// progress 完成进度(0-1)
  /// max 该梯度最大值（案例数或捐单数）
  /// unit 单位（案例：个 ；捐单：单）
  /// red 红包数值
  /// hasGet  该红包是否已经获取
  /// finishProgress  已经完成的进度
  createGradient(
      bool isShowTopTakeTask, double progress, String max, String unit, String red, bool hasGet, String finishProgress, BuildContext context, int dataSize) {
    double itemWidth = (Tools.getScreenWidth(context) - 8 * 2 - 8 * 2 - 12 - (2 + 2 / 3) * 42.5) / dataSize + 42.5;
    if (dataSize == 1) {
      itemWidth = Tools.getScreenWidth(context) - 8 * 2 - 8 * 2 - 12 * 2;
    } else if (dataSize == 2) {
      itemWidth = (Tools.getScreenWidth(context) - 8 * 2 - 8 * 2 - 12 * 2) / 2;
    } else {
      itemWidth = (Tools.getScreenWidth(context) - 8 * 2 - 8 * 2 - 12 - (2 + 2 / 3) * 42.5) / 3 + 42.5;
    }
    double itemHeight = 67;

    return Container(
        constraints: BoxConstraints.expand(width: itemWidth, height: itemHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      child: Stack(
                        children: [
                          Positioned(
                              top: 5,
                              child: Opacity(
                                child: Container(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        "images/icon_home_reward_progress_top.png",
                                        height: 21,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 11.toDouble() / 2 - 1.8),
                                        child: Text(
                                          finishProgress ?? "速领任务",
                                          style: TextStyle(color: Color(0xFFFE6600), fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                opacity: (isShowTopTakeTask ?? false) ? 1 : 0,
                              )),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: HomeRewardProgressbar(
                                        progress ?? 0,
                                        leftRadiusEnable: isShowTopTakeTask,
                                      ),
                                      left: 0,
                                      right: 42.5,
                                      bottom: 1,
                                    ),
                                    Positioned(
                                        child: Container(
                                      width: 42.5,
                                      height: 46,
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Image.asset(
                                            hasGet ? "images/icon_home_reward_red_done.png" : "images/icon_home_reward_red.png",
                                            width: 42.5,
                                            height: 46,
                                          ),
                                          Positioned(
                                              top: 5,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 1),
                                                    child: Text(red ?? "",
                                                        style: TextStyle(
                                                          color: hasGet ? Color(0xFFFE6600) : Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        )),
                                                  ),
                                                  Text(
                                                    "滴",
                                                    style: TextStyle(
                                                      color: hasGet ? Color(0xFFFE6600) : Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                    ))
                                  ],
                                  alignment: Alignment.topRight,
                                ),
                                constraints: BoxConstraints.expand(height: 55),
                              ))
                            ],
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Visibility(
                      child: Text(
                        "0${unit}",
                        style: TextStyle(color: isShowTopTakeTask || hasGet ? Color(0xFFFE6600) : Colors.black, fontSize: 10),
                      ),
                      visible: isShowTopTakeTask ?? false,
                    )),
                    Container(
                      alignment: Alignment.center,
                      width: 44,
                      child: Text(
                        "${max}${unit}",
                        style: TextStyle(color: hasGet ? Color(0xFFFE6600) : Colors.black, fontSize: 10),
                      ),
                    )
                  ],
                )
              ],
            ))
          ],
        ));
  }
}

/// 进度条
class HomeRewardProgressbar extends StatefulWidget {
  double progress;

  /// 左侧圆角是否可用
  bool leftRadiusEnable;

  HomeRewardProgressbar(this.progress, {this.leftRadiusEnable: false});

  @override
  State<StatefulWidget> createState() {
    return HomeRewardProgressbarState();
  }
}

class HomeRewardProgressbarState extends State<HomeRewardProgressbar> {
  sdui.Image? imageArrow;
  sdui.Image? imageProgress;
  sdui.Image? imageBg;

  @override
  Widget build(BuildContext context) {
    print("widget.progress 1 = ${widget.progress}");

    return Container(
      height: 36,
      child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
          child: CustomPaint(
            painter: HomeRewardProgressbarCustomPainter(imageArrow, imageProgress, imageBg, widget.progress, widget.leftRadiusEnable),
          )),
    );
  }

  HomeRewardProgressbarState() {
    getImage(
      "images/icon_reward_hj.png",
    ).then((value) {
      imageArrow = value;
    }).then((value) {
      getImage(
        "images/icon_home_reward_progress_red.png",
      ).then((value) {
        imageProgress = value;
        getImage(
          "images/icon_home_reward_prgress_bg.png",
        ).then((value) {
          setState(() {
            imageBg = value;
          });
        });
      });
    });
  }

  Future<sdui.Image> getImage(String asset, {int width = 48, int height = 48}) async {
    ByteData data = await rootBundle.load(asset);
    sdui.Codec codec;
    codec = await sdui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    sdui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void dispose() {
    if (imageBg != null) {
      imageBg!.dispose();
      imageBg = null;
    }
    if (imageArrow != null) {
      imageArrow!.dispose();
      imageArrow = null;
    }
    if (imageProgress != null) {
      imageProgress!.dispose();
      imageProgress = null;
    }
    super.dispose();
  }
}

/// 进度条条画笔
class HomeRewardProgressbarCustomPainter extends CustomPainter {
  Paint? _paint;
  Paint? _paint1;
  sdui.Image? image;
  sdui.Image? imageProgress;
  sdui.Image? imageBg;
  double? progress;
  double? progressHeight = 6;
  double? arrowWidth = 36;
  double? arrowHeight = 36;
  bool? leftRadiusEnable;

  HomeRewardProgressbarCustomPainter(this.image, this.imageProgress, this.imageBg, this.progress, this.leftRadiusEnable) {
    if (progress == null || progress! < 0) {
      progress = 0;
    }

    arrowWidth = 36.toDouble() * 166 / 108;
    print("widget.progress 2 = ${progress}");

    _paint = Paint();
    _paint!.color = Color(0xFFFDF2E9);
    _paint!.style = PaintingStyle.fill;
    _paint!.strokeWidth = 6;
    _paint!.isAntiAlias = true;
    _paint!.strokeCap = StrokeCap.round;

    _paint1 = Paint();
    _paint1!.color = Color(0xFFFE6600);
    _paint1!.style = PaintingStyle.fill;
    _paint1!.isAntiAlias = true;
    _paint1!.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double imageProgressWidth = size.width * progress!;
    bool isDrawArrow = progress! > 0 && progress! < 1;
    bool isFull = progress == 1;
    if (isFull) {
      imageProgressWidth = size.width;
    }

    if (imageBg != null && imageProgress != null && image != null) {
      // 绘制背景进
      canvas.save();
      Rect src = Rect.fromLTWH(0, 0, imageBg!.width.toDouble(), imageBg!.height.toDouble());
      Rect dst = Rect.fromLTWH(0, size.height / 2 - progressHeight! / 2, size.width, progressHeight!);
      canvas.clipRRect(RRect.fromLTRBAndCorners(0, size.height / 2 - progressHeight! / 2, size.width, progressHeight! + size.height / 2 - progressHeight! / 2,
          topLeft: Radius.circular(leftRadiusEnable ?? false ? 3 : 0), bottomLeft: Radius.circular(leftRadiusEnable ?? false ? 3 : 0)));
      canvas.drawImageRect(imageBg!, src, dst, _paint1!);
      canvas.restore();
      canvas.save();

      // 绘制进度
      src = Rect.fromLTWH(0, 0, imageProgress!.width.toDouble(), imageProgress!.height.toDouble());
      dst = Rect.fromLTRB(0, size.height / 2 - progressHeight! / 2, imageProgressWidth, progressHeight! + size.height / 2 - progressHeight! / 2);
      canvas.clipRRect(RRect.fromLTRBAndCorners(
          0, size.height / 2 - progressHeight! / 2, imageProgressWidth, progressHeight! + size.height / 2 - progressHeight! / 2,
          topLeft: Radius.circular(leftRadiusEnable ?? false ? 3 : 0), bottomLeft: Radius.circular(leftRadiusEnable ?? false ? 3 : 0)));
      canvas.drawImageRect(imageProgress!, src, dst, _paint1!);
      canvas.restore();

      // 绘制火箭
      if (isDrawArrow) {
        src = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
        dst = Rect.fromLTRB(imageProgressWidth - arrowWidth! * 2 / 3, size.height / 2 - arrowHeight! / 2 + 4, imageProgressWidth + arrowWidth! / 3,
            arrowHeight! + size.height / 2 - arrowHeight! / 2 + 4);
        canvas.drawImageRect(image!, src, dst, _paint1!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
