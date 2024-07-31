import { notificationManager } from '@kit.NotificationKit';
import { notificationManagement } from './NotificationManager';

class Notification {
  private id: number = 0;
  async enableNotification(){
    try {
      await notificationManager.requestEnableNotification();
    } catch (e) {
      console.info(`enableNotification err ${JSON.stringify(e)}`);
    }
  }

  async publishNotification(notificationRequest: notificationManager.NotificationRequest, group?: string) {
    notificationRequest.id = this.id;
    this.id++;

    if (group) {
      notificationRequest.groupName = group;
    }

    try {
      await notificationManager.publish(notificationRequest);
      console.info(`publish notification success`);
      // 通知管理器添加新通知
      await notificationManagement.addNotification(notificationRequest);
    } catch (err) {
      if (err) {
        console.info(`publishNotification err ${JSON.stringify(err)}`);
      }
    }
  }

  async cancelNotificationById(id: number) {
    try {
      await notificationManager.cancel(id);
      console.info(`cancel success`);
    } catch (err) {
      if (err) {
        console.info(`cancel err ${JSON.stringify(err)}`);
      }
    }
  }

  async cancelAllNotifications() {
    try {
      await notificationManager.cancelAll();
      console.info(`cancel all success`);
    } catch (err) {
      if (err) {
        console.info(`cancel all err ${JSON.stringify(err)}`);
      }
    }
  }
}

export const notification = new Notification();