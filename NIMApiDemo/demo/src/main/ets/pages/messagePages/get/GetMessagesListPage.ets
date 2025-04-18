import {
  V2NIMConversationType,
  V2NIMError,
  V2NIMMessage,
  V2NIMMessageListOption, V2NIMQueryDirection } from '@nimsdk/base';
import { NIMSdk } from '@nimsdk/nim/src/main/ets/nim/NIMSdk';
import { CommonConstants,
  shownDialog } from '../../../common/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';
import { HashMap, HashSet } from '@kit.ArkTS';

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
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = '';
  @State isOnlyRemoveLocal: boolean = false;
  @State beginTime: number = 0;
  @State endTime: number = 0;
  @State limit: number = 50;
  @State anchorClientId: string = "";
  @State queryDirection: V2NIMQueryDirection = V2NIMQueryDirection.V2NIM_QUERY_DIRECTION_DESC;
  @State strictMode: boolean = false
  @State onlyQueryLocal: boolean = false

  private cachedMessages: HashMap<string, V2NIMMessage> = new HashMap()
  private timeOutId: number = -1;
  private messages: V2NIMMessage[] = []
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

  async sendMessage(): Promise<void> {
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createCustomMessage(`${this.text}`, `{"1":"1"}`)
      const result = await messageService.sendMessage(message, this.getConversationId())
      this.messages.push(result.message)
      shownDialog(true, JSON.stringify(result.message, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async getMessage(): Promise<void> {
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const option: V2NIMMessageListOption = {
        conversationId: this.getConversationId(),
        beginTime: this.beginTime,
        endTime: this.endTime,
        anchorMessage: this.getCachedMessageByClientId(this.anchorClientId),
        limit: this.limit,
        direction: this.queryDirection,
        strictMode: this.strictMode,
        onlyQueryLocal: this.onlyQueryLocal
      }

      const messageList: V2NIMMessage[] = await messageService.getMessageList(option)
      this.messages = messageList
      shownDialog(true, JSON.stringify(messageList, null, 2))
      for (let message of messageList) {
        if (!this.cachedMessages.hasKey(message.messageClientId)) {
          this.cachedMessages.set(message.messageClientId, message)
        }
      }
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async deleteMessage(): Promise<void> {
      try {
        console.info(`-----------deleteMessage----------- \n`)
        // let conversationId: string = 'cjl64|1|cjl1'
        const message = this.messages[this.messages.length - 1];
        let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
        await messageService.deleteMessage(message)
        shownDialog(true, JSON.stringify('this.message'))
      } catch (error) {
        console.log('----------- deleteMessage -----------', error)
        shownDialog(false, JSON.stringify(processV2ErrorForPrint(error)))
      }
  }
  aboutToAppear(): void {
    this.conversationId = ''
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
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

  getCachedMessageByClientId(clientId: string): V2NIMMessage
  {
    return this.cachedMessages.get(clientId)
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

            TextInput({ placeholder: `is remove only local ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.isOnlyRemoveLocal = parseInt(value) > 0 ? true : false;
              })
            Line().lineStyle()

            Text(`beginTime`)
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            TextInput({ text: this.beginTime.toString() })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.beginTime = parseInt(value)
              })
              .width('100%')
            Line().lineStyle()

            Text(`endTime`)
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            TextInput({ text: this.endTime.toString() })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.endTime = parseInt(value)
              })
              .width('100%')
            Line().lineStyle()

            Text(`limit`)
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            TextInput({ text: this.limit.toString() })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.limit = parseInt(value)
              })
              .width('100%')
            Line().lineStyle()

            Text(`anchorClientId`)
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            TextInput({ text: this.anchorClientId })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.anchorClientId = value
              })
              .width('100%')
            Line().lineStyle()

            Text('Direction')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'desc', group: 'directionGroup' }).checked(true)
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

            Line().lineStyle()
            Text('strictMode')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'true', group: 'strictModeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.strictMode = true
                  }
                })
              Text('true')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'false', group: 'strictModeGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.strictMode = false
                  }
                })
              Text('false')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()
            Text('onlyQueryLocal')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'true', group: 'onlyQueryLocalGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyQueryLocal = true
                  }
                })
              Text('true')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'false', group: 'onlyQueryLocalGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyQueryLocal = false
                  }
                })
              Text('false')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()

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
            Button(('delete'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
              .onClick(() => {
                this.deleteMessage();
              })
            Blank()
          }
        }


        .backgroundColor($r('app.color.background'))
        .height(CommonConstants.FULL_PARENT)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          left: $r('app.float.page_padding_hor'),
          right: $r('app.float.page_padding_hor'),
          bottom: $r('app.float.login_page_padding_bottom')
        })
      }
      .size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 })
      .title('back')
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}

function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ? JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}