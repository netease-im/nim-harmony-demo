import { Constants } from '../../../common/Constants';
import CameraService, { SliderValue } from '../model/CameraService';
const TAG: string = 'SlideComponent';

// 变焦组件
@Component
export struct SlideComponent {
  // slide滑块
  @StorageLink('zoomRatio') zoomRatio: number = 1;
  @StorageLink('sliderValue') sliderValue: SliderValue | undefined = undefined;
  private fractionDigits = 2;
  private xString = 'x';

  aboutToDisappear(): void {
  }

  slideChange(value: number): void {
    CameraService.setZoomRatioFn(value);
  }

  build() {
    if (this.sliderValue) {
      Column() {
        Row() {
          Text(this.zoomRatio + this.xString)
            .fontColor($r('app.color.slide_text_font_color'))
            .width($r('app.string.120px'))
            .height($r('app.string.50px'))
            .borderRadius(Constants.TEXT_BORDER_RADIUS)
            .backgroundColor(Color.White)
            .fontSize(Constants.FONT_SIZE_14)
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Center)
        .width(Constants.FULL_PERCENT)

        Row() {
          Text(this.sliderValue?.min + this.xString).fontColor(Color.White)
          Text(this.sliderValue?.max + this.xString).fontColor(Color.White)
        }
        .justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_PERCENT)

        Row() {
          Slider({
            value: this.zoomRatio,
            min: this.sliderValue?.min,
            max: this.sliderValue?.max,
            step: this.sliderValue?.step,
            style: SliderStyle.OutSet
          })
            .showSteps(false)
            .trackColor($r('app.color.slider_track_color'))
            .selectedColor($r('app.color.theme_color'))
            .onChange((value: number) => {
              console.info(TAG, 'onChange');
              let val = Number(value.toFixed(this.fractionDigits));
              this.slideChange(val);
              this.zoomRatio = val;
            })
        }
        .width(Constants.FULL_PERCENT)
      }
      .height($r('app.string.60px'))
      .width(Constants.FORTY_PERCENT)
      .position({
        x: Constants.THIRTY_PERCENT,
        y: Constants.SEVENTY_FIVE_PERCENT
      })
    }
  }
}