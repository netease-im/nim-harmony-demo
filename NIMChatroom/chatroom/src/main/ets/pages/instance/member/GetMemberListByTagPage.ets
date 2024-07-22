import { V2NIMError } from '@nimsdk/base'
import { V2NIMChatroomClient,
  V2NIMChatroomMemberListResult,
  V2NIMChatroomService,
  V2NIMChatroomTagMemberOption, } from '@nimsdk/chatroom'
import { CommonConstants, shownDialog } from '../../../constants/CommonConstants'
import { Router } from '@kit.ArkUI'
import { RouterParams } from '../../ChatroomInstancePage'
import NIMChatroom from '../../../sdk/chatroom'

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
struct GetMemberListByTagPage {
  @State tag: string = 'tag1';
  @State pageToken: string = ""
  @State limit: number = 3

  async getListByOption(): Promise<void> {
    try {
      const chatroomService: V2NIMChatroomService = this.getInstanceFromRouter().chatroomService!
      const option: V2NIMChatroomTagMemberOption = {
        tag: this.tag,
        pageToken: this.pageToken,
        limit: this.limit
      }
      const res: V2NIMChatroomMemberListResult = await chatroomService.getMemberListByTag(option)
      this.pageToken = res.pageToken
      shownDialog(true, JSON.stringify(res, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('GetMemberListByTagPage')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('get member list by tag')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

            TextInput({ placeholder: `tag`, text: this.tag })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.tag = value
              })
            Line().lineStyle()

            TextInput({ placeholder: `pageToken`, text: this.pageToken })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pageToken = value
              })
            Line().lineStyle()

            TextInput({ placeholder: `limit`, text: this.limit.toString() })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.limit = Number.parseInt(value) ?? 0
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
                this.getListByOption();
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
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }

  private getInstanceFromRouter(): V2NIMChatroomClient {
    let router: Router = this.getUIContext().getRouter();
    const instanceId: number = (router.getParams() as RouterParams).routerInstanceId;
    return NIMChatroom.getInstance(instanceId)
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