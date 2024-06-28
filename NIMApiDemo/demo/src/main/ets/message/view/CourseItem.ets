
import {CommonConstants} from '../../common/CommonConstants'
import FunctionalModel from '../viewmodel/CourseModel';

@Component
export default struct CourseItem {
  @Prop itemStr: string = '';
  item?: FunctionalModel;

  aboutToAppear() {
    this.item = JSON.parse(this.itemStr);
  }

  build() {
    Row() {
      Column() {
        Text(this.item?.methodName)
          .fontSize($r('app.float.normal_font_size'))
          .fontColor($r('app.color.base_font_color'))
          .fontFamily($r('app.string.hei_ti_medium'))
          .maxLines(CommonConstants.TITLE_LINE_NUMBER)
          .textOverflow({ overflow: TextOverflow.Clip })
          .lineHeight($r('app.float.title_line_height'))
          .width(CommonConstants.FULL_WIDTH_PERCENT)
      }
      .padding($r('app.float.course_item_padding'))
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(CommonConstants.FLEX_WIDTH_PERCENT)
    }
    .clip(true)
    .borderRadius($r('app.float.normal_border_radius'))
    .backgroundColor($r('app.color.start_window_background'))
    .width('100%')
    .height($r('app.float.course_item_height'))
  }
}