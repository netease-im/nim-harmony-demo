import { notificationManager } from '@kit.NotificationKit';

interface NotificationRequestResultType {
  slotType: notificationManager.SlotType,
  id: number, // 通知id，默认为1
  content: notificationManager.NotificationContent
}


class NotificationRequest {
  createNotificationRequest(notificationContent: notificationManager.NotificationContent) {
    const result: NotificationRequestResultType = {
      slotType: notificationManager.SlotType.CONTENT_INFORMATION,
      id: 1, // 通知id，默认为1
      content: notificationContent
    }
    return result;
  }
}

export let notificationRequest= new NotificationRequest();