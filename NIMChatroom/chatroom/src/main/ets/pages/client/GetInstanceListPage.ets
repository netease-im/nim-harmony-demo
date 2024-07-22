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
export struct GetInstanceListPage {
  build() {
    Row() {
      Navigation() {
        Column() {
          Text('Client')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('getInstanceList')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          TextInput({ placeholder: `get instance list` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
          // Line().outlineStyle(OutlineStyle.SOLID)

          Button(('getInstances'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.getInstanceList();
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

  getInstanceList(){
    console.info(`-----------Get client----------- \n`)
    try {
      const ret = NIMChatroom.getInstanceList()
      let instanceIds: number[] = []
      for (const element of ret) {
        instanceIds.push(element.instanceId)
      }
      shownDialog(true, JSON.stringify(instanceIds))
    }
    catch (err) {
      shownDialog(true, processV2ErrorForPrint(err))
      return
    }
  }
}