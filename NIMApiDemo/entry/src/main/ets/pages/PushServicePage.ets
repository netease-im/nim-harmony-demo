import { CommonConstants } from '../common/constants/CommonConstants';
import { TitleWithBack } from '../view/TitleWithBack';
import pushService from '@hms.core.push.pushService';
import { BusinessError } from '@ohos.base';
import notificationManager from '@ohos.notificationManager';
import Base from '@ohos.base';
import { UserModel } from '../viewmodel/UserModel';

/**
 * Push Center page, register push token here and commit it to NIM service for the delegation of Harmony push.
 */
@Entry
@Component

struct PushServicePage {
  build() {
    Column() {
      TitleWithBack({ title: "PushService" })
      Scroll() {
        GridRow({
          columns: {
            sm: CommonConstants.GRID_ROW_SM,
            md: CommonConstants.GRID_ROW_MD,
            lg: CommonConstants.GRID_ROW_LG
          },
          gutter: { x: CommonConstants.GUTTER_X },
          breakpoints: { value: CommonConstants.BREAK_POINT }
        }) {
          GridCol({
            span: {
              sm: CommonConstants.MINE_SPAN_SM,
              md: CommonConstants.MINE_SPAN_MD,
              lg: CommonConstants.MINE_SPAN_LG
            },
            offset: {
              lg: CommonConstants.OFFSET_LG
            }
          }) {
            Column() {
              PushPageItemComponent()
            }
            .width(CommonConstants.MINE_PAGE_WIDTH_PERCENT)
            .height(CommonConstants.MINE_PAGE_HEIGHT_PERCENT)
          }
        }
        .margin({
          left: $r('app.float.user_grid_row_margin'),
          right: $r('app.float.user_grid_row_margin')
        })
      }
      .margin({ top: $r('app.float.profile_image_margin_top') })
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.login_page_background'))
  }
}


@Component
struct PushPageItemComponent {
  private userModel: UserModel | undefined;
  @State loggerText: string = 'Push logger:';

  getUserModel(): UserModel {
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }

  build() {
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