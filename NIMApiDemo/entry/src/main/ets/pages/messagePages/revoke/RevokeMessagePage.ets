import { V2NIMError, V2NIMMessage, V2NIMMessageRevokeParams } from 'base/Index';
import { CommonConstants,
  shownDialog } from '../../../common/constants/CommonConstants';
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

/**
 * Login page
 */
@Entry
@Component
struct RevokeMessagePage {
  @State conversationId: string = '';
  @State text: string = '';
  @State isShowProgress: boolean = false;
  @State message: V2NIMMessage = {} as V2NIMMessage

  private timeOutId: number = -1;
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
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }

  async sendMessage(): Promise<void> {
      try {
        console.info(`-----------Reovke消息----------- \n`)
        // let conversationId: string = 'cjl64|1|cjl1'
        let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
        const messageCreator = this.getUserModel().getNimSdk().messageCreator
        let message: V2NIMMessage = messageCreator.createTextMessage(`${this.text}`)
        const conversationId = this.getUserModel().getNimSdk().loginService.getLoginUser() + '|1|' + this.conversationId
        const result = await messageService.sendMessage(message, conversationId)
        this.message = result.message
        shownDialog(true, JSON.stringify(this.message, null, 2))
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

  async revokeMessage() {
    try {
      let params:V2NIMMessageRevokeParams =  {
        postscript: '',
        serverExtension: '',
        pushContent: '',
        pushPayload: '',
        env: '',
      }

      console.info(`-----------Reovke消息----------- \n`)
      // let conversationId: string = 'cjl64|1|cjl1'
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      await messageService.revokeMessage(this.message, params)
      shownDialog(true, 'revoke 成功')
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text($r('app.string.RevokeMessage'))
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('revoke message')
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
          TextInput({ placeholder: `send message text ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.text = value;
            })

          Line().lineStyle()

          Button(('send'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({
              top: $r('app.float.login_button_margin_top'),
              bottom: $r('app.float.login_button_margin_bottom')
            })
            .onClick(() => {
              this.sendMessage();
            })

          Button(('revoke '), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({
              top: $r('app.float.login_button_margin_top'),
              bottom: $r('app.float.login_button_margin_bottom')
            })
            .onClick(() => {
              this.revokeMessage();
            })
          if (this.isShowProgress) {
            LoadingProgress()
              .color($r('app.color.loading_color'))
              .width($r('app.float.login_progress_size'))
              .height($r('app.float.login_progress_size'))
              .margin({ top: $r('app.float.login_progress_margin_top') })
          }

          Blank()
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