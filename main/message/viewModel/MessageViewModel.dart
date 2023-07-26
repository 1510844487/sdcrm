class MessageViewModel {
  static String transformContent(String content) {
    if (content.contains("\r\n</a>")) {
      content.replaceAll("\r\n</a>", "</a>");
    }
    return content;
  }

  static List<RichTextModel> transformRichContent(String content) {
    List<RichTextModel> list = [];
    String trContent = content;

    try {
      while (trContent.endsWith("\n")) {
        int stringIndex = trContent.lastIndexOf("\n");
        trContent = trContent.substring(0, stringIndex);
      }

      while (trContent.startsWith("\n")) {
        trContent = trContent.substring("\n".length);
      }

      List<String> array = trContent.split("<a href=\"");

      if (trContent.startsWith("<a href=\"")) {
        return traverseLinkListFromStart(array, trContent, list);
      } else {
        if (array.length == 0 || array.length == 1) {
          RichTextModel model = RichTextModel();
          model.content = trContent;
          model.isRich = false;
          list.add(model);
          return list;
        }

        RichTextModel model = RichTextModel();
        model.content = array[0];
        model.isRich = false;
        list.add(model);

        return traverseLinkList(array, list);
      }
    } catch (e) {}

    return list;
  }

  static List<RichTextModel> traverseLinkList(List<String> array, List<RichTextModel> list) {
    for (var i = 1; i < array.length; i++) {
      RichTextModel richModel = RichTextModel();

      if (array[i].contains("\">")) {
        richModel.isRich = true;
        List splitArray = array[i].split("\">");
        if (splitArray.isNotEmpty) {
          richModel.link = splitArray[0];
          if (splitArray.length > 1) {
            if (splitArray[1].contains("</a>")) {
              List nameArray = splitArray[1].split("</a>");
              if (nameArray.isNotEmpty) {
                richModel.content = nameArray[0];
                if (nameArray.length > 1) {
                  list.add(richModel);
                  RichTextModel model = RichTextModel();
                  model.content = nameArray[1];
                  model.isRich = false;
                  list.add(model);
                }
              }
            } else {
              richModel.isRich = false;
              richModel.link = "";
              richModel.content = splitArray[1];
              list.add(richModel);
            }
          } else {
            list.add(richModel);
          }
        }
      } else {
        richModel.isRich = false;
        richModel.content = "<a href=\"" + array[i];
        list.add(richModel);
      }
    }
    return list;
  }

  static List<RichTextModel> traverseLinkListFromStart(List<String> array, String trContent, List<RichTextModel> list) {
    for (var i = 0; i < array.length; i++) {
      RichTextModel richModel = RichTextModel();

      if (array[i].contains("\">")) {
        richModel.isRich = true;

        List splitArray = array[i].split("\">");
        if (splitArray.isNotEmpty) {
          richModel.link = splitArray[0];
          if (splitArray.length > 1) {
            if (splitArray[1].contains("</a>")) {
              List nameArray = splitArray[1].split("</a>");
              if (nameArray.isNotEmpty) {
                richModel.content = nameArray[0];
                if (nameArray.length > 1) {
                  list.add(richModel);

                  RichTextModel model = RichTextModel();
                  model.content = nameArray[1];
                  model.isRich = false;
                  list.add(model);
                }
              }
            } else {
              richModel.isRich = false;
              richModel.link = "";
              richModel.content = splitArray[1];
              list.add(richModel);
            }
          } else {
            list.add(richModel);
          }
        }
      } else {
        if (i != 0) {
          richModel.isRich = false;
          richModel.content = "<a href=\"" + array[i];
          list.add(richModel);
        }
      }
    }
    return list;
  }
}

class RichTextModel {
  String? content;
  bool isRich = false;
  String? link;
}
