import { fileIo } from '@kit.CoreFileKit';

import {
  NIMEStrAnyObj,
  V2NIMConversationType,
  V2NIMError,
  V2NIMMessage,
  V2NIMMessageAttachment,
  V2NIMMessageFileAttachment,
  V2NIMMessagePushConfig,
  V2NIMSendMessageParams,
  V2NIMSendMessageResult
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
// import { PictureFiles } from '../../../message/view/PictureFiles';
import { UserModel } from '../../../viewmodel/UserModel';

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
struct ConverterTextMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State pictureUri: string = ''
  @State pushPayload: string = ''
  @State configUnreadEnable: boolean = true
  private message: V2NIMMessage | undefined;
  private messageSerialization: string = ''

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }
    .height($r('app.float.other_login_image_size'))
    .width($r('app.float.other_login_image_size'))
    .backgroundColor($r('app.color.background'))
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  async sendTextMessage(): Promise<void> {
    try {
      console.info(`-----------sendTextMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createTextMessage(this.text)

      // add push payload
      if (!message.pushConfig) {
        message.pushConfig = {} as V2NIMMessagePushConfig
      }

      message.pushConfig.pushEnabled = true
      message.pushConfig.pushNickEnabled =  true
      message.pushConfig.pushContent = 'y'
      message.pushConfig.pushPayload = this.pushPayload
      //
      message.pushConfig.forcePush = false
      message.pushConfig.forcePushAccountIds = []
      message.pushConfig.forcePushContent = 'y'

      //message.pushConfig.forcePushAccountIds = []
      // {
      //   "harmonyField": {
      //     "pushOptions": {
      //       "testMessage": true
      //     },
      //     "payload": {
      //       "notification": {
      //         "badge": {
      //           "addNum": 1
      //         }
      //       }
      //     }
      //   }
      // }`
      //const jsonObject: NIMEStrAnyObj = JSON.parse(message.pushConfig.pushPayload);

      // messageConfig
      if (message.messageConfig) {
        // set messageConfig.unreadEnabled
        message.messageConfig.unreadEnabled = this.configUnreadEnable
      } else {
        message.messageConfig = {
          // ...
          unreadEnabled: this.configUnreadEnable
          // ...
        }
      }

      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      this.message = messageResult.message
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  serialize() {
    try {
      console.info(`-----------serialize----------- \n`)
      const messageConverter = this.getUserModel().getNimSdk().messageConverter
      const messageString: string | null = messageConverter.messageSerialization(this.message)
      this.messageSerialization = messageString ?? ''
      shownDialog(true, JSON.stringify(messageString, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  deserialize() {
    try {
      console.info(`-----------deserialize----------- \n`)
      const messageConverter = this.getUserModel().getNimSdk().messageConverter
      const message: V2NIMMessage | null = messageConverter.messageDeserialization(this.messageSerialization)
      shownDialog(true, JSON.stringify(message, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async downloadFile(url: string, mediaType: string): Promise<void> {
    const catchDir = getContext(this).getApplicationContext().cacheDir
    let fileDir = catchDir + '/nim';
    if (!fs.accessSync(fileDir)) {
      fs.mkdirSync(fileDir);
    }

    const randomNum = getRandomNumber(0, 100);

    const filePath = fileDir + `/${randomNum}.${mediaType}`
    let storageService = this.getUserModel().getNimSdk().storageService! // Demo启用message模块，messageService不为空
    const path = await storageService.downloadFile(url, filePath, (percent) => {
      console.log(`downloadFile percent: ${percent}`)
    })

    shownDialog(true, JSON.stringify(path, null, 2))
  }

  getConversationId(): string {
    let conversationId = ''
    switch (this.conversationType) {
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.p2pConversationId(this.conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.teamConversationId(this.conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.superTeamConversationId(this.conversationId)
        break
    }

    return conversationId
  }

  aboutToAppear() {
    this.conversationId = ''
    this.pushPayload =
      `{"harmonyField":{"payload": {"notification": {"category": "IM","clickAction": {"actionType": 0}}},"pushOptions": {"testMessage": true}}}`
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('SendTextMessage')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))

            TextInput({ text: this.conversationId, placeholder: this.conversationId })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.conversationId = value;
              })
            Line().lineStyle()

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'p2p', group: 'conversationTypeGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
                  }
                })
              Text('p2p')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'team', group: 'conversationTypeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM
                  }
                })
              Text('team')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'superTeam', group: 'conversationTypeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM
                  }
                })
              Text('superTeam')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()


            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'unread enable', group: 'messageConfigUnreadEnableGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.configUnreadEnable = true
                  }
                })
              Text('unread enable')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'unread disable', group: 'messageConfigUnreadEnableGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.configUnreadEnable = false
                  }
                })
              Text('unread disable')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()

            TextInput({ placeholder: `send message text ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.text = value;
              })

            Line().lineStyle()

            TextInput({ text: this.pushPayload, placeholder: `push payload ` })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushPayload = value;
              })

            Line().lineStyle()

            Button(('SendMessage'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.sendTextMessage()
              })
            Button(('MessageSerialize'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.serialize()
              })
            Button(('MessageDeserialize'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.deserialize()
              })
            Blank()
          }
          .backgroundColor($r('app.color.background'))
          // .height(CommonConstants.FULL_PARENT)
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
    }.height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
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

function getRandomNumber(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}