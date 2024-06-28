// 对焦区域
import CameraService from '../model/CameraService';
const TAG: string = 'FocusAreaComponent';

@Component
export struct FocusAreaComponent {
  @Link focusPointBol: boolean;
  @Link focusPointVal: Array<number>;
  @Prop xComponentWidth: number;
  @Prop xComponentHeight: number;
  // 对焦区域显示框定时器
  private areaTimer: number = -1;
  private focusFrameDisplayDuration: number = 3500;

  build() {
    Row() {
    }
    .width(this.xComponentWidth)
    .height(this.xComponentHeight)
    .opacity(1)
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.focusPointBol = true;
        this.focusPointVal[0] = e.touches[0].windowX;
        this.focusPointVal[1] = e.touches[0].windowY;
        // 归一化焦点。 设置的焦点与相机sensor角度和窗口方向有关（相机sensor角度可通过CameraDevice的cameraOrientation属性获取），下面焦点是以竖屏窗口，相机sensor角度为90度场景下的焦点设置
        CameraService.setFocusPoint({
          x: e.touches[0].y / this.xComponentHeight,
          y: 1 - (e.touches[0].x / this.xComponentWidth)
        });
      }
      if (e.type === TouchType.Up) {
        if (this.areaTimer) {
          clearTimeout(this.areaTimer);
        }
        this.areaTimer = setTimeout(() => {
          this.focusPointBol = false;
        }, this.focusFrameDisplayDuration);
      }
    })
    .onClick((event: ClickEvent) => {
      console.info(TAG, 'onClick is called');
    })
  }
}