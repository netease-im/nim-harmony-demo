import {
  V2NIMError, V2NIMFriendAddMode, V2NIMFriendAddParams,
  V2NIMTeamMessageMuteMode,
  V2NIMTeamType,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/constants/CommonConstants';
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
struct SetTeamMessageMuteModePage {
  @State teamId?: string = undefined
  @State teamType?: V2NIMTeamType = undefined
  @State muteMode?: V2NIMTeamMessageMuteMode = undefined

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

  async settingSetTeamMessageMuteMode(): Promise<void> {
    try {
      const settingService = this.getUserModel().getNimSdk().settingService!
      const res = await settingService.setTeamMessageMuteMode(
        this.teamId,
        this.teamType,
        this.muteMode
      )
      shownDialog(true, JSON.stringify(res, null, 2))
    } catch (error) {
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
            Text('Set Team Message MuteMode')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('Set Team Message MuteMode')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            TextInput({ placeholder: 'teamId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.teamId = value;
              })
            Line().lineStyle()

            Text('team type')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'team', group: 'teamTypeGroup' })
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

            Text('mute mode')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: '群消息免打扰关闭', group: 'muteModeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.muteMode = V2NIMTeamMessageMuteMode.V2NIM_TEAM_MESSAGE_MUTE_MODE_OFF
                  }
                })
              Text('群消息免打扰关闭')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: '群消息免打扰开启', group: 'muteModeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.muteMode = V2NIMTeamMessageMuteMode.V2NIM_TEAM_MESSAGE_MUTE_MODE_ON
                  }
                })
              Text('群消息免打扰开启')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: '发送者为普通成员的群消息免打扰开启', group: 'muteModeGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.muteMode = V2NIMTeamMessageMuteMode.V2NIM_TEAM_MESSAGE_MUTE_MODE_NORMAL_ON
                  }
                })
              Text('发送者为普通成员的群消息免打扰开启')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }
            Line().lineStyle()



            Button(('Get'), { type: ButtonType.Capsule })
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
                this.settingSetTeamMessageMuteMode();
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