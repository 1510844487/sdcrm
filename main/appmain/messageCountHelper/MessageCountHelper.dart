import 'package:fluttercrmmodule/data/net/NetImp.dart';
import 'package:sd_flutter_base/module/net/SDResponse.dart';

class MessageCountHelper {

  static Future<bool> requestReadedAllMessage() async {
    SDResponse<bool> response = await NetImp.setReadedAllMessage();
    return response.isSuccess();
  }

  static Future<int> requestUnReadMessageCount() async {
    SDResponse<int> response = await NetImp.fetchUnReadMessageCount();
    return response.module ?? 0;
  }
}
