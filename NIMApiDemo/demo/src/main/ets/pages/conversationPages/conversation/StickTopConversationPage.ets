import {
  V2NIMError,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
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
struct StickTopConversationPage {
  @State conversationId: string = ''
  @State stickTop: boolean = false
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
  async stickTopConversation(): Promise<void> {
    console.info(`----------置顶会话--------- \n`)
    try {
      // get service
      let conversationService = this.getUserModel().getNimSdk().conversationService! // Demo启用conversation模块，conversationService不为空

      // input
      const conversationId: string = this.conversationId
      const stickTop: boolean = this.stickTop

      // call interface
      const res = await conversationService.stickTopConversation(conversationId, stickTop)
      console.info(`-----------置顶会话成功----------- ${res}`)
      shownDialog(true, JSON.stringify(res, null, 2))
    }
    catch (err) {
      console.error(`-----------置顶会话失败---------- \n`, `${err}`)
      shownDialog(false, processV2ErrorForPrint(err))
      return
    }
  }
  aboutToAppear(): void {
    this.conversationId = this.getUserModel().getNimSdk().loginService.getLoginUser() + '|1|cjl1'
  }

  aboutToDisappear() {
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('StickTopConversation')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('stick top conversation method')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          // conversation id
          TextInput({ text:this.conversationId, placeholder: 'conversation id' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.conversationId = value
            })
          Line().lineStyle()

          // clearMessage
          Text('stockTop')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .textAlign(TextAlign.Start)
            .width('100%')
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'stockTop' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('stockTop change is' + on)
                this.stickTop = on
              })
            Text('check')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }
          Line().lineStyle()


          Button(('get'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.login_button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.stickTopConversation();
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