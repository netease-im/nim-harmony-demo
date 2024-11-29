import {
  V2NIMConversationType,
  V2NIMError,
  V2NIMMessage,
  V2NIMModifyMessageParams,
  V2NIMSendMessageResult
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';
import { AudioRecordManager } from '../send/system/AudioCapturer';

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
struct ModifyAudioMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State pushPayload: string = ''
  @State isUploading: boolean = false;
  @State audioFilePath: string = ''
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

  async startRecorder(): Promise<void> {
    try {
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }

      this.audioFilePath = fileDir + `/${Date.now()}.m4a`
      AudioRecordManager.instance.startRecordingProcess(this.audioFilePath)
      shownDialog(true, JSON.stringify('start audio recorder', null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async stopRecorder(): Promise<void> {
    try {
      AudioRecordManager.instance.stopRecordingProcess().then(() => {

      })

      shownDialog(true, JSON.stringify('stop audio recorder', null, 2))

    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async sendAudioMessage(): Promise<void> {
    try {
      console.info(`-----------sendAudioMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService!
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      console.info('read bufffer size =' + this.audioFilePath);
      const message: V2NIMMessage = await messageCreator.createAudioMessage(this.audioFilePath,
        'nim', 'nim_default_im', 3000)
      const messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId)
      this.message = messageResult.message
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async modifyAudioMessage(): Promise<void> {
    try {
      console.info(`-----------modifyAudioMessage----------- \n`)
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
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
            Text('SendAudioMessage')
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
            Button(('StartRecord'), { type: ButtonType.Capsule })
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

            Button(('Stop'), { type: ButtonType.Capsule })
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
                this.sendAudioMessage()
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
                this.modifyAudioMessage()
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