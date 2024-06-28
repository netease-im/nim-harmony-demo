

import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { display, router } from '@kit.ArkUI';

import { image } from '@kit.ImageKit';
import { CommonConstants } from '../../../../common/CommonConstants';
import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BreakpointType } from '../../../../utils/BreakpointSystem';
import CameraManager from './CameraManager';
import { DataUtils } from '../../../../utils/DataUtils';
import  Logger from '../../../../utils/Logger';


@Component
export struct CameraView {
  @Link isMovingPhoto: boolean;
  @Link isTakeMovingPhoto: boolean;
  @State currentImg: image.PixelMap | Resource = $r('app.media.preview_background');
  @Link currentBreakpoint: string;
  @Link photoUriArr: string[];
  @Link cameraIndex: number;
  private readonly tag:string = 'CameraView';
  private isLocalCamera: boolean = true;
  private currentUri: string = '';
  private mXComponentController: XComponentController = new XComponentController();
  private permissions: Array<Permissions> = [
    'ohos.permission.CAMERA',
    'ohos.permission.MICROPHONE',
    'ohos.permission.MEDIA_LOCATION',
    'ohos.permission.READ_IMAGEVIDEO',
    'ohos.permission.WRITE_IMAGEVIDEO',
  ];
  private surfaceId: string = '';
  private supperCameraArr: Array<camera.CameraDevice> | undefined = undefined;
  private distributedCameraArr: Array<camera.CameraDevice> | undefined = undefined;

  aboutToAppear(): void {
    this.getThumbnail();
  }

  aboutToDisappear(): void {
    CameraManager.releaseCamera();
  }

  build() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Column,
          md: FlexDirection.Row,
          lg: FlexDirection.Row,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setCameraToolView();
      this.setXComponentView();
      this.setCameraActionsBtn();
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .backgroundColor(Color.Black)
  }

  @Builder
  setCameraToolView() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Row,
          md: FlexDirection.Column,
          lg: FlexDirection.Column,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setMovingPhotoBtn();
      this.setOtherBtn();
    }.padding({
      left: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      right: $r('sys.float.ohos_id_default_padding_bottom_fixed')
    })
    .width(new BreakpointType({
      sm: $r('app.string.full_screen'),
      md: $r('app.float.navigation_height_lg'),
      lg: $r('app.float.navigation_height_lg')
    }).getValue(this.currentBreakpoint))
    .height(new BreakpointType({
      sm: $r('app.float.navigation_height_sm'),
      md: $r('app.float.camera_tools_height_lg'),
      lg: $r('app.float.camera_tools_height_lg'),
    }).getValue(this.currentBreakpoint))
  }

  @Builder
  setMovingPhotoBtn() {
    Image(this.isMovingPhoto ? $r("app.media.ic_moving_photo_on") : $r("app.media.ic_moving_photo_off"))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
        this.isMovingPhoto = !this.isMovingPhoto;
        CameraManager.setEnableLivePhoto(this.isMovingPhoto);
      })
  }

  @Builder
  setOtherBtn() {
    Image($r("app.media.ic_camera_public_flash_on"))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r("app.media.ic_camera_public_flash_always_on"))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r("app.media.ic_camera_filters"))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r("app.media.stabilization_on"))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
  }

  @Builder
  setXComponentView() {
    XComponent({
      id: 'componentId',
      type: XComponentType.SURFACE,
      controller: this.mXComponentController
    })
      .onLoad(() => {
        this.mXComponentController.setXComponentSurfaceRect(
          {
            surfaceWidth: new BreakpointType({
              sm: CommonConstants.PREVIEW_HEIGHT,
              md: CommonConstants.PREVIEW_HEIGHT,
              lg: display.getDefaultDisplaySync().width,
            }).getValue(this.currentBreakpoint),
            surfaceHeight: new BreakpointType({
              sm: CommonConstants.PREVIEW_WIDTH,
              md: CommonConstants.PREVIEW_WIDTH,
              lg: display.getDefaultDisplaySync().height,
            }).getValue(this.currentBreakpoint)
          }
        );
        abilityAccessCtrl.createAtManager().requestPermissionsFromUser(getContext(this), this.permissions).then(() => {
          this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
          this.initCamara();
          this.getThumbnail();
        })
      })
      .width($r('app.string.full_screen'))
  }

  @Builder
  setCameraActionsBtn() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Row,
          md: FlexDirection.Column,
          lg: FlexDirection.Column,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setActionsBtn();
    }
    .width(new BreakpointType({
      sm: $r('app.float.camera_actions_height_lg'),
      md: $r('app.float.navigation_height_lg'),
      lg: $r('app.float.navigation_height_lg'),
    }).getValue(this.currentBreakpoint))
    .height(new BreakpointType({
      sm: $r('app.float.size_74'),
      md: $r('app.float.camera_actions_height_lg'),
      lg: $r('app.float.camera_actions_height_lg')
    }).getValue(this.currentBreakpoint))
    .padding({
      left: new BreakpointType({
        sm: $r('app.float.margin_24'),
        md: $r('app.float.zero'),
        lg: $r('app.float.zero')
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('app.float.margin_24'),
        md: $r('app.float.zero'),
        lg: $r('app.float.zero')
      }).getValue(this.currentBreakpoint),
    })
    .margin({
      top: $r('app.float.margin_36'),
      bottom: $r('app.float.margin_36'),
      left: new BreakpointType({
        sm: $r('app.float.zero'),
        md: $r('app.float.margin_18'),
        lg: $r('app.float.margin_18')
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('app.float.zero'),
        md: $r('app.float.margin_18'),
        lg: $r('app.float.margin_18')
      }).getValue(this.currentBreakpoint),
    })
  }

  @Builder
  setActionsBtn() {
    Image(this.currentImg)
      .height($r('app.float.size_44'))
      .width($r('app.float.size_44'))
      .objectFit(ImageFit.Cover)
      .clipShape(new Circle({
        width: DataUtils.fromResToNumber($r('app.float.size_44')),
        height: DataUtils.fromResToNumber($r('app.float.size_44'))
      }))
      .onClick(() => {
        if (this.currentUri !== '') {
          this.pushPreviewPage(this.currentUri);
        }
      });

    //take photo
    Image($r('app.media.capture'))
      .objectFit(ImageFit.Contain)
      .width($r('app.float.size_74'))
      .height($r('app.float.size_74'))
      .onClick(async () => {
        CameraManager.takePhoto();
        this.isTakeMovingPhoto = this.isMovingPhoto;
        setTimeout(() => {
          this.getThumbnail(true);
        }, DataUtils.fromResToNumber($r('app.float.DELAY_TIME')));
      });

    //camera selected
    Image($r('app.media.switch_camera'))
      .objectFit(ImageFit.Contain)
      .width($r('app.float.size_44'))
      .height($r('app.float.size_44'))
      .bindMenu(this.setLocalCameraMenu);

  }

  /**
   * get take photo to show
   * @returns
   */
  async getThumbnail(isRedirect?: boolean): Promise<void> {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    let photoHelper = photoAccessHelper.getPhotoAccessHelper(getContext(this));
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
      await photoHelper.getAssets(fetchOptions);
    if (fetchResult !== undefined) {
      let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getLastObject();
      this.currentImg = await photoAsset.getThumbnail();
      this.currentUri = photoAsset.uri;
      if (isRedirect && this.currentUri !== '') {
        this.pushPreviewPage(this.currentUri);
      }
    } else {
      Logger.error(this.tag, 'getThumbnail is failed');
    }
  }

  @Builder
  setLocalCameraMenu() {
    Menu() {
      ForEach(this.supperCameraArr, (item: camera.CameraDevice, index: number) => {
        MenuItem({ content: this.getMenuText(item) }).onChange((selected: boolean) => {
          if (selected) {
            this.cameraIndex = index;
            this.isLocalCamera = true;
            this.initCamara();
          }
        }).contentFontColor(Color.White)
      })
    }.backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color_dark'))
  }

  @Builder
  setDistributedCameraMenu() {
    Menu() {
      ForEach(this.distributedCameraArr, (item: camera.CameraDevice, index: number) => {
        MenuItem({ content: this.getMenuText(item) }).onChange((selected: boolean) => {
          if (selected) {
            this.cameraIndex = index;
            this.isLocalCamera = false;
            this.initCamara();
          }
        }).contentFontColor(Color.White)
      })
    }.backgroundColor($r('sys.color.ohos_id_blur_style_component_thick_color_dark'))
  }

  private getMenuText(item: camera.CameraDevice) {
    let res = $r("app.string.local_back")
    if (item.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
      res = item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_REMOTE ? $r("app.string.remote_front") :
      $r("app.string.local_front")
    } else if (item.cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
      res = item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_REMOTE ? $r("app.string.remote_back") :
      $r("app.string.local_back")
    }
    return res;
  }

  private initCamara() {
    CameraManager.initCamera(getContext(this), this.cameraIndex, this.surfaceId, this.isLocalCamera);
    this.supperCameraArr = CameraManager.supperCameraArr;
    this.distributedCameraArr = CameraManager.distributedCameraArr;
    CameraManager.setEnableLivePhoto(this.isMovingPhoto);
  }

  // Push photo preview
  private pushPreviewPage(uri: string) {
    let pageName = this.isTakeMovingPhoto ? 'pages/PreviewMovingPhotoPage' : 'pages/PreviewPhotoPage';
    router.pushUrl({
      url: pageName,
      params: {
        uri: uri,
        data: this.photoUriArr
      }
    });
  }
}