import {
  V2NIMChatroomClient,
  V2NIMChatroomEnterParams,
  V2NIMChatroomEnterResult,
  V2NIMChatroomInitParams,
  V2NIMChatroomStatus,
  V2NIMChatroomKickedInfo
} from '@nimsdk/chatroom'
import { common } from '@kit.AbilityKit'
import { V2NIMChatroomInfo } from '@nimsdk/chatroom/Index'
import { V2NIMError } from '@nimsdk/base'

class NIMChatroom {
  newInstance(context: common.Context, appKey?: string, customClientType?: number): V2NIMChatroomClient {

    let initParams: V2NIMChatroomInitParams = {
      appkey: appKey ?? "45c6af3c98409b18a84451215d0bdd6e",
      customClientType: customClientType ?? 10
    }

    return V2NIMChatroomClient.newInstance(context, initParams)
  }

  getInstance(instanceId: number): V2NIMChatroomClient {
    return V2NIMChatroomClient.getInstance(instanceId)
  }

  getInstanceList(): V2NIMChatroomClient[] {
    return V2NIMChatroomClient.getInstanceList()
  }

  destroyInstance(instanceId: number) {
    V2NIMChatroomClient.destroyInstance(instanceId)
  }

  destroyAll() {
    V2NIMChatroomClient.destroyAll()
  }

  async enter(instanceId: number,
    roomId: string,
    accountId: string,
    roomNick: string,
    roomAvatar: string,
    token: string,
    linkAddress: string[],
    serverExtension: string,
    notificationExtension: string,
    tags: string[],
    notifyTargetTags: string,
    distance: number,
    x: number,
    y: number,
    z: number): Promise<V2NIMChatroomEnterResult> {
    const client = this.getInstance(instanceId)
    const enterParams: V2NIMChatroomEnterParams = {
      accountId: accountId,
      roomNick: roomNick,
      roomAvatar: roomAvatar,
      token: token,
      linkProvider: () => {
        return Promise.resolve(linkAddress);
      },
      serverExtension: serverExtension,
      notificationExtension: notificationExtension,
      tagConfig: {
        tags: tags,
        notifyTargetTags: notifyTargetTags
      },
      locationConfig: {
        distance: distance,
        locationInfo: {
          x: x,
          y: y,
          z: z
        }
      }
    }

    return await client.enter(roomId, enterParams)
  }

  exit(instanceId: number) {
    const client = this.getInstance(instanceId)
    client.exit()
  }

  getChatroomInfo(instanceId: number): V2NIMChatroomInfo | null {
    const client: V2NIMChatroomClient = this.getInstance(instanceId)
    const ret = client.getChatroomInfo()
    return ret
  }

  getChatroomService(instanceId: number) {
    const client: V2NIMChatroomClient = this.getInstance(instanceId)
    const ret = client.chatroomService
    return ret
  }

  on(instanceId: number) {
    const chatroom = this.getInstance(instanceId)
    chatroom.on("onChatroomStatus", (status: V2NIMChatroomStatus, err?: V2NIMError) => {

    })
    chatroom.on("onChatroomEntered", () => {

    })
    chatroom.on("onChatroomExited", (err?: V2NIMError) => {

    })
    chatroom.on("onChatroomKicked", (kickedInfo: V2NIMChatroomKickedInfo) => {

    })
  }

  off(instanceId: number) {
    const chatroom = this.getInstance(instanceId)
    chatroom.off("onChatroomStatus", (status: V2NIMChatroomStatus, err?: V2NIMError) => {

    })
    chatroom.off("onChatroomEntered", () => {

    })
    chatroom.off("onChatroomExited", (err?: V2NIMError) => {

    })
    chatroom.off("onChatroomKicked", (kickedInfo: V2NIMChatroomKickedInfo) => {

    })
  }
}

export default new NIMChatroom()