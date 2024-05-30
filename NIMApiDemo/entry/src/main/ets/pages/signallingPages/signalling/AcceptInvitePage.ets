import {
  V2NIMError,
  V2NIMSignalingEventType,
  V2NIMSignallingAcceptInviteParams,
  V2NIMSignallingCancelInviteParams, V2NIMSignallingChannelType,
  V2NIMSignallingEvent,
  V2NIMSignallingRejectInviteParams,
} from '@nimsdk/base/Index';
import { CommonConstants, shownDialog, shownListenerDialog } from '../../../common/constants/CommonConstants';
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
struct AcceptInvitePage {

  @State channelId: string = ''
  @State inviterAccountId: string = ''
  @State requestId: string = ''
  @State serverExtension: string = ''
  @State offlineEnabled: boolean = false
  @State isShowProgress: boolean = false
  private event?: V2NIMSignallingEvent
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

  async acceptInviteRoom(): Promise<void> {
    try {
      console.info(`-----------acceptInvite room----------- \n`)
      let signalingService = this.getUserModel().getNimSdk().signallingService!
      const params: V2NIMSignallingAcceptInviteParams = {
        channelId: this.channelId,
        inviterAccountId: this.inviterAccountId,
        requestId: this.requestId,
        serverExtension: this.serverExtension,
        offlineEnabled: this.offlineEnabled
      }

      await signalingService.acceptInvite(params)
      console.log(`----------- acceptInvite room----------- ${JSON.stringify('acceptInvite', null, 2)}`)
      shownDialog(true, JSON.stringify('acceptInvite', null, 2))
    } catch (error) {
      console.log('----------- acceptInvite 失败 -----------', error)
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  aboutToAppear(): void {
    this.getUserModel().getNimSdk().signallingService!.on("onOnlineEvent", (event: V2NIMSignallingEvent) => {
      if (event.eventType === V2NIMSignalingEventType.V2NIM_SIGNALLING_EVENT_TYPE_INVITE) {
        shownListenerDialog('收到邀请', JSON.stringify(event, null, 2))
        this.event = event
        this.channelId = this.event.channelInfo.channelId
        this.inviterAccountId = this.event.inviterAccountId ?? ''
        this.requestId = this.event.requestId

      }
    })
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
            Text('Accept invite')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('accept invite ')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            TextInput({ text: this.channelId, placeholder: '输入 channelId' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelId = value;
              })
            Line().lineStyle()

            TextInput({ text: this.inviterAccountId, placeholder: '输入 inviterAccountId' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.inviterAccountId = value;
              })
            Line().lineStyle()

            TextInput({ text: this.requestId, placeholder: '输入 requestId' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.requestId = value
              })
            Line().lineStyle()
            TextInput({ placeholder: '输入 serverExtension' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.serverExtension = value
              })
            Line().lineStyle()
            TextInput({ placeholder: '输入 offlineEnabled ' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.offlineEnabled = parseInt(value) > 0 ? true : false
              })
            Line().lineStyle()
            Button(('AcceptInvite'), { type: ButtonType.Capsule })
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
                this.acceptInviteRoom()
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