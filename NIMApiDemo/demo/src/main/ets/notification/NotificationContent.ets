import { notificationManager } from '@kit.NotificationKit';
import { image } from '@kit.ImageKit';

interface NotificationContentResultType {
  contentType: notificationManager.ContentType
  normal?: notificationManager.NotificationBasicContent
  longText?: notificationManager.NotificationLongTextContent
  multiLine?: notificationManager.NotificationMultiLineContent
  picture?: notificationManager.NotificationPictureContent
}

class NotificationContent {

  creatBasicContent(basicContent: notificationManager.NotificationBasicContent) {
    const result: NotificationContentResultType = {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 通知内容类型
      normal: basicContent // 基本类型通知内容
    }
    return result;
  }

  creatLongTextContent(basicContent: notificationManager.NotificationBasicContent, notificationLongText: string, notificationBriefText: string, notificationExpandedTitle: string) {
    const result: NotificationContentResultType = {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT, // 通知内容类型
      longText: {
        title: basicContent.title, // 通知标题
        text: basicContent.text, // 通知内容
        additionalText: basicContent.additionalText ? basicContent.additionalText : '', // 通知次要内容
        longText: notificationLongText, // 通知的长文本
        briefText: notificationBriefText, // 通知概要内容，是对通知内容的总结
        expandedTitle: notificationExpandedTitle // 通知展开时的标题
      }
    };
    return result;
  }

  creatMultiLineContent(basicContent: notificationManager.NotificationBasicContent, notificationBriefText: string, notificationLongTitle: string, notificationLines: Array<string>) {
    const result: NotificationContentResultType = {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_MULTILINE, // 通知内容类型
      multiLine: {
        title: basicContent.title, // 通知标题
        text: basicContent.text, // 通知内容
        additionalText: basicContent.additionalText ? basicContent.additionalText : '', // 通知次要内容，是对通知内容的补充
        briefText: notificationBriefText, // 通知概要内容，是对通知内容的总结
        longTitle: notificationLongTitle, // 通知展开时的标题
        lines: notificationLines // 通知的多行文本
      }
    };
    return result;
  }

  creatPictureContent(basicContent: notificationManager.NotificationBasicContent,
    notificationBriefText: string,
    notificationExpandedTitle: string,
    notificationPicture: image.PixelMap) {
    const result: NotificationContentResultType = {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_PICTURE, // 通知内容类型
      picture: {
        title: basicContent.title, // 通知标题
        text: basicContent.text, // 通知内容
        additionalText: basicContent.additionalText ? basicContent.additionalText : '', // 通知次要内容，是对通知内容的补充
        briefText: notificationBriefText, // 通知概要内容，是对通知内容的总结
        expandedTitle: notificationExpandedTitle, // 通知展开时的标题
        picture: notificationPicture // 通知的图片
      }
    };
    return result;
  }

  createConversationContent(basicContent: notificationManager.NotificationBasicContent) {
    const result: NotificationContentResultType = {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_CONVERSATION, // 通知内容类型
      normal: basicContent // 基本类型通知内容
    };
    return result;
  }
}

export const notificationContent = new NotificationContent();