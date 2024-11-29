
import {
    V2NIMConversationType,
    V2NIMError,
    V2NIMMessage, V2NIMMessagePushConfig,
  V2NIMSendMessageParams,
  V2NIMSendMessageResult
} from '@nimsdk/base';

import fs from '@ohos.file.fs';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color')).
  height($r('app.float.login_input_height')).
  fontSize($r('app.float.big_text_size')).
  backgroundColor($r('app.color.background')).
  width(CommonConstants.FULL_PARENT).
  padding({ left: CommonConstants.INPUT_PADDING_LEFT }).
  margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT).height($r('app.float.line_height')).backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color')).
  fontSize($r('app.float.small_text_size')).
  fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct SendTeamTargetMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State receiverIds: string[] = []
  @State inclusive: boolean = false
  @State newMemberVisible: boolean = false

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }
    ) {
      Image(src)
    }.
    height($r('app.float.other_login_image_size')).
    width($r('app.float.other_login_image_size')).
    backgroundColor($r('app.color.background'))
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
      message.pushConfig.pushNickEnabled = true
      message.pushConfig.pushContent = 'y'
      //
      message.pushConfig.forcePush = false
      message.pushConfig.forcePushAccountIds = []
      message.pushConfig.forcePushContent = 'y'

      const params = {
        targetConfig: {
          receiverIds: this.receiverIds,
          inclusive: this.inclusive,
          newMemberVisible: this.newMemberVisible
        }
      } as V2NIMSendMessageParams

      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId, params)
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
    }
    )

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
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('SendTextMessage').
              fontSize($r('app.float.page_title_text_size')).
              fontWeight(FontWeight.Medium).
              fontColor($r('app.color.title_text_color'))

            TextInput({ text: this.conversationId, placeholder: this.conversationId }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.conversationId = value;
              })
            Line().lineStyle()

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'team', group: 'conversationTypeGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM
                }
              }
              )
              Text('team').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'superTeam', group: 'conversationTypeGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM
                }
              }
              )
              Text('superTeam').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Line().lineStyle()

            TextInput({ placeholder: `send message text ` }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.text = value;
              }
              )

            Line().lineStyle()
            Row({space: 5}){
              Text('inclusive，默认为 false').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(50)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: false })
              .onChange((isOn: boolean) => {
                this.inclusive = isOn
              })
            }.width('100%')
            .justifyContent(FlexAlign.Start)

            Row() {
              Text('newMemberVisible, 默认为 false').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(50)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: false }).onChange((isOn: boolean) => {
                this.newMemberVisible = isOn
              })
            }.width('100%')
            .justifyContent(FlexAlign.Start)

            TextInput({ text: '定向消息接收者账号列表', placeholder: '' }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.receiverIds = value.split(",")
              })

            TextInput({ placeholder: `定向消息接收者账号列表` }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.text = value;
              })

            Button(('SendTargetMessage'), { type: ButtonType.Capsule }).
              width(CommonConstants.BUTTON_WIDTH).
              height($r('app.float.login_button_height')).
              fontSize($r('app.float.normal_text_size')).
              fontWeight(FontWeight.Medium).
              backgroundColor($r('app.color.login_button_color')).
              margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              }
              ).
              onClick(() => {
                this.sendTextMessage()
              }
              )
            Blank()
          }.backgroundColor($r('app.color.background'))
          // .height(CommonConstants.FULL_PARENT)
          .width(CommonConstants.FULL_PARENT).padding({
            left: $r('app.float.page_padding_hor'),
            right: $r('app.float.page_padding_hor'),
            bottom: $r('app.float.login_page_padding_bottom')
          }
          )
        }
      }.
      size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 }).
      title('back').
      titleMode(NavigationTitleMode.Mini)
    }.height(CommonConstants.THOUSANDTH_1000).backgroundColor($r('app.color.primaryBgColor'))
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