import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercrmmodule/dialog/HomePageDialogHelper.dart';
import 'package:fluttercrmmodule/pages/bean/CampaignHospitalAreaDetailModel.dart';
import 'package:fluttercrmmodule/pages/bean/OrgList.dart';
import 'package:fluttercrmmodule/pages/common/ElementCode.dart';
import 'package:fluttercrmmodule/utils/Tools.dart';
import 'package:sd_flutter_buriedpoint/SDBuried.dart';

/// 医院发起控件
class SDHospitalDataWidget extends StatefulWidget {
  List<CampaignHospitalAreaDetailModel>? hospitalAreaDetailList;
  List<OrgList>? campaignCityDetailModelList;
  OrgList? choicedOrg;
  List<CityList>? choicedCity;
  ValueChanged<OrgList?>? choicedOrgCallback;
  ValueChanged<List<CityList>?>? choicedCityCallback;

  SDHospitalDataWidget(this.hospitalAreaDetailList, this.campaignCityDetailModelList, this.choicedOrg, this.choicedCity,
      this.choicedOrgCallback, this.choicedCityCallback);

  @override
  State<StatefulWidget> createState() {
    return _SDHospitalDataWidgetState(choicedOrg, choicedCity);
  }
}

class _SDHospitalDataWidgetState extends State<SDHospitalDataWidget> {
  bool isHomeHospitalShowMore = false;
  int num = 10;

  OrgList? initOrg;
  OrgList? choicedOrg;
  List<CityList>? initCity;
  List<CityList>? choicedCity;

  _SDHospitalDataWidgetState(OrgList? initOrg, List<CityList>? initCity) {
    this.initOrg = initOrg;
    this.initCity = initCity;
  }

  int getItemCount() {
    if (widget.hospitalAreaDetailList == null) {
      return 0;
    }
    if (widget.hospitalAreaDetailList!.length > num && isHomeHospitalShowMore) {
      return num;
    }
    return widget.hospitalAreaDetailList!.length;
  }

  bool canShowMore() {
    return widget.hospitalAreaDetailList != null && widget.hospitalAreaDetailList!.length > num;
  }

  @override
  void initState() {
    super.initState();
    if (isHomeHospitalShowMore == null) {
      isHomeHospitalShowMore = canShowMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.hospitalAreaDetailList == null
        ? Container()
        : Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 9),
                  child: Row(
                    children: [
                      Text(
                        "今日医院发起",
                        style: TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () async {
                          Map<String, String> reportParams = await Tools.buildCommonParams();
                          SDBuried.instance().reportImmediately(
                              SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_HOSPITAL_CITY,
                              customParams: reportParams);

                          int choicedCityId = -1;
                          if (choicedCity != null) {
                            if (choicedCity != null && choicedCity!.length == 1) {
                              choicedCityId = choicedCity![0].cityId;
                            } else {
                              choicedCityId = -1;
                            }
                          } else {
                            if (initCity != null && initCity!.length == 1) {
                              choicedCityId = initCity![0].cityId;
                            } else {
                              choicedCityId = -1;
                            }
                          }

                          OrgList? orgList;
                          if (choicedOrg != null) {
                            orgList = choicedOrg!;
                          } else {
                            orgList = initOrg;
                          }

                          HomePageDialogHelper.showChoiceOrgDialog(context, widget.campaignCityDetailModelList ?? [],
                              orgList?.provinceId ?? -1, orgList, choicedCityId, (choicedOrg) {
                            this.choicedOrg = choicedOrg;
                            if (widget.choicedOrgCallback != null) {
                              widget.choicedOrgCallback!(choicedOrg);
                            }
                          }, (choicedCity) {
                            this.choicedCity = choicedCity;
                            if (mounted) {
                              setState(() {});
                            }
                            if (widget.choicedCityCallback != null) {
                              widget.choicedCityCallback!(choicedCity);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 3, bottom: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                choicedCity == null || choicedCity!.length > 1 ? "全部城市" : choicedCity![0].cityName,
                                style: TextStyle(color: Color(0xFFB1B1B1), fontSize: 13),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Image.asset(
                                "images/data_arrow_down.png",
                                width: 12.5,
                              )
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Color(0xFFEDEDED),
                  margin: EdgeInsets.only(left: 12, right: 12),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "医院名称",
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                          ),
                        ),
                        flex: 48 + 112,
                      ),
                      Expanded(
                        child: Text(
                          "发起数量",
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                          ),
                        ),
                        flex: 48 + 20,
                      ),
                      Expanded(
                        child: Text(
                          "对比近8周同期数据",
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                          ),
                        ),
                        flex: 103,
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, postion) {
                    CampaignHospitalAreaDetailModel model = widget.hospitalAreaDetailList![postion];

                    /// 医院名称
                    String hospitalName = model.hospitalName;

                    /// 发起数据
                    String fqCount = "${model.campaignBaseModel.offlineCaseCount}";

                    /// 均值
                    String pt = Tools.formatIntByPre(
                        model.campaignBaseModel.offlineCaseCountAdd, model.campaignBaseModel.offlineCaseCountAddCom);

                    return _SDHospitalDataItemWidget(
                        hospitalName, fqCount, pt, model.campaignBaseModel.offlineCaseCountAdd >= 0);
                  },
                  itemCount: getItemCount(),
                ),
                canShowMore()
                    ? InkWell(
                        onTap: () async {
                          //  点击展开更多按钮
                          if (mounted) {
                            setState(() {
                              isHomeHospitalShowMore = !isHomeHospitalShowMore;
                            });
                          }
                          if (isHomeHospitalShowMore) {
                            Map<String, String> reportParams = await Tools.buildCommonParams();
                            SDBuried.instance().reportImmediately(
                                SDBuriedEvent.click, ElementCode.CODE_HOMEPAGE_CLICK_HOSPITAL_EXPEND,
                                customParams: reportParams);
                          }
                        },
                        child: Container(
                          height: 24,
                          width: 89,
                          margin: EdgeInsets.only(bottom: 15, top: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8), borderRadius: BorderRadius.all(Radius.circular(12))),
                          child: Text(
                            isHomeHospitalShowMore ? "展开更多" : "收起更多",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          );
  }
}

/// 医院发起 条目 控件
class _SDHospitalDataItemWidget extends StatelessWidget {
  /// 医院名称
  String hospitalName;

  /// 发起数据
  String fqCount;

  /// 均值
  String pt;

  bool isAdd;

  _SDHospitalDataItemWidget(this.hospitalName, this.fqCount, this.pt, this.isAdd);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              child: Text(
                hospitalName ?? "",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            flex: 48 + 112,
          ),
          Expanded(
            child: Container(
              child: Text(
                fqCount ?? "",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                ),
              ),
              margin: EdgeInsets.only(top: 2),
            ),
            flex: 48 + 20,
          ),
          Expanded(
            child: Text(
              pt ?? "",
              style: TextStyle(
                color: Color(isAdd ? 0xFFD33F42 : 0xFF459678),
                fontSize: 12,
              ),
            ),
            flex: 103,
          ),
        ],
      ),
    );
  }
}
