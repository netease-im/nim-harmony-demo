import router from '@ohos.router';
import { CommonConstants } from '../common/CommonConstants';
import { InitializeComponent } from '../view/InitializeComponent';
import { LoginComponent } from '../view/LoginComponent';

/**
 * This template implements the Login function.
 * First register personal details. Log in after entering the username and password.
 * Click the button at the bottom to ask for help and check the privacy statement.
 * Developers can save username and password by Preference or Relational Database.
 */
@Entry
@Component
struct LoginPage {
  aboutToAppear() {
  }

  aboutToDisappear() {
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          LoginComponent()

          Blank()

          //InitializeComponent()
          Text('自定义初始化: (*默认初始化为线上环境*)')
            .fontSize($r('app.float.item_text_font_size'))
            .fontColor($r('app.color.problem_encountered_font'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: CommonConstants.INITIALIZE_PAGE_URL
              });
            })

          Blank()
          Text('云信服务探测')
            .fontSize($r('app.float.item_text_font_size'))
            .fontColor($r('app.color.problem_encountered_font'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: "pages/netPerformance/HttpPerformancePage"
              });
            })
            .margin({bottom: 24})

          Blank()
          Text('系统功能')
            .fontSize($r('app.float.item_text_font_size'))
            .fontColor($r('app.color.problem_encountered_font'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: "pages/systemFeaturePages/SystemFeaturePage"
              });
            })
            .margin({bottom: 24})
        }
        .height(CommonConstants.SCROLL_HEIGHT_PERCENT)
        .constraintSize({ minHeight: $r('app.float.scroll_min_height') })
        .alignItems(HorizontalAlign.Start)
        .padding($r('app.float.login_operation_area_padding'))
      }
      .layoutWeight(CommonConstants.LOGIN_SCROLL_LAYOUT_WEIGHT)
    }
    .width(CommonConstants.LOGIN_PAGE_WIDTH_PERCENT)
    .backgroundColor($r('app.color.login_page_background'))
  }

   @Builder Title() {
    Row() {
      Image($r('app.media.ic_back'))
        .width($r('app.float.image_size'))
        .height($r('app.float.image_size'))
        .margin({
          left: $r('app.float.image_margin_left'),
          right: $r('app.float.image_margin_right')
        })
        .onClick(() => {
          router.back();
        })

       Text($r('app.string.title'))
        .fontSize($r('app.float.title_text_size'))
        .fontColor($r('app.color.title'))
        .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height(56)
  }
}