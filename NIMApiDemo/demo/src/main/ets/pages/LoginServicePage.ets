import { CommonConstants } from '../common/CommonConstants';
import { TitleWithBack } from '../view/TitleWithBack';

/**
 * Personal Center page, displaying personal information and app-related settings.
 */
@Entry
@Component
struct LoginServicePage {
  build() {
    Column() {
      TitleWithBack({ title: "LoginService" })
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
            Column(){

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
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.login_page_background'))
  }
}