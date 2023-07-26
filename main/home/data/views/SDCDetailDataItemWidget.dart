import 'package:flutter/cupertino.dart';
import 'package:fluttercrmmodule/GlobalConst/SDColor.dart';

class SDCDetailDataItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 12, bottom: 12),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          "玉溪分区一区",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: SDColor.black),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "122002",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: SDColor.black),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "76",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: SDColor.black),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "70",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: SDColor.black),
                        ),
                      )),
                  Container(
                      child: Image.asset("images/home_data_fire.png",
                          width: 10, height: 12)),
                  Container(
                    child: Text(
                      "2",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: SDColor.black),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          "                ",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                              color: SDColor.black),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "+200(+5%)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.normal,
                              color: SDColor.red),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "+20(+50%)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.normal,
                              color: SDColor.red),
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          "+20(+50%)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.normal,
                              color: SDColor.green),
                        ),
                      )),
                  Container(width: 10, height: 12),
                  Container(height: 12),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            )
          ],
        ));
  }
}
