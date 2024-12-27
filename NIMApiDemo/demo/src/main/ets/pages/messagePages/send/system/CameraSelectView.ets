/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 *
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';


@CustomDialog
export struct CameraSelectView {
  controller?: CustomDialogController
  // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  onImageChosen?: (url: string) => void
  /// 从相册选择视频
  onTakePhotoFromCamera?: () => void;
  /// 通过相机拍摄视频
  onTakeVideoFromCamera?: () => void;

  aboutToAppear(): void {
    // console.log("net ease start request permissions");
    //this.requestPermissions(["ohos.permission.CAMERA", "ohos.permission.MICROPHONE", "ohos.permission.MEDIA_LOCATION",
    //  "ohos.permission.WRITE_MEDIA", "ohos.permission.READ_MEDIA"], this.context!);
  }

  // 显示相机选择器
  async showCameraPicker() {
    try {
      // 相机选择器的配置信息
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 相机选择器的媒体类型
      let mediaTypes: cameraPicker.PickerMediaType[] = [
        cameraPicker.PickerMediaType.PHOTO, // 拍照模式
        cameraPicker.PickerMediaType.VIDEO,// 录制模式
      ]

      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(this.context, mediaTypes, pickerProfile);
      if (this.onImageChosen && pickerResult.resultCode == 0 && pickerResult.resultUri.length > 0) {
        this.onImageChosen(pickerResult.resultUri)
      }
      console.log("the pick pickerResult is:" + JSON.stringify(pickerResult));
    } catch (error) {
      let err = error as BusinessError;
      console.error(`the pick call failed. error code: ${err.code}`);
    }
  }

  // 显示相册选择器
  async showPhotoPicker() {
    console.log("net ease show photo picker");
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 过滤选择媒体文件类型为IMAGE
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    // 选择媒体文件的最大数目
    photoSelectOptions.maxSelectNumber = 1;

    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions)
      .then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (this.onImageChosen && photoSelectResult.photoUris.length > 0) {
          this.onImageChosen(photoSelectResult.photoUris[0])
        }
        console.info('net ease photoViewPicker.select to file succeed and uris are:' + photoSelectResult.photoUris);
      }).catch((err: BusinessError) => {
      console.error(`net ease Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  takePicture = () => {
    if (this.onTakePhotoFromCamera) {
      this.onTakePhotoFromCamera()
    }
    this.cancel()
  }
  takeVideo = () => {
    if (this.onTakeVideoFromCamera) {
      this.onTakeVideoFromCamera()
    }
    this.cancel()
  }
  cancel = () => {
    this.controller?.close()
  }

  build() {
    Column() {
      Column() {
        Text('拍照')
          .fontSize(14)
          .fontColor("#333333")
          .textAlign(TextAlign.Center)
          .height(42)
          .width('100%')
          .onClick(this.takePicture)

        Row()
          .height(1)
          .width('100%')
          .backgroundColor("#EFF1F4")

        Text('摄像')
          .fontSize(14)
          .fontColor("#333333")
          .textAlign(TextAlign.Center)
          .height(42)
          .width('100%')
          .onClick(this.takeVideo)
      }
      .height(85)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 12, right: 12 })

      Column() {
        Text('取消')
          .fontSize(14)
          .fontColor("#333333")
          .textAlign(TextAlign.Center)
          .height(42)
          .width('100%')
          .onClick(this.cancel)
      }
      .height(42)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 10, left: 12, right: 12 })

    }
    .backgroundColor(Color.Transparent)
  }
}