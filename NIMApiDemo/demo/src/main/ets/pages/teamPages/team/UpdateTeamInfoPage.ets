import {
  V2NIMCreateTeamParams,
  V2NIMCreateTeamResult,
  V2NIMError,
  V2NIMTeamAgreeMode,
  V2NIMTeamChatBannedMode,
  V2NIMTeamInviteMode,
  V2NIMTeamJoinMode,
  V2NIMTeamType,
  V2NIMTeamUpdateExtensionMode,
  V2NIMTeamUpdateInfoMode,
  V2NIMUpdateTeamInfoParams
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
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
struct UpdateTeamInfoPage {
  @State teamId: string = ''
  @State name: string = ''
  @State teamType: V2NIMTeamType = V2NIMTeamType.V2NIM_TEAM_TYPE_NORMAL
  @State memberLimit: number | undefined = undefined
  @State intro: string | undefined = undefined
  @State announcement: string | undefined = undefined
  @State avatar: string | undefined = undefined
  @State serverExtension: string | undefined = undefined
  @State joinMode: V2NIMTeamJoinMode | undefined = undefined
  @State agreeMode: V2NIMTeamAgreeMode | undefined = undefined
  @State inviteMode: V2NIMTeamInviteMode | undefined = undefined
  @State updateInfoMode: V2NIMTeamUpdateInfoMode | undefined = undefined
  @State updateExtensionMode: V2NIMTeamUpdateExtensionMode | undefined = undefined
  @State chatBannedMode: V2NIMTeamChatBannedMode | undefined = undefined
  @State isShowProgress: boolean = false;

  private timeOutId: number = -1;
  private userModel: UserModel | undefined;
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogWidget({
      hobbies: $hobbies
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    offset: {
      dx: 0,
      dy: -20
    }
  });

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

  async updateTeamInfo(): Promise<void> {
    try {
      console.info(`-----------update team----------- \n`)
      let teamService = this.getUserModel().getNimSdk().teamService! // Demo启用team模块，teamService不为空
      const params: V2NIMUpdateTeamInfoParams = {
        name: this.name,
        memberLimit: this.memberLimit,
        intro: this.intro,
        announcement: this.announcement,
        avatar: this.avatar,
        serverExtension: this.serverExtension,
        joinMode: this.joinMode,
        agreeMode: this.agreeMode,
        inviteMode: this.inviteMode,
        updateInfoMode: this.updateInfoMode,
        updateExtensionMode: this.updateExtensionMode,
      }

      await teamService.updateTeamInfo(this.teamId, this.teamType, params )

      shownDialog(true, JSON.stringify('success', null, 2))
    } catch (error) {
      console.log('----------- update 失败 -----------', error)
      shownDialog(false, processV2ErrorForPrint(error))
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
        Scroll() {
          Column() {
            Text('Update')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('update team info')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            TextInput({ text: this.teamId, placeholder: '输入 群组Id' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.teamId = value;
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组类型' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.teamType = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ text: this.name, placeholder: '输入 群组名称' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.name = value;
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组人数上限' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.memberLimit = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组介绍' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.intro = value
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组公告' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.announcement = value
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组头像' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.avatar = value
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 服务端扩展字段' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.serverExtension = value
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 申请入群模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.joinMode = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 被邀请人同意入群模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.agreeMode = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 邀请入群模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.inviteMode = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组资料修改模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.updateInfoMode = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组扩展字段修改模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.updateExtensionMode = parseInt(value);
              })
            Line().lineStyle()

            TextInput({ placeholder: '输入 群组禁言模式' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.chatBannedMode = parseInt(value);
              })
            Line().lineStyle()

            Button(('updateTeamInfo'), { type: ButtonType.Capsule })
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
                this.updateTeamInfo();
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
        }
        .backgroundColor($r('app.color.background'))
        // .height(CommonConstants.FULL_PARENT)
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