import { fileIo, picker } from '@kit.CoreFileKit';

import {
  V2NIMConversationType,
  V2NIMDownloadAttachmentType,
  V2NIMDownloadMessageAttachmentParams,
  V2NIMError,
  V2NIMMessage,
  V2NIMMessageAttachmentUploadState,
  V2NIMMessageFileAttachment,
  V2NIMSendMessageParams,
  V2NIMSendMessageResult
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UIUtils } from '../../../utils/UIUtils';
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
struct ConverterImageMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State pictureUri: string = ''
  @State pushPayload: string = ''
  @State imageUri: string = '';
  @State isUploading: boolean = false;
  @State tabsIndex: number = 1;
  @State isEnterCamera: boolean = false;
  @State cameraIndex: number = 0;
  @State isMovingPhoto: boolean = true;
  @State isTakeMovingPhoto: boolean = false;
  @State photoUriArr: string[] = [];
  @State selectPhotoUri: string = '';
  private message: V2NIMMessage = {} as V2NIMMessage
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

  async downloadFile(message: V2NIMMessage, mediaType: string): Promise<void> {
    const catchDir = getContext(this).getApplicationContext().cacheDir
    let fileDir = catchDir + '/nim';
    if (!fs.accessSync(fileDir)) {
      fs.mkdirSync(fileDir);
    }

    const randomNum = getRandomNumber(0, 100);

    const filePath = fileDir + `/${randomNum}.${mediaType}`
    let storageService = this.getUserModel().getNimSdk().storageService! // Demo启用message模块，messageService不为空
    const downloadParams: V2NIMDownloadMessageAttachmentParams = {
      attachment: message.attachment,
      saveAs: filePath,
      type: V2NIMDownloadAttachmentType.V2NIM_DOWNLOAD_ATTACHMENT_TYPE_SOURCE
    } as V2NIMDownloadMessageAttachmentParams
    const path = await storageService.downloadAttachment(downloadParams, (percent) => {
      console.log(`downloadFile percent: ${percent}`)
    })
    console.log('messageUrl', path)
    shownDialog(true, JSON.stringify(path, null, 2))
  }

  async sendImageMessage(): Promise<void> {
    try {
      console.info(`-----------sendImageMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      // 1.创建文件缓存目录
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }

      // 2.读取系统相册 => buffer
      let uriFile = fs.openSync(this.selectPhotoUri, fs.OpenMode.READ_ONLY);
      let buffer = new ArrayBuffer(4096 * 4096);

      let readLen = fs.readSync(uriFile.fd, buffer);
      console.info('readSync data to file succeed and buffer size is:' + readLen);
      fs.closeSync(uriFile);
      // 3. 创建发送文件，将buffer 写入
      const filePath = fileDir + `/${Date.now()}.png`
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let writeLen = await fileIo.write(file.fd, buffer);
      console.info('write success,len=' + writeLen);
      // 发送消息
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
      this.message = messageResult.message
      shownDialog(true, JSON.stringify(attachment, null, 2))
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
    this.getUserModel().getNimSdk().messageService?.on('onSendMessage', (message: V2NIMMessage) => {
      if (message.attachmentUploadState ===
      V2NIMMessageAttachmentUploadState.V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_SUCCESS) {
        const attachment: V2NIMMessageFileAttachment = message.attachment as V2NIMMessageFileAttachment
        //this.downloadFile(attachment.url as string, 'png')
      }
    })
    this.conversationId = ''
    this.pushPayload =
      `{"harmonyField":{"payload": {"notification": {"category": "IM","clickAction": {"actionType": 0}}},"pushOptions": {"testMessage": true}}}`
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('SendImageMessage')
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

            Button(('image'), { type: ButtonType.Capsule })
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

                UIUtils.showPickerView((uriArr: string[]) => {
                  let pickerUriArr: string[] = [];
                  while (uriArr.length > 0) {
                    let uri = uriArr.pop()
                    if (uri === undefined) {
                      continue
                    }
                    pickerUriArr.unshift(uri)
                  }
                  this.selectPhotoUri = pickerUriArr[0]
                }, picker.PhotoViewMIMETypes.IMAGE_TYPE, 1);
              })

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
                this.isShowProgress = true;
                this.sendImageMessage();
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