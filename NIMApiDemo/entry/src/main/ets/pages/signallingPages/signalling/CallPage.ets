import {
  V2NIMError,
  V2NIMSignallingCallParams,
  V2NIMSignallingCallResult,
  V2NIMSignallingChannelType,
} from '@nimsdk/base/Index';
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
struct CallPage {
  @State channelType: V2NIMSignallingChannelType = V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO
  @State calleeAccountId: string = ''
  @State requestId: string = ''
  @State isShowProgress: boolean = false;

  private channelName?: string = undefined
  private channelExtension?:string = undefined
  private serverExtension?:string = undefined

  // private signallingConfig?: V2NIMSignallingConfig = undefined
  private offlineEnabled?: boolean
  private unreadEnabled?: boolean
  private selfUid?: number

  // private pushConfig?: V2NIMSignallingPushConfig = undefined
  // 是否需要推送，true表示推送，false表示不推送
  private pushEnabled?: boolean
  // 推送标题
  private pushTitle?: string
  // 推送内容
  private pushContent?: string
  // 推送自定义字段
  private pushPayload?: string

  // private rtcConfig?: V2NIMSignallingRtcConfig = undefined
  // 云信音视频房间频道名称
  private rtcChannelName?: string
  // 音视频房间token过期时间
  private rtcTokenTtl?: number
  // JSON格式字符串， 音视频SDK相关参数， IM信令仅透传相关参数
  private rtcParams?: string

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

  async call(): Promise<void> {
    try {
      console.info(`-----------call----------- \n`)
      let signalingService = this.getUserModel().getNimSdk().signallingService!
      const params: V2NIMSignallingCallParams = {
        calleeAccountId: this.calleeAccountId,
        requestId: this.requestId,
        channelType: this.channelType,
        channelName: this.channelName,
        channelExtension: this.channelExtension,
        serverExtension: this.serverExtension,
        signallingConfig: {
          unreadEnabled: this.unreadEnabled,
          offlineEnabled: this.offlineEnabled,
          selfUid: this.selfUid
        },
        pushConfig: {
          pushEnabled: this.pushEnabled,
          pushTitle: this.pushTitle,
          pushContent: this.pushContent,
          pushPayload: this.pushPayload
        },
        rtcConfig: {
          rtcChannelName: this.rtcChannelName,
          rtcTokenTtl: this.rtcTokenTtl,
          rtcParams: this.rtcParams
        }
      }

      const result:V2NIMSignallingCallResult = await signalingService.call(params)
      console.log(`----------- call----------- ${JSON.stringify(result, null, 2)}`)
      shownDialog(true, JSON.stringify(result, null, 2))
    } catch (error) {
      console.log('----------- call 失败 -----------', error)
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
            Text('Call')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('call ')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            TextInput({ text: this.calleeAccountId, placeholder: '输入 calleeAccountId' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.calleeAccountId = value;
              })
            Line().lineStyle()

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

            Line().lineStyle()

            TextInput({ placeholder: '输入 requestId' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.requestId = value
              })
            Line().lineStyle()
            TextInput({ placeholder: '输入 channelName' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelName = value
              })
            Line().lineStyle()
            TextInput({ placeholder: '输入 channelExtension' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.channelExtension = value
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
            Text('signallingConfig 选填').fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.login_button_color'))
            Row(){
              Text('offlineEnabled 设置')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.offlineEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)
            Row(){
              Text('unreadEnabled 设置')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.unreadEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            TextInput({ placeholder: '输入 selfUid' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.selfUid = parseInt(value)
              })
            Line().lineStyle()

            Text('pushConfig 选填').fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.login_button_color'))
            Row(){
              Text('pushEnabled 设置')
                .fontSize($r('app.float.big_text_size'))
              Toggle({ type: ToggleType.Switch, isOn: false })
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    this.pushEnabled = isOn
                  }
                }
                )
            }.width('100%').height(50).justifyContent(FlexAlign.SpaceEvenly)

            TextInput({ placeholder: '输入 pushTitle' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushTitle = value
              })
            TextInput({ placeholder: '输入 pushContent' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushContent = value
              })
            TextInput({ placeholder: '输入 pushPayload' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.pushPayload = value
              })
            Line().lineStyle()
            Text('rtcConfig 选填').fontSize($r('app.float.big_text_size'))
              .fontColor($r('app.color.login_button_color'))
            TextInput({ placeholder: '输入 rtcChannelName' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.rtcChannelName = value
              })
            TextInput({ placeholder: '输入 rtcTokenTtl' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.rtcTokenTtl = parseInt(value)
              })
            TextInput({ placeholder: '输入 rtcParams' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.rtcParams = JSON.stringify(value)
              })
            Line().lineStyle()

            Button(('Call'), { type: ButtonType.Capsule })
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
                this.call();
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