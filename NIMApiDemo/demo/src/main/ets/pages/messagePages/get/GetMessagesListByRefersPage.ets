import { V2NIMConversationType, V2NIMError, V2NIMMessage } from '@nimsdk/base';
import { CommonConstants,
  shownDialog } from '../../../common/CommonConstants';
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
struct GetMessagesListByRefersPage {
  @State conversationId: string = '';
  @State text: string = '';
  @State senderId: string = '';
  @State receiverId: string = '';
  @State messageClientId: string = '';
  @State messageServerId: string = '';
  @State createTime: number = 0;
  @State conversationType: V2NIMConversationType = 1;

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
      let message: V2NIMMessage = messageCreator.createTextMessage(`${this.text}`)
      const conversationId = this.getUserModel().getNimSdk().loginService.getLoginUser() + `|${this.conversationType}|` + this.conversationId
      const result = await messageService.sendMessage(message,
        conversationId)
      this.messages.push(result.message)
      this.messageClientId = result.message.messageClientId;
      this.messageServerId = result.message.messageServerId;
      this.senderId = result.message.senderId;
      this.receiverId = result.message.receiverId;
      this.createTime = result.message.createTime;
      this.conversationType = result.message.conversationType;

      shownDialog(true, JSON.stringify(result.message, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async getMessage(): Promise<void> {
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const result = await messageService.getMessageListByRefers(this.messages)
      shownDialog(true, JSON.stringify(result, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }


  aboutToAppear(): void {
    this.conversationId = ''
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('GetMessageByRefer')
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

            TextInput({ placeholder: `send message text ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.text = value;
              })
            Line().lineStyle()

            TextInput({ placeholder: `sendId `, text: this.senderId })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.senderId = value;
              })
            Line().lineStyle()
            TextInput({ placeholder: `receiverId `, text: this.receiverId })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.receiverId = value;
              })
            Line().lineStyle()
            TextInput({ placeholder: `messageClientId `, text: this.messageClientId })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.messageClientId = value;
              })
            Line().lineStyle()
            TextInput({ placeholder: `messageServerId `, text: this.messageServerId })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.messageServerId = value;
              })
            Line().lineStyle()

            Text(`createTime`)
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            TextInput({ text: this.createTime.toString() })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.createTime = parseInt(value)
              })
              .width('100%')
            Line().lineStyle()

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

            Button(('getMessageByRefer '), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
              .onClick(() => {
                this.getMessage();
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