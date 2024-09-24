
import { image } from '@kit.ImageKit'
import { camera } from '@kit.CameraKit';
import { Context } from '@ohos.arkui.UIContext'

import { BusinessError } from '@kit.BasicServicesKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { MediaFileUtils } from '../utils/MediaFileUtils'
import { sensor } from '@kit.SensorServiceKit'



export class CameraManager {
  supperCameraArr: Array<camera.CameraDevice> = [];
  distributedCameraArr: Array<camera.CameraDevice> = [];
  private tag: string = 'CameraService';
  private cameraManager: camera.CameraManager | undefined = undefined;
  private photoSession: camera.PhotoSession | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private currentContext: Context | undefined = undefined;
  private rotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;

  CAMERA_SIZE: camera.Size[] = [{ width: 1920, height: 1080 }, {
    width: 1440,
    height: 1080
  }]

  public constructor() {
  }

  async initCamera(context: Context, cameraIndex: number, surfaceId: string, isLocal: boolean) {
    this.currentContext = context;
    this.releaseCamera()
    this.cameraManager = camera.getCameraManager(this.currentContext)
    let supperCameras = this.cameraManager.getSupportedCameras();
    this.distinguishCamera(supperCameras);
    let cameraOutputCapability =
      this.cameraManager.getSupportedOutputCapability(isLocal ? this.supperCameraArr[cameraIndex] :
      this.distributedCameraArr[cameraIndex], camera.SceneMode.NORMAL_PHOTO);
    this.createCameraInputFn(isLocal ? this.supperCameraArr[cameraIndex] : this.distributedCameraArr[cameraIndex]);

    this.cameraInput?.open()
    let photoProfileObj = cameraOutputCapability.photoProfiles[0]
    let previewProfileObj = cameraOutputCapability.previewProfiles[0]
    photoProfileObj.size.width = this.CAMERA_SIZE[0].width
    photoProfileObj.size.height = this.CAMERA_SIZE[0].height
    previewProfileObj.size.width = this.CAMERA_SIZE[0].width
    previewProfileObj.size.height = this.CAMERA_SIZE[0].height
    this.createPreviewOutputFn(previewProfileObj, surfaceId)
    this.createPhotoOutputFn(photoProfileObj)
    this.photoOutPutCallBack()
    this.sessionFlowFn()
  }

  private distinguishCamera(cameras: Array<camera.CameraDevice>) {
    this.supperCameraArr.length = 0;
    this.distributedCameraArr.length = 0;
    cameras.forEach((item: camera.CameraDevice) => {
      if (item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_REMOTE) {
        this.distributedCameraArr.push(item);
      } else {
        this.supperCameraArr.push(item);
      }
    });
    console.debug(this.tag,
      `distinguishCamera cameras: ${cameras.length}, supperCameraArr: ${this.supperCameraArr.length}, distributedCameraArr: ${this.distributedCameraArr.length}`)
  }

  async releaseCamera() {
    this.previewOutput?.release()
    this.photoOutput?.release()
    this.photoSession?.stop();
    this.photoSession?.release();
    this.cameraInput?.close()
  }

  private async createCameraInputFn(camera: camera.CameraDevice) {
    try {
      this.cameraInput = this.cameraManager?.createCameraInput(camera)
      console.info(this.tag, `createCameraInputFn success: ${this.cameraInput}`)
    } catch (err) {
      console.error(this.tag, `createCameraInputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  private async createPreviewOutputFn(previewProfile: camera.Profile, surfaceId: string) {
    try {
      console.info(this.tag, `createPreviewOutputFn previewProfilesObj success: ` + JSON.stringify(previewProfile))
      this.previewOutput = this.cameraManager?.createPreviewOutput(previewProfile, surfaceId.toString())
      console.info(this.tag, `createPreviewOutputFn success: ` + JSON.stringify(this.previewOutput))
    } catch (err) {
      console.error(this.tag, `createPreviewOutputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  private async createPhotoOutputFn(photoProfile: camera.Profile) {
    try {
      console.info(this.tag, `createPhotoOutputFn photoProfileObj success: ` + JSON.stringify(photoProfile))
      this.photoOutput = this.cameraManager?.createPhotoOutput(photoProfile)
      console.info(this.tag, `createPhotoOutputFn success: ` + JSON.stringify(this.photoOutput))
    } catch (err) {
      console.error(this.tag, `createPhotoOutputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  /**
   * Photo out put callback
   * @param photoOutput
   */
  private photoOutPutCallBack(): void {
    // Save Photo
    this.photoOutput?.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      if (errCode || photo === undefined) {
        console.error(this.tag, 'getPhoto failed');
        return;
      }
      let imageObj = photo.main;
      imageObj.getComponent(image.ComponentType.JPEG, (errCode: BusinessError, component: image.Component): void => {
        console.info(this.tag, 'getComponent start');
        if (component.byteBuffer) {
          let buffer = component.byteBuffer;
          MediaFileUtils.savePicture(buffer).then(() => {
            imageObj.release();
          });
        } else {
          console.error(this.tag, `byteBuffer is null fail err: ${JSON.stringify(errCode)}`)
        }
      });
    });
    // Saving Moving Photo
    this.photoOutput?.on('photoAssetAvailable',
      async (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset): Promise<void> => {
        if (err) {
          console.error(this.tag, `getPhoto failed err: ${err}`);
          return;
        }
        let accessHelper: photoAccessHelper.PhotoAccessHelper =
          photoAccessHelper.getPhotoAccessHelper(this.currentContext);
        let albumFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.Album> =
          await accessHelper.getAlbums(photoAccessHelper.AlbumType.USER, photoAccessHelper.AlbumSubtype.USER_GENERIC);
        let album: photoAccessHelper.Album = await albumFetchResult.getFirstObject();
        let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
          new photoAccessHelper.MediaAlbumChangeRequest(album);
        albumChangeRequest.addAssets([photoAsset]);
        await accessHelper.applyChanges(albumChangeRequest);
      });
  }

  /**
   * Session
   */
  private async sessionFlowFn() {
    try {
      // create captureSession
      console.info(this.tag, `sessionFlowFn success`)
      this.photoSession = this.cameraManager?.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      if (this.photoSession === undefined) {
        console.error(this.tag, `sessionFlowFn photoSession is failed`)
        return;
      }
      // Begin session config
      this.photoSession?.beginConfig()

      // Add cameraInput to session
      console.info(this.tag, `cameraInput success: ` + JSON.stringify(this.cameraInput))
      if (this.cameraInput) {
        this.photoSession?.addInput(this.cameraInput)
        console.info(this.tag, `cameraInput failed:` + JSON.stringify(this.cameraInput))
      }
      // Add preview output to session
      this.photoSession?.addOutput(this.previewOutput)
      // Add photo output to session
      this.photoSession?.addOutput(this.photoOutput)
      // Commit session config
      await this.photoSession?.commitConfig()
      // Start session
      await this.photoSession?.start()
    } catch (err) {
      console.info(this.tag, `sessionFlowFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  takePhoto() {
    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      rotation: this.rotation
    };
    this.photoOutput?.capture(settings);
  }

  setEnableLivePhoto(isMovingPhoto: boolean) {
    if (this.photoOutput?.isMovingPhotoSupported()) {
      this.photoOutput?.enableMovingPhoto(isMovingPhoto);
    }
  }

  register() {
    sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
      let degree: number = -1;
      degree = this.getCalDegree(data.x, data.y, data.z);
      if (degree >= 0 && (degree <= 30 || degree >= 330)) {
        this.rotation = camera.ImageRotation.ROTATION_0;
      } else if (degree >= 60 && degree <= 120) {
        // Use ROTATION_90 when degree range is [60, 120]
        this.rotation = camera.ImageRotation.ROTATION_90;
      } else if (degree >= 150 && degree <= 210) {
        // Use ROTATION_180 when degree range is [150, 210]
        this.rotation = camera.ImageRotation.ROTATION_180;
      } else if (degree >= 240 && degree <= 300) {
        // Use ROTATION_270 when degree range is [240, 300]
        this.rotation = camera.ImageRotation.ROTATION_270;
      }
    });
  }

  unRegister() {
    sensor.off(sensor.SensorId.GRAVITY);
  }

  private getCalDegree(x: number, y: number, z: number): number {
    let degree: number = -1;
    // three is Effective Delta Angle Threshold Coefficient
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }
}

export default new CameraManager()