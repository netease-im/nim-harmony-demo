import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { UserModel, USER_MODEL_LIST } from '../viewmodel/UserModel';

/**
 * Component of privacy statement and help.
 */
@Component
export struct InitializeComponent {
  build() {
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
          sm: CommonConstants.PRIVACY_SPAN_SM,
          md: CommonConstants.PRIVACY_SPAN_MD,
          lg: CommonConstants.PRIVACY_SPAN_LG
        },
        offset: {
          sm: CommonConstants.PRIVACY_OFFSET_SM,
          md: CommonConstants.PRIVACY_OFFSET_MD,
          lg: CommonConstants.PRIVACY_OFFSET_LG
        }
      }) {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('自定义初始化')
            .fontSize($r('app.float.statement_text_size'))
            .fontColor($r('app.color.problem_encountered_font'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: CommonConstants.INITIALIZE_PAGE_URL
              });
            })
        }
        .width(CommonConstants.FLEX_WIDTH_PERCENT)
        .margin({
          bottom: $r('app.float.statement_area_margin_bottom')
        })
      }

      GridCol({
        span: {
          sm: CommonConstants.PRIVACY_SPAN_SM,
          md: CommonConstants.PRIVACY_SPAN_MD,
          lg: CommonConstants.PRIVACY_SPAN_LG
        },
        offset: {
          sm: CommonConstants.PRIVACY_OFFSET_SM,
          md: CommonConstants.PRIVACY_OFFSET_MD,
          lg: CommonConstants.PRIVACY_OFFSET_LG
        }
      }) {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Radio({ value: 'REL', group: 'initGroup' }).checked(true)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                UserModel.USER_MODEL = USER_MODEL_LIST.REL
              }
            })
          Text('REL')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .lineHeight(20)
            .fontWeight(500)
        }
      }

      GridCol({
        span: {
          sm: CommonConstants.PRIVACY_SPAN_SM,
          md: CommonConstants.PRIVACY_SPAN_MD,
          lg: CommonConstants.PRIVACY_SPAN_LG
        },
        offset: {
          sm: CommonConstants.PRIVACY_OFFSET_SM,
          md: CommonConstants.PRIVACY_OFFSET_MD,
          lg: CommonConstants.PRIVACY_OFFSET_LG
        }
      }) {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Radio({ value: 'TEST', group: 'initGroup' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                UserModel.USER_MODEL = USER_MODEL_LIST.TEST
              }
            })
          Text('TEST')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .lineHeight(20)
            .fontWeight(500)
        }
      }
    }
    .margin({
      left: $r('app.float.gird_row_margin_left'),
      right: $r('app.float.gird_row_margin_right')
    })
    .onBreakpointChange((breakpoints) => {
      console.log(breakpoints);
    })
  }
}