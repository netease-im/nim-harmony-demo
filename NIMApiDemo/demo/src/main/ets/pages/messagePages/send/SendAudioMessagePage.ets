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

import fs, { Options } from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
// import { PictureFiles } from '../../../message/view/PictureFiles';
import { UserModel } from '../../../viewmodel/UserModel';
import { router } from '@kit.ArkUI';
import { AudioRecorder } from './system/AudioRecorder';
import { AudioCapturer } from './system/AudioCapturer';
import { LoggerServiceImpl } from '@nimsdk/nim';

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
struct SendAudioMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State audioFilePath: string = ''
  @State pushPayload: string = ''
  private userModel: UserModel | undefined;
  //private audioRecorder: AudioRecorder = new AudioRecorder(getContext(this).getApplicationContext())
  private audioCapturer: AudioCapturer = new AudioCapturer(getContext(this).getApplicationContext())
  private file?: fs.File
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


  async sendAudioMessage(): Promise<void> {
    try {
      console.info(`-----------sendCallMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      //const catchDir = getContext(this).getApplicationContext().cacheDir
      //let fileDir = catchDir + '/nim';
      //if (!fs.accessSync(fileDir)) {
      //  fs.mkdirSync(fileDir);
      //}
      //const filePath = fileDir + '/audio.aac'
      //let file = await fileIo.open(filePath, fileIo.OpenMode
      //  .READ_WRITE | fileIo.OpenMode.CREATE);
      //let buffer = getContext(this).resourceManager.getMediaContentSync($r
      //('app.media.audio').id);
      //// Write the read ArrayBuffer to the new media file.
      //let writeLen = await fileIo.write(file.fd, buffer.buffer);
      //TODO 录音功能还有问题，代码仅供参考
      console.info('read bufffer size =' + this.file?.path);

      let message: V2NIMMessage = await messageCreator.createAudioMessage(this.audioFilePath,
        'nim')
      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
      const attachment: V2NIMMessageFileAttachment = messageResult.message.attachment as V2NIMMessageFileAttachment
      this.downloadFile(attachment.url as string, 'mp3')
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async initRecorder(): Promise<void> {
    try {
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }

      this.audioFilePath = fileDir + `/${Date.now()}.wav`
      this.file = fs.openSync(this.audioFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let bufferSize = 0
      //this.audioRecorder.startRecordingProcess(this.audioFilePath)
      this.audioCapturer.init((buffer) => {
        let options = {
          length: buffer.byteLength
        } as Options

        fs.writeSync(this.file?.fd, buffer, options);
        bufferSize += buffer.byteLength;
        console.info(`read bufffer size`, bufferSize)
      })
      shownDialog(true, JSON.stringify('start audio recorder', null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async startRecorder(): Promise<void> {
    try {
      //const catchDir = getContext(this).getApplicationContext().cacheDir
      //let fileDir = catchDir + '/nim';
      //if (!fs.accessSync(fileDir)) {
      //  fs.mkdirSync(fileDir);
      //}
      //
      //this.audioFilePath = fileDir + `/${Date.now()}.aac`
      //this.audioRecorder.startRecordingProcess(this.audioFilePath)
      this.audioCapturer.start()
      shownDialog(true, JSON.stringify('start audio recorder', null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async stopRecorder(): Promise<void> {
    try {
     //await this.audioRecorder.stopRecordingProcess(this.audioFilePath)
      this.audioCapturer.stop(() => {
        fs.close(this.file)
        this.audioCapturer.release()
      })
      shownDialog(true, JSON.stringify('stop audio recorder', null, 2))

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
            Text('SendAudioMessage')
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

            TextInput({ placeholder: `recorder ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.text = value;
              })

            Line().lineStyle()
            Button(('init'), { type: ButtonType.Capsule })
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
                this.initRecorder()
              })

            Button(('start'), { type: ButtonType.Capsule })
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
                this.startRecorder()
              })
            Line().lineStyle()
            Button(('stop'), { type: ButtonType.Capsule })
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
                this.stopRecorder()
              })
            Line().lineStyle()

            Button(('send'), { type: ButtonType.Capsule })
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