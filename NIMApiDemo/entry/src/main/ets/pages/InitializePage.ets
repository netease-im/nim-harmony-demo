import { NIMSdk } from 'nim/Index';
import { CommonConstants } from '../common/constants/CommonConstants';
import { UserModel } from '../viewmodel/UserModel';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct Index {
  // TextInput多行显示存在Bug，暂时使用单行字符串
  @State initializeOptions: string = '{"appkey":"fe416640c8e8a72734219e1847ad2547","debugLevel":"debug","xhrConnectTimeout":30000,"socketConnectTimeout":30000}';
  @State serviceOptions: string = '{"loginServiceConfig":{"lbsUrls":["https://imtest.netease.im/lbs/webconf"],"linkUrl":"imtest-jd.netease.im:8091"}}';

  build() {
    Navigation() {
      Row() {
        Column() {
          TextInput({ text: this.initializeOptions, placeholder: 'NIMInitializeOptions' })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .maxLines(Number.MAX_VALUE)
            .enterKeyType(EnterKeyType.Done)
            .placeholderColor($r('app.color.text_input_place_holder'))
            .placeholderFont({ size: $r('app.float.text_input_font_size') })
            .fontSize($r('app.float.text_input_font_size'))
            .backgroundColor($r('app.color.login_input_text_background'))
            .padding({ left: $r('app.float.password_padding_left') })
            .border({
              width: { bottom: $r('app.float.input_border_width') },
              color: $r('app.color.input_border_color'),
              radius: $r('app.float.input_border_radius')
            })
            .margin({ bottom: $r('app.float.input_margin_bottom') })
            .onChange((value: string) => {
              this.initializeOptions = value;
            })

          TextInput({ text: this.serviceOptions, placeholder: 'NIMServiceOptions' })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .maxLines(Number.MAX_VALUE)
            .enterKeyType(EnterKeyType.Done)
            .placeholderColor($r('app.color.text_input_place_holder'))
            .placeholderFont({ size: $r('app.float.text_input_font_size') })
            .fontSize($r('app.float.text_input_font_size'))
            .backgroundColor($r('app.color.login_input_text_background'))
            .padding({ left: $r('app.float.password_padding_left') })
            .border({
              width: { bottom: $r('app.float.input_border_width') },
              color: $r('app.color.input_border_color'),
              radius: $r('app.float.input_border_radius')
            })
            .margin({ bottom: $r('app.float.input_margin_bottom') })
            .onChange((value: string) => {
              this.serviceOptions = value;
            })

          Button('初始化NIM')
            .width(CommonConstants.BUTTON_WIDTH_PERCENT)
            .height($r('app.float.login_btn_height'))
            .borderRadius($r('app.float.login_btn_border_radius'))
            .fontSize($r('app.float.text_input_font_size'))
            .margin({ top: $r('app.float.register_btn_margin_top') })
            .fontWeight(CommonConstants.LOGIN_TEXT_FONT_WEIGHT)
            .onClick(() => {
              this.getUserModel().initNim(JSON.parse(this.initializeOptions), JSON.parse(this.serviceOptions))
              prompt.showToast({
                message: 'NIM初始化成功'
              })
            })
        }
        .width('100%')
      }
      .height('100%')
    }
    .title('InitializePage')
    .titleMode(NavigationTitleMode.Mini)
  }

  private userModel: UserModel | undefined;
  getUserModel(): UserModel {
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }
}