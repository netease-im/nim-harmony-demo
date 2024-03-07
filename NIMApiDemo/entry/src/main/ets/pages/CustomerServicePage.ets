import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { CustomerListComponent } from '../view/CustomerListComponent';

/**
 * Customer service page. Click the help button to jump to the CustomerServicePage.
 */
@Entry
@Component
struct CustomerServicePage {
  build() {
    Column() {
      this.Title()

      GridRow({
        breakpoints: {
          value: CommonConstants.BREAK_POINT,
          reference: BreakpointsReference.WindowSize
        },
        columns: {
          sm: CommonConstants.GRID_ROW_SM,
          md: CommonConstants.GRID_ROW_MD,
          lg: CommonConstants.GRID_ROW_LG
        },
        gutter: { x: CommonConstants.GUTTER_X },
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: {
            sm: CommonConstants.SPAN_SM,
            md: CommonConstants.SPAN_MD,
            lg: CommonConstants.SPAN_LG
          },
          offset: {
            md: CommonConstants.OFFSET_MD,
            lg: CommonConstants.OFFSET_LG
          }
        }) {
          CustomerListComponent()
        }
      }
      .margin({
        left: $r('app.float.customer_margin_left'),
        right: $r('app.float.customer_margin_right')
      })
    }
    .width(CommonConstants.CUSTOMER_COLUMN_WIDTH_PERCENT)
    .height(CommonConstants.CUSTOMER_COLUMN_HEIGHT_PERCENT)
    .backgroundColor($r('app.color.detail_background'))
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

      Text($r('app.string.contact_customer_service'))
        .fontSize($r('app.float.title_text_size'))
        .fontColor($r('app.color.title'))
        .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
    }
    .width(CommonConstants.FULL_WIDTH_PERCENT)
    .height($r('app.float.title_height'))
  }
}
