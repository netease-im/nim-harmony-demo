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
import { UserModel } from '../../../viewmodel/UserModel';
import { router } from '@kit.ArkUI';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';

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
struct SendMediaMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State pictureUri: string = ''
  @State pushPayload: string = ''
  private userModel: UserModel | undefined;

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
      message.pushConfig.pushPayload = this.pushPayload

      const jsonObject: NIMEStrAnyObj = JSON.parse(message.pushConfig.pushPayload);

      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendCallMessage(): Promise<void> {
    try {
      console.info(`-----------sendCallMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createCallMessage(1, "2", 3, [
        { accountId: "accid_1", duration: 1 },
        { accountId: "accid_2", duration: 2 },
        { accountId: "accid_3", duration: 3 },
        { accountId: "accid_4", duration: 4 }
      ], this.text)

      // add push payload
      if (!message.pushConfig) {
        message.pushConfig = {} as V2NIMMessagePushConfig
      }
      message.pushConfig.pushPayload = this.pushPayload
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
      const jsonObject: NIMEStrAnyObj = JSON.parse(message.pushConfig.pushPayload);
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendLocationMessage(): Promise<void> {
    try {
      console.info(`-----------sendLocationMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createLocationMessage(11.22, 33.44, "HangZhouNetease")

      // add push payload
      if (!message.pushConfig) {
        message.pushConfig = {} as V2NIMMessagePushConfig
      }
      message.pushConfig.pushPayload = this.pushPayload
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
      const jsonObject: NIMEStrAnyObj = JSON.parse(message.pushConfig.pushPayload);
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
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

  async sendImageMessage(): Promise<void> {
    try {
      console.info(`-----------sendImageMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }
      const filePath = fileDir + '/image.png'
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer = getContext(this).resourceManager.getMediaContentSync($r('app.media.img').id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen = await fileIo.write(file.fd, buffer.buffer);
      console.info('write success,len=' + writeLen);
      let message: V2NIMMessage = await messageCreator.createImageMessage(filePath,
        'nim')
      const onUploadProgress = (percentage: number) => {
        console.info(`onUploadProgress: ${JSON.stringify(percentage)}`)
        if (percentage >= 1) {
          this.isShowProgress = false
        }
      }

      const params: V2NIMSendMessageParams = {
        //   配置参数
      }
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId, params,
        onUploadProgress)
      const attachment: V2NIMMessageFileAttachment = messageResult.message.attachment as V2NIMMessageFileAttachment
      this.downloadFile(attachment.url as string, 'png')
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendVideoMessage(): Promise<void> {
    try {
      console.info(`-----------sendVideoMessage----------- \n`)
      const conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }
      const filePath = fileDir + '/video.mp4'
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer = getContext(this).resourceManager.getMediaContentSync($r
      ("app.media.video2").id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen = await fileIo.write(file.fd, buffer.buffer);
      console.info('write success,len=' + writeLen);
      let message: V2NIMMessage = await messageCreator.createVideoMessage(filePath,
        'nim')
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
      const attachment: V2NIMMessageFileAttachment = messageResult.message.attachment as V2NIMMessageFileAttachment
      this.downloadFile(attachment.url as string, 'mp4')
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendAudioMessage(): Promise<void> {
    try {
      console.info(`-----------sendCallMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }
      const filePath = fileDir + '/audio.aac'
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer = getContext(this).resourceManager.getMediaContentSync($r
      ('app.media.audio').id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen = await fileIo.write(file.fd, buffer.buffer);
      console.info('write success,len=' + writeLen);
      let message: V2NIMMessage = await messageCreator.createAudioMessage(filePath,
        'nim')
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
      const attachment: V2NIMMessageFileAttachment = messageResult.message.attachment as V2NIMMessageFileAttachment
      this.downloadFile(attachment.url as string, 'mp3')
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendCustomMessage(): Promise<void> {
    try {
      console.info(`-----------sendCustomMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createCustomMessage(this.text, `{"1": "2"}`)
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      const attachment: V2NIMMessageAttachment = messageResult.message.attachment as V2NIMMessageAttachment
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
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
            Text($r('app.string.SendMessageMethod'))
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text($r('app.string.send_message_description'))
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

            TextInput({ text: this.conversationId, placeholder: $r('app.string.conversation_id') })
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

            // PictureFiles({ picture: this.pictureUri })

            Button(('camera'), { type: ButtonType.Capsule })
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
                const url =  'pages/messagePages/send/CameraPage'
                router.pushUrl({url: url})
              })

            Button(('send Image'), { type: ButtonType.Capsule })
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
                this.isShowProgress = true;
                this.sendImageMessage();
              })
            Button(('send video'), { type: ButtonType.Capsule })
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
                this.sendVideoMessage()
              })
            Button(('send audio'), { type: ButtonType.Capsule })
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
                this.sendAudioMessage()
              })
            Button(('send custom'), { type: ButtonType.Capsule })
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
                this.sendCustomMessage()
              })
            Button(('send call'), { type: ButtonType.Capsule })
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
                this.sendCallMessage()
              })
            Button(('send location'), { type: ButtonType.Capsule })
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
                this.sendLocationMessage()
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