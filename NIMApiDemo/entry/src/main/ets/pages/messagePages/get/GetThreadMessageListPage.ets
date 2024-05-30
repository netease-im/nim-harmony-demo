import { V2NIMError, V2NIMMessage, V2NIMThreadMessageListOption
} from '@nimsdk/base';
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

@Entry
@Component
struct GetThreadMessageListPage {
  @State text: string = '';
  @State conversationId: string = '';
  @State beginTime: number = 0
  @State endTime:number = 0
  @State limit:number = 50
  @State directionType: number = 1
  @State excludeMessageServerId:string = ''
  private messages = {}  as V2NIMMessage

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
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  async sendMessage(): Promise<void> {
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createTextMessage(`${this.text}`)
      const conversationId = this.getUserModel().getNimSdk().loginService.getLoginUser() + '|1|' + this.conversationId
      const result = await messageService.sendMessage(message, conversationId)
      this.messages = result.message
      shownDialog(true, JSON.stringify(result.message, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async getThreadMessageList() {
    console.info(`-----------getThreadMessageList----------- \n`)
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const params = {
        messageRefer: this.messages,
        beginTime: this.beginTime,
        endTime: this.endTime,
        limit: this.limit,
        direction: this.directionType,
        excludeMessageServerId: this.excludeMessageServerId.length > 0 ? this.excludeMessageServerId : this.messages.messageServerId
      } as V2NIMThreadMessageListOption

      const list = await messageService.getThreadMessageList(params)
      shownDialog(true, JSON.stringify(list, null, 2))
    }
    catch (err) {
      shownDialog(false, processV2ErrorForPrint(err))
      return
    }
  }

  aboutToAppear(): void {
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('GetThreadMessageList')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('get thread message list')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          TextInput({ placeholder: `接受消息id` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.conversationId = value
            })
          Line().lineStyle()
          TextInput({ placeholder: `send message text` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.text = value
            })
          Line().lineStyle()
          TextInput({ placeholder: `beginTime ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.beginTime = parseInt(value);
            })
          Line().lineStyle()
          TextInput({ placeholder: `endTime ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.endTime = parseInt(value);
            })
          Line().lineStyle()
          TextInput({ placeholder: `limit ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.limit = parseInt(value);
            })
          Line().lineStyle()
          TextInput({ placeholder: `directionType 只能是 0， 或者 1 ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.directionType = parseInt(value);
            })
          Line().lineStyle()
          TextInput({ placeholder: `excludeMessageServerId ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.excludeMessageServerId = value;
            })
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

          Button(('getThreadMessageList'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.getThreadMessageList();
            })
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