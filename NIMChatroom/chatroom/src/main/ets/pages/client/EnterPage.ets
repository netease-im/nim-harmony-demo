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
export struct GetInstancePage {
  @State instanceId: number = 1
  @State roomId: string = `3003`
  @State accountId: string = 'cjl1'
  @State roomNick: string = 'cs1Nick'
  @State roomAvatar: string = 'cs1RoomAvatar'
  @State token: string = 'e10adc3949ba59abbe56e057f20f883e'
  @State linkAddress: string[] = ['chatweblink10.netease.im:443']
  @State serverExtension: string = 'serverExtension'
  @State notificationExtension: string = 'notificationExtension'
  @State tags: string[] = ['tag1', 'tag2']
  @State notifyTargetTags: string = '{"tag": "tag1"}'
  @State distance: number = 500
  @State locationInfo_x: number = 3.1
  @State locationInfo_y: number = 4.1
  @State locationInfo_z: number = 5.1

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('Client')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('enter')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          TextInput({ placeholder: `${this.instanceId}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.instanceId = parseInt(value)
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.roomId}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.roomId = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.accountId}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.accountId = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.roomId}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.instanceId = parseInt(value)
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.roomNick}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.roomNick = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.roomAvatar}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.roomAvatar = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.token}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.token = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.serverExtension}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.serverExtension = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          TextInput({ placeholder: `${this.notificationExtension}` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.notificationExtension = value
            })
          // Line().outlineStyle(OutlineStyle.SOLID)

          Button(('enter'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.enter();
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

  async enter(){
    console.info(`-----------enter chatroom----------- \n`)
    try {
      const ret = await NIMChatroom.enter(
        this.instanceId,
        this.roomId,
        this.accountId,
        this.roomNick,
        this.roomAvatar,
        this.token,
        this.linkAddress,
        this.serverExtension,
        this.notificationExtension,
        this.tags,
        this.notifyTargetTags,
        this.distance,
        this.locationInfo_x,
        this.locationInfo_y,
        this.locationInfo_z)
      shownDialog(true, JSON.stringify(ret, null, 2))
    }
    catch (err) {
      shownDialog(true, processV2ErrorForPrint(err))
      return
    }
  }
}