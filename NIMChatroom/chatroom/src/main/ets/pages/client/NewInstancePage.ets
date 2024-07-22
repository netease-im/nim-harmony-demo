import { V2NIMChatroomClient } from '@nimsdk/chatroom/Index'
import { CommonConstants, processV2ErrorForPrint, shownDialog } from '../../constants/CommonConstants'
import NIMChatroom  from '../../sdk/chatroom'

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

@Entry
@Component
export struct NewInstancePage {
  @State appKey: string = '45c6af3c98409b18a84451215d0bdd6e'
  @State customClientType: number = 0
  build() {
    Row() {
      Navigation() {
        Column() {
          Text('Client')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('NewInstance')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          TextInput({ text: this.appKey, placeholder: $r('app.string.conversation_id') })
            .maxLength(1024)
            .type(InputType.Normal)
            .inputStyle()
          // Line().outlineStyle(OutlineStyle.SOLID)
          TextInput({ placeholder: `customClientType` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.customClientType = parseInt(value)
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          Button(('newInstance'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.newInstance();
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

  async newInstance(): Promise<void> {
    console.info(`-----------创建client----------- \n`)
    try {
      const ret: V2NIMChatroomClient = NIMChatroom.newInstance(getContext(this).getApplicationContext())
      shownDialog(true, JSON.stringify(ret.instanceId))
    }
    catch (err) {
      shownDialog(true, processV2ErrorForPrint(err))
      return
    }
  }
}