import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import MinePageContentComponent from '../view/MinePageContentComponent';
import { TitleWithBack } from '../view/TitleWithBack';

/**
 * Personal Center page, displaying personal information and app-related settings.
 */
@Entry
@Component
export default struct ServiceListPage {
  build() {
    Column() {
      TitleWithBack({ title: "ServiceList" })
      Scroll(){
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
            Column(){

              Button('CustomNotificationService')
                .width('100%')
                .margin(5)
                .onClick(event => {
                  router.pushUrl({
                    url: CommonConstants.CUSTOM_NOTIFICATION_SERVICE_URL
                  });
                })

              Button('PushService')
                .width('100%')
                .margin(5)
                .onClick(event => {
                  router.pushUrl({
                    url: CommonConstants.PUSH_SERVICE_URL
                  });
                })

              Button('NosService')
                .width('100%')
                .margin(5)
                .onClick(event => {
                  router.pushUrl({
                    url: CommonConstants.NOS_SERVICE_URL
                  });
                })

              Button('ConversationService')
                .width('100%')
                .margin(5)
                .onClick(event => {
                  router.pushUrl({
                    url: CommonConstants.CONVERSATION_SERVICE_URL
                  });
                })
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