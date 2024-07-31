import { notificationManager } from '@kit.NotificationKit';
import { notification } from './Notification';
import { notificationContent } from './NotificationContent';
import { notificationRequest } from './NotificationRequest';
import { image } from '@kit.ImageKit';

interface NOTIFICATION_GROUP_TYPE {
  BASIC: string
  LONG_TEXT: string
  MULTI_LINE: string
  PICTURE: string
  CONVERSATION: string
}

const NOTIFICATION_GROUP: NOTIFICATION_GROUP_TYPE = { // 定义不同类型通知的通知组
  BASIC: 'BASIC',
  LONG_TEXT: 'LONG_TEXT',
  MULTI_LINE: 'MULTI_LINE',
  PICTURE: 'PICTURE',
  CONVERSATION: 'CONVERSATION'
}


export default class NotificationOperations {
  private context: Context;
  private basicContent: notificationManager.NotificationBasicContent;

  constructor(context: Context) {
    this.context = context;
    let notificationTitle = '';
    let notificationText = '通知内容';
    let notificationAdditional = '通知添加内容';
    this.basicContent = {
      title: notificationTitle,
      text: notificationText,
      additionalText: notificationAdditional
    }
  }

  // 发布基本类型通知
  publishBasicNotification = (title: string, text: string) => {
    try {
      console.info('publishBasicNotification');
      this.basicContent.title = title;
      this.basicContent.text = text;
      let ncontent = notificationContent.creatBasicContent(this.basicContent);
      notification.publishNotification(notificationRequest.createNotificationRequest(ncontent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      console.info(`publishBasicNotification error, error = ${JSON.stringify(error)}`);
    }
  }

  // 发布长文本类型通知
  publishLongTextNotification = (title: string, longText: string, brief: string, expanded: string) => {
    try {
      console.info('publishLongTextNotification');
      this.basicContent.title = title;
      let notificationLongText = longText;
      let notificationBriefText = brief;
      let notificationExpandedText = expanded;
      let nContent = notificationContent.creatLongTextContent(this.basicContent, notificationLongText, notificationBriefText, notificationExpandedText);
      notification.publishNotification(notificationRequest.createNotificationRequest(nContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      console.info(`publishLongTextNotification error, error = ${JSON.stringify(error)}`);
    }
  }
  // 发布多行文本类型通知
  publishMultiLineNotification = (title: string, brief: string, longTitle: string, multiContent: string[]) => {
    try {
      console.info('publishMultiLineNotification');
      this.basicContent.title = title;
      let notificationBriefText = brief;
      let notificationLongTitle = longTitle;
      let nContent = notificationContent.creatMultiLineContent(this.basicContent, notificationBriefText, notificationLongTitle, multiContent);
      notification.publishNotification(notificationRequest.createNotificationRequest(nContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      console.info(`publishMultiLineNotification error, error = ${JSON.stringify(error)}`);
    }
  }
  // 发布图片类型通知
  publishPictureNotification = async (title: string, brief: string, longTitle: string, imageArray: ArrayBuffer)  => {
    try {
      console.info('publishPictureNotification');
      this.basicContent.title = title;
      let notificationBriefText = brief;
      let notificationExpandedText = longTitle;
      let imageResource = image.createImageSource(imageArray as ArrayBuffer);
      let picture = await imageResource.createPixelMap();
      let nContent = notificationContent.creatPictureContent(this.basicContent, notificationBriefText, notificationExpandedText, picture);
      notification.publishNotification(notificationRequest.createNotificationRequest(nContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      console.info(`publishPictureNotification error, error = ${JSON.stringify(error)}`);
    }
  }
  // 发布社交类型的通知
  publishConversationNotification = async (title: string) => {
    try {
      console.info('publishConversationNotification');
      this.basicContent.title = title;
      let nContent = notificationContent.createConversationContent(this.basicContent);
      notification.publishNotification(notificationRequest.createNotificationRequest(nContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest, NOTIFICATION_GROUP.CONVERSATION);
    } catch (error) {
      console.info(`publishNotificationWithWantAgent error, error = ${JSON.stringify(error)}`);
    }
  }
}