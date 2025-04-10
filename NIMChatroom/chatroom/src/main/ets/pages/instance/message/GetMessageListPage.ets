import { V2NIMError, V2NIMMessageType, V2NIMQueryDirection } from '@nimsdk/base'
import { V2NIMChatroomClient, V2NIMChatroomMessage } from '@nimsdk/chatroom'
import { CommonConstants, shownDialog } from '../../../constants/CommonConstants'
import { Router } from '@kit.ArkUI'
import { RouterParams } from '../../ChatroomInstancePage'
import NIMChatroom from '../../../sdk/chatroom'
import { V2NIMChatroomMessageListOption } from '@nimsdk/chatroom'
import { HashSet } from '@kit.ArkTS'

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor($r('app.color.background'))
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT)
  .height($r('app.float.line_height'))
  .backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct GetMessagesListPage {
  @State text: string = '';
  @State queryDirection: V2NIMQueryDirection | undefined = undefined;
  @State messageTypes: HashSet<V2NIMMessageType> | undefined = undefined;
  @State beginTime: number | undefined = undefined;
  @State limit: number | undefined = undefined;
  private messages: V2NIMChatroomMessage[] = []
  scroller: Scroller = new Scroller();

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }
    .height($r('app.float.other_login_image_size'))
    .width($r('app.float.other_login_image_size'))
    .backgroundColor($r('app.color.background'))
  }

  async sendMessage(): Promise<void> {
    try {
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
      let message: V2NIMChatroomMessage = messageCreator.createCustomMessage(`{"1":"1"}`)
      const result = await chatroomService.sendMessage(message)
      this.messages.push(result.message)
      shownDialog(true, JSON.stringify(result.message, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async getMessage(): Promise<void> {
    try {
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const option: V2NIMChatroomMessageListOption = {
        direction: this.queryDirection,
        messageTypes: this.messageTypes ? Array.from(this.messageTypes) : undefined,
        beginTime: this.beginTime,
        limit: this.limit
      }
      const messageList: V2NIMChatroomMessage[] = await chatroomService.getMessageList(option)
      shownDialog(true, JSON.stringify(messageList, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('GetMessageList')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('get message list')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

            TextInput({ placeholder: `send message text ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.text = value;
              })
            Line().lineStyle()

            Text('Direction')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'desc', group: 'directionGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.queryDirection = V2NIMQueryDirection.V2NIM_QUERY_DIRECTION_DESC
                  }
                })
              Text('Desc')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'asc', group: 'directionGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.queryDirection = V2NIMQueryDirection.V2NIM_QUERY_DIRECTION_ASC
                  }
                })
              Text('Asc')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Line().lineStyle()

            // message types
            Text('message types')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            // 全选按钮
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              CheckboxGroup({ group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((itemName: CheckboxGroupResult) => {
                  console.info("checkbox group content" + JSON.stringify(itemName))
                })
              Text('全选')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'TEXT', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_TEXT)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_TEXT)
                  }
                })
              Text('TEXT')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })


            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'IMAGE', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_IMAGE)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_IMAGE)
                  }
                })
              Text('IMAGE')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'AUDIO', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_AUDIO)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_AUDIO)
                  }
                })
              Text('AUDIO')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'VIDEO', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_VIDEO)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_VIDEO)
                  }
                })
              Text('VIDEO')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'LOCATION', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_LOCATION)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_LOCATION)
                  }
                })
              Text('LOCATION')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'NOTIFICATION', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION)
                  }
                })
              Text('NOTIFICATION')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'FILE', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_FILE)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_FILE)
                  }
                })
              Text('FILE')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'AVCHAT', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_AVCHAT)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_AVCHAT)
                  }
                })
              Text('AVCHAT')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'TIPS', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_TIPS)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_TIPS)
                  }
                })
              Text('TIPS')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'ROBOT', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_ROBOT)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_ROBOT)
                  }
                })
              Text('ROBOT')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'CALL', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_CALL)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_CALL)
                  }
                })
              Text('CALL')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'CUSTOM', group: 'checkboxGroupMessageType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.messageTypes === 'undefined') {
                    this.messageTypes = new HashSet<V2NIMMessageType>()
                  }
                  if (on) {
                    this.messageTypes.add(V2NIMMessageType.V2NIM_MESSAGE_TYPE_CUSTOM)
                  } else {
                    this.messageTypes.remove(V2NIMMessageType.V2NIM_MESSAGE_TYPE_CUSTOM)
                  }
                })
              Text('CUSTOM')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Line().lineStyle()

            TextInput({ text: this.beginTime?.toString(), placeholder: `beginTime` })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.beginTime = parseInt(value)
              })
            Line().lineStyle()

            TextInput({ text: this.limit?.toString(), placeholder: `limit` })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.limit = parseInt(value)
              })
            Line().lineStyle()


            Button(('send'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
              .onClick(() => {
                this.sendMessage();
              })

            Button(('get message '), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
              .onClick(() => {
                this.getMessage();
              })
            Blank()
          }
          .backgroundColor($r('app.color.background'))
          .width(CommonConstants.FULL_PARENT)
          .padding({
            left: $r('app.float.page_padding_hor'),
            right: $r('app.float.page_padding_hor'),
            bottom: $r('app.float.login_page_padding_bottom')
          })
        }
      }
      .size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 })
      .title('back')
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }

  private getInstanceFromRouter(): V2NIMChatroomClient {
    let router: Router = this.getUIContext().getRouter();
    const instanceId: number = (router.getParams() as RouterParams).routerInstanceId;
    return NIMChatroom.getInstance(instanceId)
  }
}

function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ?
    JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}