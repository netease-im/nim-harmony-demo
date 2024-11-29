import { V2NIMCustomUserStatusParams, V2NIMError } from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
import { UserModel } from '../../../viewmodel/UserModel';
import { JSON } from '@kit.ArkTS';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color')).
  height($r('app.float.login_input_height')).
  fontSize($r('app.float.big_text_size')).
  backgroundColor($r('app.color.background')).
  width(CommonConstants.FULL_PARENT).
  padding({ left: CommonConstants.INPUT_PADDING_LEFT }).
  margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT).height($r('app.float.line_height')).backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color')).
  fontSize($r('app.float.small_text_size')).
  fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct SubscribeUserStatusPage {
  @State isShowProgress: boolean = false;
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
  /**
   * 状态的有效期，单位秒，范围为 60s 到 7days
   */
  private duration: number = 60;
  /**
   * 自定义设置值： 10000以上，不包括一万， 一万以内为预定义值。小于1万，返回参数错误
   */
  private statusType: number = 10001;
  /**
   * 用户发布状态时设置的扩展字段
   */
  private extension?: string
  /**
   * 用户发布状态时是否只广播给在线的订阅者。默认为 true
   */
  private onlineOnly?: boolean
  /**
   * 用户发布状态时是否需要多端同步。默认为 false
   */
  private multiSync?: boolean

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }.
    height($r('app.float.other_login_image_size')).
    width($r('app.float.other_login_image_size')).
    backgroundColor($r('app.color.background'))
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  async subscribeUserStatus() {
    try {
      const extensionMap: Map<string, string> = new Map()
      extensionMap.set('extension', this.extension??'')

      const params = {
        statusType: this.statusType,
        duration: this.duration,
        extension: JSON.stringify(extensionMap),
        onlineOnly: this.onlineOnly,
        multiSync: this.multiSync
      } as V2NIMCustomUserStatusParams

      const subscriptionService = this.getUserModel().getNimSdk().subscriptionService!
      const subscriptionList = await subscriptionService.publishCustomUserStatus(params)
      shownDialog(true, JSON.stringify(subscriptionList, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  aboutToAppear(): void {
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('发布用户自定义状态').
              fontSize($r('app.float.page_title_text_size')).
              fontWeight(FontWeight.Medium).
              fontColor($r('app.color.title_text_color'))

            TextInput({ placeholder: '自定义设置值： 10000以上，不包括一万， 一万以内为预定义值' }).
              type(InputType.Number).
              inputStyle().
              onChange((value: string) => {
                this.statusType = parseInt(value)
              })

            TextInput({ placeholder: '状态的有效期，单位秒，范围为 60s 到 7days' }).
              type(InputType.Number).
              inputStyle().
              onChange((value: string) => {
                this.duration = parseInt(value)
              })

            TextInput({ placeholder: '用户发布状态时设置的扩展字段, 必须是JSON 字符串' }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.extension = value
              })

            Text('onlineOnly').
              fontSize($r('app.float.normal_text_size')).
              fontColor($r('app.color.login_more_text_color')).
              textAlign(TextAlign.Start).
              width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'onlineOnly', group: 'onlineOnlyGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.onlineOnly = true
                }
              })
              Text('True').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'onlineOnly', group: 'onlineOnlyGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.onlineOnly = false
                }
              })
              Text('False').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Line().lineStyle()

            Text('multiSync').
              fontSize($r('app.float.normal_text_size')).
              fontColor($r('app.color.login_more_text_color')).
              textAlign(TextAlign.Start).
              width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'multiSync', group: 'multiSyncGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.multiSync = true
                }
              })
              Text('True').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'multiSync', group: 'multiSyncGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.multiSync = false
                }
              })
              Text('False').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Line().lineStyle()

            Button(('Subscribe'), { type: ButtonType.Capsule }).
              width(CommonConstants.BUTTON_WIDTH).
              height($r('app.float.login_button_height')).
              fontSize($r('app.float.normal_text_size')).
              fontWeight(FontWeight.Medium).
              backgroundColor($r('app.color.login_button_color')).
              margin({
                top: $r('app.float.login_button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              }).
              onClick(() => {
                this.subscribeUserStatus();
              })

            if (this.isShowProgress) {
              LoadingProgress().
                color($r('app.color.loading_color')).
                width($r('app.float.login_progress_size')).
                height($r('app.float.login_progress_size')).
                margin({ top: $r('app.float.login_progress_margin_top') })
            }
            Blank()
          }
        }.backgroundColor($r('app.color.background'))
        // .height(CommonConstants.FULL_PARENT)
        .width(CommonConstants.FULL_PARENT).padding({
          left: $r('app.float.page_padding_hor'),
          right: $r('app.float.page_padding_hor'),
          bottom: $r('app.float.login_page_padding_bottom')
        })
      }.
      size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 }).
      title('发布订阅/状态').
      titleMode(NavigationTitleMode.Mini)
    }.height(CommonConstants.THOUSANDTH_1000).backgroundColor($r('app.color.primaryBgColor'))
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