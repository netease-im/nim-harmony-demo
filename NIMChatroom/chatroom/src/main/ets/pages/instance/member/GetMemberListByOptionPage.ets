import { V2NIMError } from '@nimsdk/base'
import { V2NIMChatroomClient,
  V2NIMChatroomMemberListResult,
  V2NIMChatroomMemberQueryOption,
  V2NIMChatroomMemberRole,
  V2NIMChatroomService, } from '@nimsdk/chatroom'
import { CommonConstants, shownDialog } from '../../../constants/CommonConstants'
import { Router } from '@kit.ArkUI'
import { RouterParams } from '../../ChatroomInstancePage'
import NIMChatroom from '../../../sdk/chatroom'
import { HashSet } from '@kit.ArkTS'

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
struct GetMemberListByOptionPage {
  @State tag: string = 'tag1';
  @State memberRoles: HashSet<V2NIMChatroomMemberRole> | undefined = undefined
  @State onlyBlocked: boolean | undefined = undefined
  @State onlyChatBanned: boolean | undefined = undefined
  @State onlyOnline: boolean | undefined = undefined
  @State pageToken: string = ""
  @State limit: number = 3

  async getListByOption(): Promise<void> {
    try {
      const chatroomService: V2NIMChatroomService = this.getInstanceFromRouter().chatroomService!
      const option: V2NIMChatroomMemberQueryOption = {
        memberRoles: typeof this.memberRoles === 'undefined' ? undefined : Array.from(this.memberRoles),
        onlyBlocked: this.onlyBlocked,
        onlyChatBanned: this.onlyChatBanned,
        onlyOnline: this.onlyOnline,
        pageToken: this.pageToken,
        limit: this.limit
      }
      const res: V2NIMChatroomMemberListResult = await chatroomService.getMemberListByOption(option)
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
            Text('GetMemberListByOptionPage')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('get member list by option')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

            // member types
            Text('member roles')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            // 全选按钮
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              CheckboxGroup({ group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((itemName: CheckboxGroupResult) => {
                  console.info("checkbox group content" + JSON.stringify(itemName))
                })
              Text('全选')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'NORMAL', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_NORMAL)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_NORMAL)
                  }
                })
              Text('NORMAL')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'CREATOR', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_CREATOR)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_CREATOR)
                  }
                })
              Text('CREATOR')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'MANAGER', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_MANAGER)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_MANAGER)
                  }
                })
              Text('MANAGER')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'MANAGER', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_MANAGER)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_MANAGER)
                  }
                })
              Text('MANAGER')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'NORMAL_GUEST', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_NORMAL_GUEST)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_NORMAL_GUEST)
                  }
                })
              Text('NORMAL_GUEST')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'ANONYMOUS_GUEST', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_ANONYMOUS_GUEST)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_ANONYMOUS_GUEST)
                  }
                })
              Text('ANONYMOUS_GUEST')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'VIRTUAL', group: 'checkboxGroupMemberType' })
                .selectedColor('#007DFF')
                .onChange((on: boolean) => {
                  if (typeof this.memberRoles === 'undefined') {
                    this.memberRoles = new HashSet<V2NIMChatroomMemberRole>()
                  }
                  if (on) {
                    this.memberRoles.add(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_VIRTUAL)
                  } else {
                    this.memberRoles.remove(V2NIMChatroomMemberRole.V2NIM_CHATROOM_MEMBER_ROLE_VIRTUAL)
                  }
                })
              Text('VIRTUAL')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }.margin({ left: 36 })

            Line().lineStyle()

            Text('onlyBlocked')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'on', group: 'onlyBlockedGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyBlocked = true
                  }
                })
              Text('ON')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'off', group: 'onlyBlockedGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyBlocked = false
                  }
                })
              Text('OFF')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            
            Line().lineStyle()

            Text('onlyChatBanned')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'on', group: 'onlyChatBannedGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyChatBanned = true
                  }
                })
              Text('ON')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'off', group: 'onlyChatBannedGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyChatBanned = false
                  }
                })
              Text('OFF')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()

            Text('onlyOnline')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'on', group: 'onlyOnlineGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyOnline = true
                  }
                })
              Text('ON')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'off', group: 'onlyOnlineGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.onlyOnline = false
                  }
                })
              Text('OFF')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

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