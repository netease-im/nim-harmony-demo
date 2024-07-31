import {
  V2NIMError,
  V2NIMSignallingCancelInviteParams,
  V2NIMSignallingChannelInfo,
  V2NIMSignallingChannelType, V2NIMSignallingInviteParams
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
struct CancelInvitePage {
  @State channelType: V2NIMSignallingChannelType = V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO
  @State channelName: string = ''
  @State channelExt: string = ''
  @State channelId: string = ''
  @State inviteeAccountId: string = ''
  @State requestId: string = ''
  @State serverExtension: string = ''
  @State offlineEnabled: boolean = false;
  @State unreadEnabled: boolean = false;
  @State selfUid: number = 0;
  @State pushEnabled: boolean = false;
  @State pushTitle: string = '';
  @State pushContent: string = '';
  @State pushPayload: string = '';

  @State isShowProgress: boolean = false;

  private timeOutId: number = -1;
  private userModel: UserModel | undefined;
  @State channelInfo: V2NIMSignallingChannelInfo = {} as V2NIMSignallingChannelInfo
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

  async cancelInviteRoom(): Promise<void> {
    try {
      console.info(`-----------cancelInvite room----------- \n`)
      let signalingService = this.getUserModel().getNimSdk().signallingService!
      const params: V2NIMSignallingCancelInviteParams = {
        channelId: this.channelId,
        inviteeAccountId: this.inviteeAccountId,
        requestId: this.requestId,
        serverExtension: this.serverExtension,
        offlineEnabled: this.offlineEnabled
      }

      await signalingService.cancelInvite(params)
      console.log(`----------- cancelInvite room----------- ${JSON.stringify('cancelInvite', null, 2)}`)
      shownDialog(true, JSON.stringify('cancelInvite', null, 2))
    } catch (error) {
      console.log('----------- cancelInvite 失败 -----------', error)
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async createRoom(): Promise<void> {
    try {
      console.info(`-----------create room----------- \n`)
      let signalingService = this.getUserModel().getNimSdk().signallingService!
      this.channelInfo = await signalingService.createRoom(this.channelType,
        this.channelName, this.channelExt)
      console.log(`----------- create room----------- ${JSON.stringify(this.channelInfo, null, 2)}`)
      shownDialog(true, JSON.stringify(this.channelInfo, null, 2))
    } catch (error) {
      console.log('----------- create 失败 -----------', error)
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  async inviteRoom(): Promise<void> {
    try {
      console.info(`-----------invite room----------- \n`)
      let signalingService = this.getUserModel().getNimSdk().signallingService! // Demo启用team模块，teamService不为空
      const params: V2NIMSignallingInviteParams = {
        channelId: this.channelId,
        inviteeAccountId: this.inviteeAccountId,
        requestId: this.requestId,
        serverExtension: this.serverExtension,
        pushConfig: {
          pushEnabled: this.pushEnabled,
          pushTitle: this.pushTitle,
          pushContent: this.pushContent,
          pushPayload: this.pushPayload
        },
        signallingConfig: {
          offlineEnabled: this.offlineEnabled,
          unreadEnabled: this.unreadEnabled,
          selfUid: this.selfUid
        }
      }

      await signalingService.invite(params)
      console.log(`----------- invite room----------- ${JSON.stringify('invite', null, 2)}`)
      shownDialog(true, JSON.stringify('invite', null, 2))
    } catch (error) {
      console.log('----------- invite 失败 -----------', error)
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
            Text('CancelInvite')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('cancel room ')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })
            Line().lineStyle()
            Text('先创建Room ')
              .fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.blueColor'))

            TextInput({ text: this.channelName, placeholder: '输入 Room 名称' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelName = value;
              })

            Text('Room channel 类型')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'AUDIO', group: 'channelGroupType' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.channelType = V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO
                  }
                })
              Text('CHANNEL_TYPE_AUDIO')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'VIDEO', group: 'channelGroupType' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.channelType = V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO
                  }
                })
              Text('CHANNEL_TYPE_VIDEO')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'CUSTOM', group: 'channelGroupType' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.channelType = V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_CUSTOM
                  }
                })
              Text('CHANNEL_TYPE_CUSTOM')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            TextInput({ placeholder: '输入 room 扩展' })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.channelExt = value
              })

            Button(('createRoom'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.createRoom();
              })

            Line().lineStyle()
            Text('必填参数 ')
              .fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.blueColor'))

            TextInput({ text: this.channelInfo?.channelId, placeholder: '输入 channelId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelId = value;
              })
            TextInput({ placeholder: '输入 inviteeAccountId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.inviteeAccountId = value;
              })
            TextInput({ placeholder: '输入 requestId' })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.requestId = value
              })
            Line().lineStyle()
            Text('推送配置 ')
              .fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.blueColor'))
            Row(){
              Text('pushEnabled ')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.pushEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            TextInput({ placeholder: '输入 pushTitle ' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushTitle = value
              })
            TextInput({ placeholder: '输入 pushContent ' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushContent = value
              })
            TextInput({ placeholder: '输入 pushPayload ' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushPayload = value
              })
            Line().lineStyle()

            Row(){
              Text('offlineEnabled ')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.offlineEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            Line().lineStyle()
            Row(){
              Text('unreadEnabled ')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.unreadEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            Line().lineStyle()
            TextInput({ placeholder: '输入 selfUid ' })
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.selfUid = parseInt(value)
              })
            Line().lineStyle()

            Button(('inviteRoom'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.login_button_margin_bottom'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.inviteRoom();
              })
            Line().lineStyle()
            Text('取消邀请 ')
              .fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.blueColor'))

            TextInput({ text: this.channelId, placeholder: '输入 channelId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelId = value;
              })

            TextInput({ text: this.inviteeAccountId, placeholder: '输入 inviteeAccountId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.inviteeAccountId = value;
              })
            TextInput({text: this.requestId,  placeholder: '输入 requestId' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.requestId = value
              })
            TextInput({ text: this.serverExtension, placeholder: '输入 serverExtension' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.serverExtension = value
              })
            Row(){
              Text('offlineEnabled ')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.offlineEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            Button(('cancelInvite'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.cancelInviteRoom();
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