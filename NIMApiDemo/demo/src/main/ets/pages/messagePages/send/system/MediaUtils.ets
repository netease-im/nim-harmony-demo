/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 *
 */

import picker from '@ohos.file.picker';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { dataSharePredicates } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';

export class SelectResult {
  public uri?: string;
  public name?: string;
  public errorMsg?: string;
  // 视频宽度(只支持视频)
  public width?: number;
  // 视频高度(只支持视频)
  public height?: number;
  // 视频时长(只支持视频)
  public duration?: number;
  // 视频首帧(只支持视频)
  public thumbnail?: PixelMap;
  // 文件类型
  public type: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
}


export class MediaUtils {
  // 显示相册选择器(包含视频照片)
  static async showMediaPicker(mimeType: photoAccessHelper.PhotoViewMIMETypes): Promise<SelectResult> {
    console.log("net ease show photo picker");
    const result: SelectResult = await new Promise((resolve: Function) => {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 过滤选择媒体文件类型为IMAGE
      photoSelectOptions.MIMEType = mimeType;
      // 选择媒体文件的最大数目
      photoSelectOptions.maxSelectNumber = 1;
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoViewPicker.select(photoSelectOptions)
        .then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          const context = getContext(photoSelectOptions)
          const uri = photoSelectResult.photoUris[0];
          const selectResult = MediaUtils.getMediaInfo(context, uri)
          resolve(selectResult);
        })
        .catch((err: BusinessError) => {
          console.error(`net ease Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
          const selectResult = new SelectResult();
          selectResult.errorMsg =
            `net ease Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`;
          resolve(selectResult);
        })
    });
    return result;
  }

  // 显示相册（图片）选择器
  static async showImagePicker(): Promise<SelectResult> {
    console.log("net ease show photo picker");
    const result: SelectResult = await MediaUtils.showMediaPicker(photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE)
    return result;
  }

  // 显示相册（视频）选择器
  static async showVideoPicker(): Promise<SelectResult> {
    console.log("net ease show photo picker");
    const result: SelectResult = await MediaUtils.showMediaPicker(photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE)
    return result;
  }

  // 显示相册（图片+视频）选择器
  static async showImageVideoPicker(): Promise<SelectResult> {
    console.log("net ease show photo picker");
    const result: SelectResult = await MediaUtils.showMediaPicker(photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE)
    return result;
  }

  // 文件选择器
  static async showFilePicker(): Promise<SelectResult> {
    console.log("net ease show file picker");
    const result: SelectResult = await new Promise((resolve: Function) => {
      let uris: Array<string> = [];
      let documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;

      const documentViewPicker = new picker.DocumentViewPicker(); // 创建文件选择器实例
      documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
        uris = documentSelectResult;
        console.info('net ease documentViewPicker.select to file succeed and uris are:' + uris);
        const selectResult = new SelectResult();
        if (uris.length > 0) {
          console.log("net ease first uri is:" + uris[0]);
          selectResult.uri = uris[0];
        }
        resolve(selectResult);
      }).catch((err: BusinessError) => {
        console.error(`net ease Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
        const selectResult = new SelectResult();
        selectResult.errorMsg =
          `net ease Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`;
        resolve(selectResult);
      })
    });
    return result;
  }

  // 显示相机选择器
  static async showCameraPicker(context: common.UIAbilityContext,
    mediaType: cameraPicker.PickerMediaType): Promise<SelectResult> {

    const result: SelectResult = await new Promise((resolve: Function) => {
      try {
        // 相机选择器的配置信息
        let pickerProfile: cameraPicker.PickerProfile = {
          cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
        };

        // 相机选择器的媒体类型
        let mediaTypes: cameraPicker.PickerMediaType[] = [
          mediaType
        ]

        let context1 = getContext(pickerProfile) as common.UIAbilityContext;

        cameraPicker.pick(context1, mediaTypes, pickerProfile).then((result) => {
          let uri = result.resultUri
          let selectResult = MediaUtils.getMediaInfo(context1, uri);
          console.log("net ease the pick pickerResult is:" + JSON.stringify(result));
          resolve(selectResult);
        });

      } catch (error) {
        let err = error as BusinessError;
        let selectResult = new SelectResult();
        selectResult.errorMsg = err.code + ":" + err.message;
        selectResult.errorMsg =
          `net ease Invoke camera  failed, code is ${err.code}, message is ${err.message}`;
        resolve(selectResult);
      }
    });
    return result;

  }

  // 获取 photoAsset
  // 得到uri对应的PhotoAsset对象，读取文件的部分信息
  static async getPhotoAsset(context: Context, uri?: string): Promise<photoAccessHelper.PhotoAsset> {
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 配置查询条件，使用PhotoViewPicker选择图片返回的uri进行查询
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [photoAccessHelper.PhotoKeys.WIDTH,
        photoAccessHelper.PhotoKeys.HEIGHT,
        photoAccessHelper.PhotoKeys.TITLE,
        photoAccessHelper.PhotoKeys.ORIENTATION,
        photoAccessHelper.PhotoKeys.DURATION],
      predicates: predicates
    };
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
      await phAccessHelper.getAssets(fetchOption);
    // 得到uri对应的PhotoAsset对象，读取文件的部分信息
    return await fetchResult.getFirstObject();
  }

  // 获取媒体信息
  static async getMediaInfo(context: Context, uri?: string): Promise<SelectResult> {
    // 得到uri对应的PhotoAsset对象，读取文件的部分信息
    const photoAsset: photoAccessHelper.PhotoAsset = await MediaUtils.getPhotoAsset(context, uri);
    const selectResult = new SelectResult();
    // let srcName = photoAsset.get(photoAccessHelper.PhotoKeys.TITLE) as string;  // 不带后缀
    let srcName = photoAsset.displayName; // 带后缀
    let srcType = photoAsset.photoType
    let srcWidth = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
    let srcHeight = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
    let srcDuration = photoAsset.get(photoAccessHelper.PhotoKeys.DURATION) as number;
    let srcOrientation = photoAsset.get(photoAccessHelper.PhotoKeys.ORIENTATION) as number;
    if (srcOrientation === 90 || srcOrientation === 270) {
      const width = srcWidth
      srcWidth = srcHeight
      srcHeight = width
    }
    selectResult.uri = uri;
    selectResult.name = srcName;
    selectResult.type = srcType;
    selectResult.width = srcWidth;
    selectResult.height = srcHeight;
    selectResult.duration = srcDuration;

    selectResult.thumbnail = await photoAsset.getThumbnail({
      height: srcHeight,
      width: srcWidth
    })
    return selectResult;
  }
}