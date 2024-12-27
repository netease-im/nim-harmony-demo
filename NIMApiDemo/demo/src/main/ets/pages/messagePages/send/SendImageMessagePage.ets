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
import { CameraSelectView } from './system/CameraSelectView';
import { MediaUtils } from './system/MediaUtils';
import { common } from '@kit.AbilityKit';
import { cameraPicker } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { DeviceUtils } from './system/DeviceUtils';
import { image } from '@kit.ImageKit';

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
struct SendImageMessagePage {
  //@StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
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
  private userModel: UserModel | undefined;
  selectVideoView: CustomDialogController = new CustomDialogController({
    builder: CameraSelectView({
      onTakePhotoFromCamera: () => {
        const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        MediaUtils.showCameraPicker(context, cameraPicker.PickerMediaType.PHOTO).then((result) => {
          if (result.uri) {
            if (result.type === photoAccessHelper.PhotoType.IMAGE) {
              this.sendImageMessage(result.uri)
            } else if (result.type === photoAccessHelper.PhotoType.VIDEO) {
              this.sendVideoMessage(result.uri, result.duration, result.width, result.height)
            }
          }
        });
      },
      onTakeVideoFromCamera: () => {
        const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        MediaUtils.showCameraPicker(context, cameraPicker.PickerMediaType.VIDEO).then((result) => {
          if (result.uri) {
            if (result.type === photoAccessHelper.PhotoType.IMAGE) {
              this.sendImageMessage(result.uri)
            } else if (result.type === photoAccessHelper.PhotoType.VIDEO) {
              this.sendVideoMessage(result.uri, result.duration, result.width, result.height)
            }
          }
        });
      }
    }),
    cornerRadius: 0,
    alignment: DialogAlignment.Bottom,
    backgroundColor: Color.Transparent,
    backgroundBlurStyle: BlurStyle.NONE,
    height: 140,
  })
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

  async sendImageMessage(uri: string): Promise<void> {
    try {
      if (uri.length > 0) {
        let fileType = ""
        const subStrings = uri.split(".");
        if (subStrings.length > 0) {
          fileType = subStrings[subStrings.length - 1];
        }
        // 将文件 拷贝到 临时目录
        const file = await fs.open(uri, fs.OpenMode.READ_ONLY)
        // （以时间戳）生成一个新的文件名
        const fileName = Date.now() + '.' + fileType
        // 通过缓存路径+文件名 拼接出完整的路径
        let fileDir = DeviceUtils.rootDirPath + '/temp/'
        const copyFilePath = fileDir + fileName
        if (!fs.accessSync(fileDir)) {
          await fs.mkdir(fileDir)
        }
        await fs.copyFile(file.fd, copyFilePath)
        const imageSource = image.createImageSource(file.fd);
        let imageInfo = imageSource.getImageInfoSync()
        let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
        const messageCreator = this.getUserModel().getNimSdk().messageCreator

        const message = await messageCreator.createImageMessage(copyFilePath, file.name, undefined, imageInfo?.size.width,
          imageInfo?.size.height);
        await messageService.sendMessage(message, this.getConversationId())
        await fs.close(file)
        shownDialog(true, JSON.stringify(message, null, 2))
      }
    } catch (err) {
      console.log("net ease send image error", err);
    }
  }

  async sendVideoMessage(uri: string, duration?: number, width?: number, height?: number, thumbnail?: PixelMap) {
    try {
      let fileType = ""
      const subStrings = uri.split(".");
      if (subStrings.length > 0) {
        fileType = subStrings[subStrings.length - 1];
      }
      // 将文件 拷贝到 临时目录
      const file = await fs.open(uri, fs.OpenMode.READ_ONLY)
      // （以时间戳）生成一个新的文件名
      const fileName = Date.now() + '.' + fileType
      // 通过缓存路径+文件名 拼接出完整的路径
      let fileDir = DeviceUtils.rootDirPath + '/temp/'
      const copyFilePath = fileDir + fileName
      if (!fs.accessSync(fileDir)) {
        await fs.mkdir(fileDir)
      }
      await fs.copyFile(file.fd, copyFilePath)
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator

      const message = await messageCreator.createVideoMessage(copyFilePath, file.name, undefined, duration, width, height);

      await messageService.sendMessage(message, this.getConversationId())
      await fs.close(file)
      shownDialog(true, JSON.stringify(message, null, 2))
    } catch (err) {
      console.log("net ease send video error", err);
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
    DeviceUtils.rootDirPath = getContext(this).filesDir
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
                    this.sendImageMessage(uri)
                  }
                  this.selectPhotoUri = pickerUriArr[0]
                }, picker.PhotoViewMIMETypes.IMAGE_TYPE, 1);
              })

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
                this.isShowProgress = true;
                this.selectVideoView.open();
              })
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