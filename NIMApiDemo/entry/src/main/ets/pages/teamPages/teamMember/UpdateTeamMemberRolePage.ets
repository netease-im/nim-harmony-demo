import { V2NIMError, V2NIMTeamMemberRole, V2NIMTeamType, } from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/constants/CommonConstants';
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
struct UpdateTeamMemberRolePage {
  @State teamId: string = ''
  @State teamType: V2NIMTeamType = V2NIMTeamType.V2NIM_TEAM_TYPE_NORMAL
  @State memberAccountIds: string = ''
  @State memberRole: V2NIMTeamMemberRole = V2NIMTeamMemberRole.V2NIM_TEAM_MEMBER_ROLE_NORMAL
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

  async callInterface(): Promise<void> {
    console.info(`----------设置成员角色--------- \n`)
    try {
      // get service
      let teamService = this.getUserModel().getNimSdk().teamService! // Demo启用team模块，teamService不为空

      // input
      const teamId: string = this.teamId
      const teamType: V2NIMTeamType = this.teamType
      const memberAccountIds: string[] = this.memberAccountIds.split(',') // 以 ',' 分割
      const memberRole: V2NIMTeamMemberRole = this.memberRole

      // call interface
      const res = await teamService.updateTeamMemberRole(teamId, teamType, memberAccountIds, memberRole)
      console.info(`-----------设置成员角色 成功----------- ${res}`)
      shownDialog(true, JSON.stringify(res, null, 2))
    }
    catch (err) {
      console.error(`-----------设置成员角色 失败---------- \n`, `${err}`)
      shownDialog(false, processV2ErrorForPrint(err))
      return
    }
  }

  aboutToAppear(): void {
    // this.teamId = '123'
  }

  aboutToDisappear() {
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('UpdateTeamMemberRole')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('update team member role method')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })
          TextInput({ text: this.teamId, placeholder: '输入 team id' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.teamId = value
            })
          Line().lineStyle()

          Text('team type')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .textAlign(TextAlign.Start)
            .width('100%')
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'team', group: 'teamTypeGroup' }).checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.teamType = V2NIMTeamType.V2NIM_TEAM_TYPE_NORMAL
                }
              })
            Text('team')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'superTeam', group: 'teamTypeGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.teamType = V2NIMTeamType.V2NIM_TEAM_TYPE_SUPER
                }
              })
            Text('superTeam')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Line().lineStyle()

          TextInput({ text: 'cjl1,cjl2', placeholder: '输入 inviteeAccount ids' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.memberAccountIds = value
            })
          Line().lineStyle()

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'ROLE_NORMAL', group: 'V2NIMTeamMemberRoleGroup' }).checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.memberRole = V2NIMTeamMemberRole.V2NIM_TEAM_MEMBER_ROLE_NORMAL
                }
              })
            Text('ROLE_NORMAL')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'ROLE_OWNER', group: 'V2NIMTeamMemberRoleGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.memberRole = V2NIMTeamMemberRole.V2NIM_TEAM_MEMBER_ROLE_OWNER
                }
              })
            Text('ROLE_OWNER')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'ROLE_MANAGER', group: 'V2NIMTeamMemberRoleGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.memberRole = V2NIMTeamMemberRole.V2NIM_TEAM_MEMBER_ROLE_MANAGER
                }
              })
            Text('ROLE_MANAGER')
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
            .margin({
              top: $r('app.float.login_button_margin_top'),
              bottom: $r('app.float.login_button_margin_bottom')
            })
            .onClick(() => {
              this.callInterface();
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