import { fileIo } from '@kit.CoreFileKit';
import NIMChatroom from '../../../sdk/chatroom'
import {
  V2NIMError,
  V2NIMMessageAttachment,
  V2NIMMessageFileAttachment,
  V2NIMSendMessageParams,
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../constants/CommonConstants';
import { RouterParams } from '../../ChatroomInstancePage';
import { Router } from '@kit.ArkUI';
import { V2NIMChatroomClient, V2NIMChatroomMessage, V2NIMSendChatroomMessageResult } from '@nimsdk/chatroom';

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
struct SendMessagePage {
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State pictureUri: string = ''
  @State pushPayload: string = ''

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }
    .height($r('app.float.other_login_image_size'))
    .width($r('app.float.other_login_image_size'))
    .backgroundColor($r('app.color.background'))
  }

  private getInstanceFromRouter(): V2NIMChatroomClient {
    let router: Router = this.getUIContext().getRouter();
    const instanceId: number = (router.getParams() as RouterParams).routerInstanceId;
    return NIMChatroom.getInstance(instanceId)
  }

  async sendTextMessage(): Promise<void> {
    try {
      console.info(`-----------sendTextMessage----------- \n`)
      const chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
      let message: V2NIMChatroomMessage = messageCreator.createTextMessage(this.text)

      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendLocationMessage(): Promise<void> {
    try {
      console.info(`-----------sendLocationMessage----------- \n`)
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
      let message: V2NIMChatroomMessage = messageCreator.createLocationMessage(11.22, 33.44, "HangZhouNetease")

      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message)
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
    let storageService = this.getInstanceFromRouter().storageService! // Demo启用message模块，messageService不为空
    // const path = await storageService..downloadFile(url, filePath, (percent) => {
    //   console.log(`downloadFile percent: ${percent}`)
    // })

    shownDialog(true, JSON.stringify("downloadFile not implemented, path", null, 2))
  }

  async sendImageMessage(): Promise<void> {
    try {
      console.info(`-----------sendImageMessage----------- \n`)
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
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
      let message: V2NIMChatroomMessage = await messageCreator.createImageMessage(filePath,
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
      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message, params,
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
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }
      const filePath = fileDir + '/video.mp4'
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer = getContext(this).resourceManager.getMediaContentSync($r
      ('app.media.video').id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen = await fileIo.write(file.fd, buffer.buffer);
      console.info('write success,len=' + writeLen);
      let message: V2NIMChatroomMessage = await messageCreator.createVideoMessage(filePath,
        'nim')
      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message)
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
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
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
      let message: V2NIMChatroomMessage = await messageCreator.createAudioMessage(filePath,
        'nim')
      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message)
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
      let chatroomService = this.getInstanceFromRouter().chatroomService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getInstanceFromRouter().messageCreator
      let message: V2NIMChatroomMessage = messageCreator.createCustomMessage(`{"1": "2"}`)
      let messageResult: V2NIMSendChatroomMessageResult = await chatroomService.sendMessage(message)
      const attachment: V2NIMMessageAttachment = messageResult.message.attachment as V2NIMMessageAttachment
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  aboutToAppear() {
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

            Button(('send text'), { type: ButtonType.Capsule })
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