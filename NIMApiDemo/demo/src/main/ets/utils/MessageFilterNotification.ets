import { V2NIMMessage, V2NIMMessageFilter, V2NIMMessageType } from '@nimsdk/base'

export class MessageFilterNotification implements V2NIMMessageFilter {
  async shouldIgnore(message: V2NIMMessage): Promise<boolean> {
    //if (message.messageType === V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION) {
    //  return true
    //} else {
      return false
    //}
  }
}