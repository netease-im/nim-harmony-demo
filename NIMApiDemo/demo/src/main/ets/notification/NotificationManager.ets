import { notificationManager } from '@kit.NotificationKit';

const NOTIFICATION_TYPE_SIZE = 5;

interface getAllNotificationsResultType {
  groupNotifications: Array<Array<notificationManager.NotificationRequest>>
  countsByType: Array<number>
}

class NotificationManager {
  typeNotifications: Array<Array<notificationManager.NotificationRequest>> = new Array(NOTIFICATION_TYPE_SIZE + 1);
  countsByType: Array<number> = new Array(NOTIFICATION_TYPE_SIZE + 1);
  badgeNum: number = 0;

  public constructor() {
    this.countsByType.fill(0);
    for (let i = 0; i < NOTIFICATION_TYPE_SIZE + 1; i++) {
      this.typeNotifications[i] = new Array();
    }
    // 获取当前应用所有通知
    notificationManager.getActiveNotifications().then((notifications) => {
      for (let i = 0; i < notifications.length; i++) {
        let typeId = notifications[i].content.notificationContentType;
        this.countsByType[typeId as number] += 1;
        this.typeNotifications[typeId as number].push(notifications[i]);
      }
      // 计算角标数量
      this.countsByType.forEach((num: number) => {
        this.badgeNum += num;
      })
    })
  }
  // 取消属于该类型的通知
  cancelNotificationType(typeId: number) {
    this.typeNotifications[typeId].forEach(item => {
      notificationManager.cancel(item.id);
    })
  }


  // 获取角标数量
  getBadgeNumber(): number {
    return this.badgeNum;
  }

  // 设置角标
  async setBadgeNumber(num: number) {
    await notificationManager.setBadgeNumber(num).then(() => {
      this.badgeNum = num;
    });
  }
  // 添加一条消息
  async addNotification(notification: notificationManager.NotificationRequest) {
    const typeId: notificationManager.ContentType = notification.content.contentType as notificationManager.ContentType;
    this.typeNotifications[typeId].push(notification);
    this.countsByType[typeId] += 1;
    this.badgeNum += 1;
    await this.setBadgeNumber(this.badgeNum);
  }

  // 获取当前所有消息及数量
  async getAllNotifications() {
    let result: getAllNotificationsResultType = {
      groupNotifications: this.typeNotifications,
      countsByType: this.countsByType
    }
    return result;
  }
}

export const notificationManagement = new NotificationManager();