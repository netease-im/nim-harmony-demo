import { V2NIMError } from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
import { UserModel } from '../../../viewmodel/UserModel';

@Entry
@Component
struct GetCurrentLoginClientPage {
  @State roomId: string = ''
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
  private timeOutId: number = -1;

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }
    ) {
      Image(src)
    }.
    height($r('app.float.other_login_image_size')).
    width($r('app.float.other_login_image_size')).
    backgroundColor($r('app.color.background'))
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  getCurrentLoginClient() {
    try {
      const loginService = this.getUserModel().getNimSdk().loginService!
      const res = loginService.getCurrentLoginClient()
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
            Text('Get current login client').
              fontSize($r('app.float.page_title_text_size')).
              fontWeight(FontWeight.Medium).
              fontColor($r('app.color.title_text_color'))
            Text('get current login info').
              fontSize($r('app.float.normal_text_size')).
              fontColor($r('app.color.login_more_text_color')).
              margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            Button(('GetCurrentLoginInfo'), { type: ButtonType.Capsule }).
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
                this.getCurrentLoginClient();
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
        }
        )
      }.
      size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 }).
      title('back').
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