import {CommonConstants} from '../common/CommonConstants'
@Component
export default struct ClassifyItem {
  classifyName?: string;
  @Prop isSelected: boolean = false;
  onClickAction = () => {}

  build() {
    Text(this.classifyName)
      .fontSize($r('app.float.app_info_sub_title_size'))
      .fontColor(this.isSelected ? $r('app.color.title') : $r('app.color.text_opacity'))
      .fontFamily(this.isSelected ? $r('app.string.hei_ti_medium') : $r('app.string.hei_ti'))
      .fontWeight(this.isSelected ? CommonConstants.TITLE_FONT_WEIGHT : CommonConstants.LABEL_FONT_WEIGHT)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.isSelected ? $r('app.color.background') : '')
      .width(CommonConstants.FULL_WIDTH_PERCENT)
      .height($r('app.float.classity_title_height'))
      .onClick(this.onClickAction)
  }
}