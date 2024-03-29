import {
  V2NIMError,
} from '@nimsdk/base';
import Base, { BusinessError } from '@ohos.base';
import { CommonConstants, shownDialog } from '../../../common/constants/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
import { UserModel } from '../../../viewmodel/UserModel';
import { notificationManager } from '@kit.NotificationKit';
import { pushService } from '@kit.PushKit';

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
struct PushServicePage {
  private userModel: UserModel | undefined;
  @State loggerText: string = 'Push logger:';

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
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }

  aboutToAppear(): void {
  }

  aboutToDisappear() {
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Button('Request enable notification', { type: ButtonType.Normal, stateEffect: true })
              .width('100%')
              .borderRadius(8)
              .height(40)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                this.onClickRequestEnableNotification()
                console.info('Button onClick, request enable notification')
              })

            Button('Register a token', { type: ButtonType.Normal, stateEffect: true })
              .width('100%')
              .borderRadius(8)
              .height(40)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                this.doRegisterPushToken()
                console.info('Button onClick, register push token')
              })

            Button('PushService.enable(true)', { type: ButtonType.Normal, stateEffect: true })
              .width('100%')
              .borderRadius(8)
              .height(40)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                console.info('Button onClick, PushService.enable(true)')

                this.getUserModel().getNimSdk().pushService.enable(true)
                  .then(() => {
                    console.info("Push service page, enable push token success")
                    this.logText("[SID 26 , CID 6 ] enable success");
                  })
                  .catch((error: Error) => {
                    console.error("Push service page, enable push token fail", error)
                    this.logText("[SID 26 , CID 6 ] enable failed");
                  });
                ;
              })

            Button('PushService.enable(false)', { type: ButtonType.Normal, stateEffect: true })
              .width('100%')
              .borderRadius(8)
              .height(40)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                console.info('Button onClick, PushService.enable(false)')

                this.getUserModel().getNimSdk().pushService.enable(false)
                  .then(() => {
                    console.info("Push service page, disable push token success")
                    this.logText("[SID 26 , CID 6 ] disable success");
                  })
                  .catch((error: Error) => {
                    console.error("Push service page, disable push token fail", error)
                    this.logText("[SID 26 , CID 6 ] disable failed");
                  });
              })

            Button('Clear log', { type: ButtonType.Normal, stateEffect: true })
              .width('100%')
              .borderRadius(8)
              .height(40)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                this.loggerText = 'Push logger:';
              })

            Text(this.loggerText)
              .textAlign(TextAlign.Start)
              .margin({ top: 5, bottom: 5 })
              .padding(5)
              .borderRadius(8)
              .id('Push logger:')
              .width('100%')
              .backgroundColor("#DDDDDD")
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

  async doRegisterPushToken(): Promise<void> {
    // Register Harmony push token
    try {
      const pushToken: string = await pushService.getToken();
      console.info('Push', 'Get push token successfully: ', pushToken);
      this.logText("success: " + pushToken);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('Push', 'Get push token catch error: ', e.code, e.message);
      this.logText("error: " + e.code + " " + e.message);
    }
  }

  onClickRequestEnableNotification(): void {
    notificationManager.requestEnableNotification().then(() => {
      console.info(`[ANS] requestEnableNotification success`);
    }).catch((err:Base.BusinessError) => {
      console.error(`[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  logText(log: string): void {
    this.loggerText += "\n" + log;
  }
}


