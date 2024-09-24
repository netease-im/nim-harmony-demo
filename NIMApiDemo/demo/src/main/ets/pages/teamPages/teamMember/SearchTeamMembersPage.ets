import { V2NIMError, V2NIMSortOrder,
  V2NIMTeamMemberSearchOption,
  V2NIMTeamType, V2NIMUpdateSelfMemberInfoParams, } from '@nimsdk/base';
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
struct SearchTeamMembersPage {
  @State keyword: string = ''
  @State teamType: V2NIMTeamType = V2NIMTeamType.V2NIM_TEAM_TYPE_NORMAL
  @State teamId: string = ''
  @State nextToken: string = ''
  @State order: V2NIMSortOrder = V2NIMSortOrder.V2NIM_SORT_ORDER_ASC
  @State limit: number = 10
  @State initNextToken: string = ''

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

  async searchTeamMembers(): Promise<void> {
    try {
      // get service
      let teamService = this.getUserModel().getNimSdk().teamService! // Demo启用team模块，teamService不为空

      // input
      const teamId: string = this.teamId
      const teamType: V2NIMTeamType = this.teamType
      const initNextToken: string = this.initNextToken
      const order: V2NIMSortOrder = this.order
      const limit: number = this.order
      const keyword: string = this.keyword
      const nextToken: string = this.nextToken
      const options = {
        keyword: keyword,
        teamId: teamId,
        teamType: teamType,
        nextToken: nextToken,
        initNextToken: initNextToken,
        limit: limit,
        order: order
      } as V2NIMTeamMemberSearchOption
      // call interface
      //const res = await teamService.searchTeamMembers(options)
      //shownDialog(true, JSON.stringify(res, null, 2))
    }
    catch (err) {
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
          Text('SearchTeamMembers')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('search team members by options')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })
          TextInput({ text: this.keyword, placeholder: '输入 keyword' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.keyword = value
            })
          Line().lineStyle()

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
          TextInput({ placeholder: '输入 limit' })
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.limit = parseInt(value)
            })
          Line().lineStyle()

          TextInput({ placeholder: '输入 nextToken' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.nextToken = value
            })
          Line().lineStyle()

          TextInput({ placeholder: '输入 initNextToken' })
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.initNextToken = value
            })
          Line().lineStyle()

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'ASC', group: 'V2NIMSortOrder' }).checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.order = V2NIMSortOrder.V2NIM_SORT_ORDER_ASC
                }
              })
            Text('ASC')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'DES', group: 'V2NIMSortOrder' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.order = V2NIMSortOrder.V2NIM_SORT_ORDER_DESC
                }
              })
            Text('DES')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          Button(('Search'), { type: ButtonType.Capsule })
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
              this.searchTeamMembers();
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
      .title('群成员搜索')
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