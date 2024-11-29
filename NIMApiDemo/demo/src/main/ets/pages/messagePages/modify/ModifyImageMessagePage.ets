import { fileIo, picker } from '@kit.CoreFileKit';

import {
    V2NIMConversationType,
    V2NIMError,
    V2NIMMessage, V2NIMModifyMessageParams,
    V2NIMSendMessageParams,
    V2NIMSendMessageResult
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UIUtils } from '../../../utils/UIUtils';
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

@Entry
@Component
struct ModifyImageMessagePage {
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
  @State subType: number = 0
  @State serverExtension: string = ''
  private message: V2NIMMessage = {} as V2NIMMessage

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

      const messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId, params,
        onUploadProgress)
      this.message = messageResult.message
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async modifyImageMessage(): Promise<void> {
    try {
      console.info(`-----------modifyImageMessage----------- \n`)
      let messageService = this.getUserModel().getNimSdk().messageService!
      const params: V2NIMModifyMessageParams = {
        subType: this.subType,
        text: this.text,
        serverExtension: this.serverExtension
      } as V2NIMModifyMessageParams

      const result = await messageService.modifyMessage(this.message, params)
      shownDialog(true, JSON.stringify(result, null, 2), 'modifyImageMessage')
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
            Button(('SelectImage'), { type: ButtonType.Capsule })
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

            Line().lineStyle()
            Text('Modify Message')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            TextInput({ placeholder: `modify message text ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.text = value;
              })
            TextInput({ placeholder: `modify message subType ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.subType = parseInt(value);
              })
            TextInput({ placeholder: `modify message serversion ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.serverExtension = value;
              })
            Button(('Modify'), { type: ButtonType.Capsule })
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
                this.modifyImageMessage()
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