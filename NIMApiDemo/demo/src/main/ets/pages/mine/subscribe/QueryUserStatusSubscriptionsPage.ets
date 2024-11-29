import { V2NIMError, V2NIMSubscribeUserStatusOption } from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
import { UserModel } from '../../../viewmodel/UserModel';

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
struct QueryUserStatusSubscriptionsPage {
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
  private duration: number = 60;
  private accountIds: string = ''
  private immediateSync: boolean = false

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

  async queryUserStatusSubscriptions() {
    try {
      const accountIds = this.accountIds.split(',')
      const subscriptionService = this.getUserModel().getNimSdk().subscriptionService!
      const query = await subscriptionService.queryUserStatusSubscriptions(accountIds)
      shownDialog(true, JSON.stringify(query, null, 2))
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
            Text('查询用户状态订阅关系').
              fontSize($r('app.float.page_title_text_size')).
              fontWeight(FontWeight.Medium).
              fontColor($r('app.color.title_text_color'))

            TextInput({ placeholder: '账号字符串，以逗号分隔' }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.accountIds = value
              })

            Button(('Query'), { type: ButtonType.Capsule }).
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
                this.queryUserStatusSubscriptions();
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