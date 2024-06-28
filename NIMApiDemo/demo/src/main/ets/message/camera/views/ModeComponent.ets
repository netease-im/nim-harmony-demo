import { camera } from '@kit.CameraKit';
import CameraService from '../model/CameraService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { GlobalContext } from '../../../common/GlobalContext';
import { router } from '@kit.ArkUI';
import { Constants } from '../../../common/Constants';

const TAG: string = 'ModeComponent';

@Component
export struct ModeComponent {
  @StorageLink('isOpenEditPage') @Watch('changePageState') isOpenEditPage: boolean = false;
  @State sceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO;
  @State isRecording: boolean = false;

  changePageState(): void {
    if (this.isOpenEditPage) {
      this.onJumpClick();
    }
  }

  aboutToAppear(): void {
    console.info(TAG, 'aboutToAppear');
    CameraService.setSavePictureCallback(this.handleSavePicture);
  }

  handleSavePicture = (photoAsset: photoAccessHelper.PhotoAsset): void => {
    console.info(TAG, 'handleSavePicture');
    this.setImageInfo(photoAsset);
    AppStorage.set<boolean>('isOpenEditPage', true);
    console.info(TAG, 'setImageInfo end');
  }

  setImageInfo(photoAsset: photoAccessHelper.PhotoAsset): void {
    console.info(TAG, 'setImageInfo');
    GlobalContext.get().setObject('photoAsset', photoAsset);
  }

  onJumpClick(): void {
    GlobalContext.get().setObject('sceneMode', this.sceneMode);
    // 目标url
    router.pushUrl({ url: 'pages/EditPage' }, router.RouterMode.Single, (err) => {
      if (err) {
        console.error(TAG, `Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info(TAG, 'Invoke pushUrl succeeded.');
    });
  }

  build() {
    Column() {
      Row({ space: Constants.COLUMN_SPACE_24 }) {
        Column() {
          Text('拍照')
            .fontSize(Constants.FONT_SIZE_14)
            .fontColor(Color.White)
        }
        .width(Constants.CAPTURE_COLUMN_WIDTH)
        .backgroundColor(this.sceneMode === camera.SceneMode.NORMAL_PHOTO ? $r('app.color.theme_color') : '')
        .borderRadius(Constants.BORDER_RADIUS_14)
        .onClick(async () => {
          if (this.sceneMode === camera.SceneMode.NORMAL_PHOTO) {
            return;
          }
          this.sceneMode = camera.SceneMode.NORMAL_PHOTO;
          CameraService.setSceneMode(this.sceneMode);
          let cameraDeviceIndex = GlobalContext.get().getT<number>('cameraDeviceIndex');
          let surfaceId = GlobalContext.get().getT<string>('xComponentSurfaceId');
          await CameraService.initCamera(surfaceId, cameraDeviceIndex);
        })

        // 录像
        Column() {
          Text('录像')
            .fontSize(Constants.FONT_SIZE_14)
            .fontColor(Color.White)
        }
        .width(Constants.CAPTURE_COLUMN_WIDTH)
        .backgroundColor(this.sceneMode === camera.SceneMode.NORMAL_VIDEO ? $r('app.color.theme_color') : '')
        .borderRadius(Constants.BORDER_RADIUS_14)
        .onClick(async () => {
          if (this.sceneMode === camera.SceneMode.NORMAL_VIDEO) {
            return;
          }
          this.sceneMode = camera.SceneMode.NORMAL_VIDEO;
          CameraService.setSceneMode(this.sceneMode);
          let cameraDeviceIndex = GlobalContext.get().getT<number>('cameraDeviceIndex');
          let surfaceId = GlobalContext.get().getT<string>('xComponentSurfaceId');
          await CameraService.initCamera(surfaceId, cameraDeviceIndex);
        })
      }
      .height(Constants.CAPTURE_ROW_HEIGHT)
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
        }
        .width($r('app.string.200px'))

        // 拍照-录像 按键
        Column() {
          if (!this.isRecording) {
            Row() {
              Button() {
                Text()
                  .width($r('app.string.120px'))
                  .height($r('app.string.120px'))
                  .borderRadius($r('app.string.40px'))
                  .backgroundColor(this.sceneMode === camera.SceneMode.NORMAL_VIDEO ?
                  $r('app.color.theme_color') : Color.White)
              }
              .border({
                width: Constants.CAPTURE_BUTTON_BORDER_WIDTH,
                color: $r('app.color.border_color'),
                radius: Constants.CAPTURE_BUTTON_BORDER_RADIUS
              })
              .width($r('app.string.200px'))
              .height($r('app.string.200px'))
              .backgroundColor(Color.Black)
              .onClick(async () => {
                if (this.sceneMode === camera.SceneMode.NORMAL_PHOTO) {
                  await CameraService.takePicture();
                } else {
                  await CameraService.startVideo();
                  this.isRecording = true;
                }
              })
            }
          } else {
            Row() {
              // 录像停止键
              Button() {
                Image($r('app.media.ic_camera_video_close'))
                  .size({ width: Constants.IMAGE_SIZE, height: Constants.IMAGE_SIZE })
              }
              .width($r('app.string.120px'))
              .height($r('app.string.120px'))
              .backgroundColor($r('app.color.theme_color'))
              .onClick(() => {
                this.isRecording = !this.isRecording;
                CameraService.stopVideo().then(() => {
                  this.isOpenEditPage = true;
                  console.info(TAG, 'stopVideo success');
                })
              })
            }
            .width($r('app.string.200px'))
            .height($r('app.string.200px'))
            .borderRadius($r('app.string.60px'))
            .backgroundColor($r('app.color.theme_color'))
            .justifyContent(FlexAlign.SpaceAround)
          }
        }

        // 前后置摄像头切换
        Column() {
          Row() {
            Button() {
              Image($r('app.media.switch_camera'))
                .width($r('app.string.120px'))
                .height($r('app.string.120px'))
            }
            .width($r('app.string.200px'))
            .height($r('app.string.200px'))
            .backgroundColor($r('app.color.flash_background_color'))
            .borderRadius($r('app.string.40px'))
            .onClick(async () => {
              let cameraDeviceIndex = GlobalContext.get().getT<number>('cameraDeviceIndex');
              let surfaceId = GlobalContext.get().getT<string>('xComponentSurfaceId');
              cameraDeviceIndex ? cameraDeviceIndex = 0 : cameraDeviceIndex = 1;
              GlobalContext.get().setObject('cameraDeviceIndex', cameraDeviceIndex);
              await CameraService.initCamera(surfaceId, cameraDeviceIndex);
            })
          }
        }
        .visibility(this.isRecording ? Visibility.Hidden : Visibility.Visible)
      }
      .padding({
        left: Constants.CAPTURE_BUTTON_COLUMN_PADDING,
        right: Constants.CAPTURE_BUTTON_COLUMN_PADDING
      })
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.End)
    .height(Constants.TEN_PERCENT)
    .padding({
      left: Constants.CAPTURE_BUTTON_COLUMN_PADDING,
      right: Constants.CAPTURE_BUTTON_COLUMN_PADDING
    })
    .margin({ bottom: Constants.CAPTURE_BUTTON_COLUMN_MARGIN })
    .position({
      x: Constants.ZERO_PERCENT,
      y: Constants.EIGHTY_FIVE_PERCENT
    })
  }
}