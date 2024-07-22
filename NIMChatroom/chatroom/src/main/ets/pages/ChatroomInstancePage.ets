import ClassifyModel from '../viewmodel/ClassifyModel';
import ClassifyViewModel, { LinkDataType } from '../viewmodel/ClassifyViewModel';
import { CommonConstants as Constants, shownDialog, shownListenerDialog } from '../constants/CommonConstants';
import FunctionalModel from '../viewmodel/CourseModel';
import CourseItem from '../view/CourseItem';
import ClassifyItem from '../view/ClassityItem';
import { router } from '@kit.ArkUI';
import { V2NIMChatroomClient,
  V2NIMChatroomInfo,
  V2NIMChatroomKickedInfo,
  V2NIMChatroomMember,
  V2NIMChatroomMemberRole,
  V2NIMChatroomMessage,
  V2NIMChatroomStatus} from '@nimsdk/chatroom';
import NIMChatroom from '../sdk/chatroom'
import { V2NIMError } from '@nimsdk/base';

@Entry
@Component
export struct ChatroomInstancePage {
  @State currentClassify: number = 0; // selected classify index.
  @State requestSuccess: boolean = false; // is loading data.
  @State instanceId: number = 1; // 聊天室实例号
  private classifyList: Array<ClassifyModel> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    // loading data.
    setTimeout(() => {
      this.classifyList = ClassifyViewModel.getLinkData(LinkDataType.MESSAGE);
      this.requestSuccess = true;
    }, Constants.LOADING_DURATION);
    // this.addListener()
  }

  @Builder
  ClassifyHeader(classifyName: string) {
    Row() {
      Text(classifyName)
        .fontSize($r('app.float.header_font_size'))
        .fontColor($r('app.color.base_font_color'))
        .fontFamily($r('app.string.hei_ti_medium'))
        .fontWeight(Constants.TITLE_FONT_WEIGHT)
    }
    .padding({
      left: $r('app.float.item_padding_left')
    })
    .height($r('app.float.classify_item_height'))
    .width(Constants.FULL_WIDTH_PERCENT)
    .backgroundColor($r('app.color.background'))
  }

  classifyChangeAction(index: number, isClassify: boolean) {
    if (this.currentClassify !== index) {
      // change the classify status.
      this.currentClassify = index;
      if (isClassify) {
        // scroll the course scroll.
        this.scroller.scrollToIndex(index);
      } else {
        // scroll the classify scroll.
        this.classifyScroller.scrollToIndex(index);
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text("聊天室实例号")
          .fontSize($r('app.float.header_font_size'))
          .fontColor($r('app.color.base_font_color'))
          .fontFamily($r('app.string.hei_ti_medium'))
          .fontWeight(Constants.TITLE_FONT_WEIGHT)
          .margin({
            left: $r('app.float.item_padding_left'),
            top: $r('app.float.item_padding_top'),
            bottom: $r('app.float.item_padding_bottom')
          })
        TextInput({ placeholder: this.instanceId.toString() })
          .type(InputType.Number)
          .width('50vp')
          .onChange((value: string) => {
            this.instanceId = Number.parseInt(value);
          })
          .margin({
            left: $r('app.float.item_padding_left'),
            top: $r('app.float.item_padding_top'),
            bottom: $r('app.float.item_padding_bottom')
          })
      }

      Row() {
        Text("Listener")
          .fontSize($r('app.float.header_font_size'))
          .fontColor($r('app.color.base_font_color'))
          .fontFamily($r('app.string.hei_ti_medium'))
          .fontWeight(Constants.TITLE_FONT_WEIGHT)
          .margin({
            left: $r('app.float.item_padding_left'),
            top: $r('app.float.item_padding_top'),
            bottom: $r('app.float.item_padding_bottom')
          })
        Button('ON', { type: ButtonType.Capsule, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .width(60)
          .height(40)
          .onClick(() => {
            // add all listener
            try {
              this.addMyListener()
              shownDialog(true, `AddMyListener. \nChatroom instance: ${this.instanceId}`)
            } catch (e) {
              shownDialog(false, `AddMyListener. \nChatroom instance: ${this.instanceId} \nError: ${JSON.stringify(e)}`)
            }
          })
          .margin({
            left: $r('app.float.item_padding_left'),
            top: $r('app.float.item_padding_top'),
            bottom: $r('app.float.item_padding_bottom')
          })
        Button('OFF', { type: ButtonType.Capsule, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .width(60)
          .height(40)
          .onClick(() => {
            // remove all listener
            try {
              this.removeMyListener()
              shownDialog(true, `RemoveMyListener. \nChatroom instance: ${this.instanceId}`)
            } catch (e) {
              shownDialog(false, `RemoveMyListener. \nChatroom instance: ${this.instanceId} \nError: ${JSON.stringify(e)}`)
            }
          })
          .margin({
            left: $r('app.float.item_padding_left'),
            top: $r('app.float.item_padding_top'),
            bottom: $r('app.float.item_padding_bottom')
          })

      }

      Row() {
        if (this.requestSuccess) {
          List({ scroller: this.classifyScroller }) {
            ForEach(this.classifyList, (item: ClassifyModel, index?: number) => {
              ListItem() {
                ClassifyItem({
                  classifyName: item.classifyName,
                  isSelected: this.currentClassify === index,
                  onClickAction: () => {
                    if (index !== undefined) {
                      this.classifyChangeAction(index, true);
                    }
                  }
                })
              }
            }, (item: ClassifyModel) => item.classifyName + this.currentClassify)
          }
          .height(Constants.FULL_PARENT)
          .width($r('app.float.classify_item_width'))
          .backgroundColor($r('app.color.classify_background'))
          .scrollBar(BarState.Off)

          List({ scroller: this.scroller }) {
            ForEach(this.classifyList, (classifyItem: ClassifyModel) => {
              ListItemGroup({
                header: this.ClassifyHeader(classifyItem.classifyName),
                space: Constants.COURSE_ITEM_PADDING
              }) {
                ForEach(classifyItem.courseList, (courseItem: FunctionalModel) => {
                  ListItem() {
                    CourseItem({ itemStr: JSON.stringify(courseItem) })
                  }.onClick(event => {
                    console.info(`${courseItem}`)
                    this.apiFunction(courseItem)
                  })
                }, (courseItem: FunctionalModel) => `${courseItem.courseId}`)
              }
            }, (item: ClassifyModel) => `${item.classifyId}`)
          }
          .padding({ left: $r('app.float.item_padding_left'), right: $r('app.float.course_item_padding') })
          .sticky(StickyStyle.Header)
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.None)
          .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
        } else {
          Text($r('app.string.loading'))
            .fontFamily($r('app.string.hei_ti_medium'))
            .textAlign(TextAlign.Center)
            .height(Constants.FULL_PARENT)
            .width(Constants.FULL_PARENT)
        }
      }
      .backgroundColor($r('app.color.background'))
    }
    .backgroundColor($r('app.color.background'))
    .margin( {
      bottom: '100vp'
    })

  }

  apiFunction(courseItem: FunctionalModel) {
    let pageName: string = courseItem.methodName.charAt(0).toUpperCase() + courseItem.methodName.slice(1) + 'Page'
    const url = 'pages/instance/' + courseItem.module + '/' + pageName
    router.pushUrl({
      url: url,
      params: {
        routerInstanceId: this.instanceId
      } as RouterParams
    })
  }

  private getCRInstance(): V2NIMChatroomClient {
    return NIMChatroom.getInstance(this.instanceId)
  }
  private onSendMessageListener = (message: V2NIMChatroomMessage) => {
    this.shownListenerDialogAddInstanceId('onSendMessage', JSON.stringify(message, null, 2))
  }
  private onReceiveMessagesListener = (messages: V2NIMChatroomMessage[]) => {
    this.shownListenerDialogAddInstanceId('onReceiveMessages', JSON.stringify(messages, null, 2))
  }
  private onMessageRevokedNotificationListener = (messageClientId: string, messageTime: number) => {
    this.shownListenerDialogAddInstanceId('onMessageRevokedNotification', JSON.stringify({ messageClientId, messageTime }, null, 2))
  }
  private onChatroomMemberEnterListener = (member: V2NIMChatroomMember) => {
    this.shownListenerDialogAddInstanceId('onChatroomMemberEnter', JSON.stringify(member, null, 2))
  }
  private onChatroomMemberExitListener = (accountId: string) => {
    this.shownListenerDialogAddInstanceId('onChatroomMemberExit', JSON.stringify(accountId, null, 2))
  }
  private onChatroomMemberRoleUpdatedListener = (previousRole: V2NIMChatroomMemberRole, currentMember: V2NIMChatroomMember) => {
    this.shownListenerDialogAddInstanceId('onChatroomMemberRoleUpdated', JSON.stringify({ previousRole, currentMember }, null, 2))
  }
  private onChatroomMemberInfoUpdatedListener = (member: V2NIMChatroomMember) => {
    this.shownListenerDialogAddInstanceId('onChatroomMemberInfoUpdated', JSON.stringify(member, null, 2))
  }
  private onSelfChatBannedUpdatedListener = (chatBanned: boolean) => {
    this.shownListenerDialogAddInstanceId('onSelfChatBannedUpdated', JSON.stringify(chatBanned, null, 2))
  }
  private onSelfTempChatBannedUpdatedListener = (tempChatBanned: boolean, tempChatBannedDuration: number) => {
    this.shownListenerDialogAddInstanceId('onSelfTempChatBannedUpdated', JSON.stringify({ tempChatBanned, tempChatBannedDuration }, null, 2))
  }
  private onChatroomInfoUpdatedListener = (chatroomInfo: V2NIMChatroomInfo) => {
    this.shownListenerDialogAddInstanceId('onChatroomInfoUpdated', JSON.stringify(chatroomInfo, null, 2))
  }
  private onChatroomChatBannedUpdatedListener = (chatBanned: boolean) => {
    this.shownListenerDialogAddInstanceId('onChatroomChatBannedUpdated', JSON.stringify(chatBanned, null, 2))
  }
  private onChatroomTagsUpdatedListener = (tags: Array<string>) => {
    this.shownListenerDialogAddInstanceId('onChatroomTagsUpdated', JSON.stringify(tags, null, 2))
  }
  private onChatroomStatusListener = (status: V2NIMChatroomStatus, error?: V2NIMError) => {
    this.shownListenerDialogAddInstanceId('onChatroomStatus', JSON.stringify({ status, error }, null, 2))
  }
  private onChatroomEnteredListener = () => {
    this.shownListenerDialogAddInstanceId('onChatroomEntered', JSON.stringify({}, null, 2))
  }
  private onChatroomExitedListener = (error?: V2NIMError) => {
    this.shownListenerDialogAddInstanceId('onChatroomExited', JSON.stringify(error, null, 2))
  }
  private onChatroomKickedListener = (kickedInfo: V2NIMChatroomKickedInfo) => {
    this.shownListenerDialogAddInstanceId('onChatroomKicked', JSON.stringify(kickedInfo, null, 2))
  }

  private onChatroomQueueOfferedListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueueOffered', JSON.stringify(keyValues, null, 2))
  }
  private onChatroomQueuePolledListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueuePolled', JSON.stringify(keyValues, null, 2))
  }
  private onChatroomQueueDropedListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueueDroped', JSON.stringify(keyValues, null, 2))
  }
  private onChatroomQueuePartClearedListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueuePartCleared', JSON.stringify(keyValues, null, 2))
  }
  private onChatroomQueueBatchUpdatedListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueueBatchUpdated', JSON.stringify(keyValues, null, 2))
  }
  private onChatroomQueueBatchOfferedListener = (keyValues: Map<string, string>[]) => {
  this.shownListenerDialogAddInstanceId('onChatroomQueueBatchOffered', JSON.stringify(keyValues, null, 2))
  }


  addMyListener() {
    // chatroom client
    this.getCRInstance().on("onChatroomStatus", this.onChatroomStatusListener)
    this.getCRInstance().on("onChatroomEntered", this.onChatroomEnteredListener)
    this.getCRInstance().on("onChatroomExited", this.onChatroomExitedListener)
    this.getCRInstance().on("onChatroomKicked", this.onChatroomKickedListener)

    // chatroom service
    this.getCRInstance().chatroomService.on("onSendMessage", this.onSendMessageListener)
    this.getCRInstance().chatroomService.on("onReceiveMessages", this.onReceiveMessagesListener)
    this.getCRInstance().chatroomService.on("onMessageRevokedNotification", this.onMessageRevokedNotificationListener)
    this.getCRInstance().chatroomService.on("onChatroomMemberEnter", this.onChatroomMemberEnterListener)
    this.getCRInstance().chatroomService.on("onChatroomMemberExit", this.onChatroomMemberExitListener)
    this.getCRInstance().chatroomService.on("onChatroomMemberRoleUpdated", this.onChatroomMemberRoleUpdatedListener)
    this.getCRInstance().chatroomService.on("onChatroomMemberInfoUpdated", this.onChatroomMemberInfoUpdatedListener)
    this.getCRInstance().chatroomService.on("onSelfChatBannedUpdated", this.onSelfChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.on("onSelfTempChatBannedUpdated", this.onSelfTempChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.on("onChatroomInfoUpdated", this.onChatroomInfoUpdatedListener)
    this.getCRInstance().chatroomService.on("onChatroomChatBannedUpdated", this.onChatroomChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.on("onChatroomTagsUpdated", this.onChatroomTagsUpdatedListener)

    // chatroom queue
    this.getCRInstance().queueService.on("onChatroomQueueOffered", this.onChatroomQueueOfferedListener)
    this.getCRInstance().queueService.on("onChatroomQueuePolled", this.onChatroomQueuePolledListener)
    this.getCRInstance().queueService.on("onChatroomQueueDroped", this.onChatroomQueueDropedListener)
    this.getCRInstance().queueService.on("onChatroomQueuePartCleared", this.onChatroomQueuePartClearedListener)
    this.getCRInstance().queueService.on("onChatroomQueueBatchUpdated", this.onChatroomQueueBatchUpdatedListener)
    this.getCRInstance().queueService.on("onChatroomQueueBatchOffered", this.onChatroomQueueBatchOfferedListener)
  }

  removeMyListener() {
    // chatroom client
    this.getCRInstance().off("onChatroomStatus", this.onChatroomStatusListener)
    this.getCRInstance().off("onChatroomEntered", this.onChatroomEnteredListener)
    this.getCRInstance().off("onChatroomExited", this.onChatroomExitedListener)
    this.getCRInstance().off("onChatroomKicked", this.onChatroomKickedListener)
    this.getCRInstance().removeAllListeners()

    // chatroom service
    this.getCRInstance().chatroomService.off("onSendMessage", this.onSendMessageListener)
    this.getCRInstance().chatroomService.off("onReceiveMessages", this.onReceiveMessagesListener)
    this.getCRInstance().chatroomService.off("onMessageRevokedNotification", this.onMessageRevokedNotificationListener)
    this.getCRInstance().chatroomService.off("onChatroomMemberEnter", this.onChatroomMemberEnterListener)
    this.getCRInstance().chatroomService.off("onChatroomMemberExit", this.onChatroomMemberExitListener)
    this.getCRInstance().chatroomService.off("onChatroomMemberRoleUpdated", this.onChatroomMemberRoleUpdatedListener)
    this.getCRInstance().chatroomService.off("onChatroomMemberInfoUpdated", this.onChatroomMemberInfoUpdatedListener)
    this.getCRInstance().chatroomService.off("onSelfChatBannedUpdated", this.onSelfChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.off("onSelfTempChatBannedUpdated", this.onSelfTempChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.off("onChatroomInfoUpdated", this.onChatroomInfoUpdatedListener)
    this.getCRInstance().chatroomService.off("onChatroomChatBannedUpdated", this.onChatroomChatBannedUpdatedListener)
    this.getCRInstance().chatroomService.off("onChatroomTagsUpdated", this.onChatroomTagsUpdatedListener)
    this.getCRInstance().chatroomService.removeAllListeners()

    // chatroom queue
    this.getCRInstance().queueService.off("onChatroomQueueOffered", this.onChatroomQueueOfferedListener)
    this.getCRInstance().queueService.off("onChatroomQueuePolled", this.onChatroomQueuePolledListener)
    this.getCRInstance().queueService.off("onChatroomQueueDroped", this.onChatroomQueueDropedListener)
    this.getCRInstance().queueService.off("onChatroomQueuePartCleared", this.onChatroomQueuePartClearedListener)
    this.getCRInstance().queueService.off("onChatroomQueueBatchUpdated", this.onChatroomQueueBatchUpdatedListener)
    this.getCRInstance().queueService.off("onChatroomQueueBatchOffered", this.onChatroomQueueBatchOfferedListener)
    this.getCRInstance().queueService.removeAllListeners()
  }

  private shownListenerDialogAddInstanceId(title: string, message: string) {
    shownListenerDialog(title, `InstanceId: ${this.instanceId}\n${message}`)
  }
}


export interface RouterParams {
  routerInstanceId: number
}