// 闪关灯页面
import { camera } from '@kit.CameraKit';
import CameraService from '../model/CameraService';

@Component
export struct FlashingLightComponent {
  // 闪光灯模式
  @Link @Watch('flashModeChange') flashMode: camera.FlashMode;

  @State flashIconResource: Resource = $r('app.media.ic_camera_public_flash_off');
  flashModeChange(): void {
    switch (this.flashMode) {
      case camera.FlashMode.FLASH_MODE_OPEN:
        this.flashIconResource = $r('app.media.ic_camera_public_flash_on');
        break;
      case camera.FlashMode.FLASH_MODE_AUTO:
        this.flashIconResource = $r('app.media.ic_camera_public_flash_auto');
        break;
      case camera.FlashMode.FLASH_MODE_ALWAYS_OPEN:
        this.flashIconResource = $r('app.media.flash_always_on');
        break;
      case camera.FlashMode.FLASH_MODE_CLOSE:
      default:
        this.flashIconResource = $r('app.media.ic_camera_public_flash_off');
    }
  }
  build() {
    Row() {
      Row() {
        Button() {
          Image(this.flashIconResource)
            .width($r('app.string.200px'))
            .height($r('app.string.200px'))
            .fillColor($r('app.color.white'))
        }
        .width($r('app.string.200px'))
        .height($r('app.string.200px'))
        .backgroundColor($r('app.color.mainPage_backgroundColor'))
        .borderRadius(50)
        .onClick(() => {
          this.flashMode = (this.flashMode + 1) % 4;
          console.info(`flashMode: ${this.flashMode}`);
          CameraService.hasFlashFn(this.flashMode);
        })
      }
    }
  }
}