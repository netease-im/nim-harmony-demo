import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { camera } from '@kit.CameraKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { CommonConstants } from '../../../common/CommonConstants';
import { GlobalContext } from '../../../common/GlobalContext';
import { get } from '@nimsdk/vendor';

export class SliderValue {
  min: number = 1;
  max: number = 6;
  step: number = 0.1;
}

const TAG: string = 'CameraService';

class CameraService {
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private videoOutput: camera.VideoOutput | undefined = undefined;
  private avRecorder: media.AVRecorder | undefined = undefined;
  private session: camera.PhotoSession | camera.VideoSession | undefined = undefined;
  private handlePhotoAssetCb: (photoAsset: photoAccessHelper.PhotoAsset) => void = () => {
  };
  private curCameraDevice: camera.CameraDevice | undefined = undefined;
  private isRecording: boolean = false;
  // 推荐拍照分辨率之一
  private photoProfileObj: camera.Profile = {
    format: 2000,
    size: {
      width: 1920,
      height: 1080
    }
  };
  // 推荐预览分辨率之一
  private previewProfileObj: camera.Profile = {
    format: 1003,
    size: {
      width: 1920,
      height: 1080
    }
  };
  // 推荐录像分辨率之一
  private videoProfileObj: camera.VideoProfile = {
    format: 1003,
    size: {
      width: 1920,
      height: 1080
    },
    frameRateRange: {
      min: 30,
      max: 60
    }
  };
  private curSceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO;

  public constructor() {
  }

  setSavePictureCallback(callback: (photoAsset: photoAccessHelper.PhotoAsset) => void): void {
    this.handlePhotoAssetCb = callback;
  }

  setSceneMode(sceneMode: camera.SceneMode): void {
    this.curSceneMode = sceneMode;
  }

  getSceneMode(): camera.SceneMode {
    return this.curSceneMode;
  }

  getPreviewProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    let previewProfiles = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    let index = previewProfiles.findIndex((previewProfile: camera.Profile) => {
      return previewProfile.size.width === this.previewProfileObj.size.width &&
        previewProfile.size.height === this.previewProfileObj.size.height &&
        previewProfile.format === this.previewProfileObj.format;
    });
    if (index === -1) {
      return undefined;
    }
    return previewProfiles[index];
  }

  getPhotoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    let photoProfiles = cameraOutputCapability.photoProfiles;
    if (photoProfiles.length < 1) {
      return undefined;
    }
    let index = photoProfiles.findIndex((photoProfile: camera.Profile) => {
      return photoProfile.size.width === this.photoProfileObj.size.width &&
        photoProfile.size.height === this.photoProfileObj.size.height &&
        photoProfile.format === this.photoProfileObj.format;
    });
    if (index === -1) {
      return undefined;
    }
    return photoProfiles[index];
  }

  getVideoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.VideoProfile | undefined {
    let videoProfiles = cameraOutputCapability.videoProfiles;
    if (videoProfiles.length < 1) {
      return undefined;
    }
    for (let i = 0; i < videoProfiles.length; i++) {
      console.info(TAG, `getVideoProfile: ${JSON.stringify(videoProfiles[i])}`);
    }
    let index = videoProfiles.findIndex((videoProfile: camera.VideoProfile) => {
      return videoProfile.size.width === this.videoProfileObj.size.width &&
        videoProfile.size.height === this.videoProfileObj.size.height &&
        videoProfile.format === this.videoProfileObj.format &&
        videoProfile.frameRateRange.min <= CommonConstants.MAX_VIDEO_FRAME &&
        videoProfile.frameRateRange.max <= CommonConstants.MAX_VIDEO_FRAME;
    });
    if (index === -1) {
      return undefined;
    }
    return videoProfiles[index];
  }

  isSupportedSceneMode(cameraManager: camera.CameraManager, cameraDevice: camera.CameraDevice): boolean {
    let sceneModes = cameraManager.getSupportedSceneModes(cameraDevice);
    if (sceneModes === undefined) {
      return false;
    }
    let index = sceneModes.findIndex((sceneMode: camera.SceneMode) => {
      return sceneMode === this.curSceneMode;
    });
    if (index === -1) {
      return false;
    }
    return true;
  }

  /**
   * 初始化相机功能
   * @param surfaceId - Surface 的 ID
   * @param cameraDeviceIndex - 相机设备索引
   * @returns 无返回值
   */
  async initCamera(surfaceId: string, cameraDeviceIndex: number): Promise<void> {
    console.debug(TAG, `initCamera cameraDeviceIndex: ${cameraDeviceIndex}`);
    try {
      await this.releaseCamera();
      // 获取相机管理器实例
      this.cameraManager = this.getCameraManagerFn();
      if (this.cameraManager === undefined) {
        console.error(TAG, 'cameraManager is undefined');
        return;
      }
      // 获取支持指定的相机设备对象
      this.cameras = this.getSupportedCamerasFn(this.cameraManager);
      if (this.cameras.length < 1 || this.cameras.length < cameraDeviceIndex + 1) {
        return;
      }
      this.curCameraDevice = this.cameras[cameraDeviceIndex];
      let isSupported = this.isSupportedSceneMode(this.cameraManager, this.curCameraDevice);
      if (!isSupported) {
        console.error(TAG, 'The current scene mode is not supported.');
        return;
      }
      let cameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.curCameraDevice, this.curSceneMode);
      let previewProfile = this.getPreviewProfile(cameraOutputCapability);
      if (previewProfile === undefined) {
        console.error(TAG, 'The resolution of the current preview stream is not supported.');
        return;
      }
      this.previewProfileObj = previewProfile;
      // 创建previewOutput输出对象
      this.previewOutput = this.createPreviewOutputFn(this.cameraManager, this.previewProfileObj, surfaceId);
      if (this.previewOutput === undefined) {
        console.error(TAG, 'Failed to create the preview stream.');
        return;
      }
      // 监听预览事件
      this.previewOutputCallBack(this.previewOutput);
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        let photoProfile = this.getPhotoProfile(cameraOutputCapability);
        if (photoProfile === undefined) {
          console.error(TAG, 'The resolution of the current photo stream is not supported.');
          return;
        }
        this.photoProfileObj = photoProfile;
        // 创建photoOutPut输出对象
        this.photoOutput = this.createPhotoOutputFn(this.cameraManager, this.photoProfileObj);
        if (this.photoOutput === undefined) {
          console.error(TAG, 'Failed to create the photo stream.');
          return;
        }
      } else if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        let videoProfile = this.getVideoProfile(cameraOutputCapability);
        if (videoProfile === undefined) {
          console.error(TAG, 'The resolution of the current video stream is not supported.');
          return;
        }
        this.videoProfileObj = videoProfile;
        this.avRecorder = await this.createAVRecorder();
        if (this.avRecorder === undefined) {
          console.error(TAG, 'Failed to create the avRecorder.');
          return;
        }
        await this.prepareAVRecorder();
        let videoSurfaceId = await this.avRecorder.getInputSurface();
        // 创建videoOutPut输出对象
        this.videoOutput = this.createVideoOutputFn(this.cameraManager, this.videoProfileObj, videoSurfaceId);
        if (this.videoOutput === undefined) {
          console.error(TAG, 'Failed to create the video stream.');
          return;
        }
      }
      // 创建cameraInput输出对象
      this.cameraInput = this.createCameraInputFn(this.cameraManager, this.curCameraDevice);
      if (this.cameraInput === undefined) {
        console.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // 打开相机
      let isOpenSuccess = await this.cameraInputOpenFn(this.cameraInput);
      if (!isOpenSuccess) {
        console.error(TAG, 'Failed to open the camera.');
        return;
      }
      // 镜头状态回调
      this.onCameraStatusChange(this.cameraManager);
      // 监听CameraInput的错误事件
      this.onCameraInputChange(this.cameraInput, this.curCameraDevice);
      // 会话流程
      await this.sessionFlowFn(this.cameraManager, this.cameraInput, this.previewOutput, this.photoOutput,
        this.videoOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `initCamera fail: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取可变焦距范围
   */
  getZoomRatioRange(): Array<number> {
    let zoomRatioRange: Array<number> = [];
    if (this.session !== undefined) {
      zoomRatioRange = this.session.getZoomRatioRange();
    }
    return zoomRatioRange;
  }

  /**
   * 变焦
   */
  setZoomRatioFn(zoomRatio: number): void {
    console.info(TAG, `setZoomRatioFn value ${zoomRatio}`);
    // 获取支持的变焦范围
    try {
      let zoomRatioRange = this.getZoomRatioRange();
      console.info(TAG, `getZoomRatioRange success: ${JSON.stringify(zoomRatioRange)}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `getZoomRatioRange fail: ${JSON.stringify(err)}`);
    }

    try {
      this.session?.setZoomRatio(zoomRatio);
      console.info(TAG, 'setZoomRatioFn success');
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `setZoomRatioFn fail: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 以指定参数触发一次拍照
   */
  async takePicture(): Promise<void> {
    console.info(TAG, 'takePicture start');
    let cameraDeviceIndex = GlobalContext.get().getT<number>('cameraDeviceIndex');
    let photoSettings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      mirror: cameraDeviceIndex ? true : false
    };
    await this.photoOutput?.capture(photoSettings);
    console.info(TAG, 'takePicture end');
  }

  /**
   * 释放会话及其相关参数
   */
  async releaseCamera(): Promise<void> {
    console.info(TAG, 'releaseCamera is called');
    try {
      await this.previewOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `previewOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.photoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `photoOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.photoOutput = undefined;
    }
    try {
      await this.avRecorder?.release();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `avRecorder release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.avRecorder = undefined;
    }

    try {
      await this.videoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `videoOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.videoOutput = undefined;
    }
    try {
      await this.session?.release();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `captureSession release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `cameraInput close fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.cameraInput = undefined;
    }
    this.offCameraStatusChange();
    console.info(TAG, 'releaseCamera success');
  }

  /**
   * 获取相机管理器实例
   */
  getCameraManagerFn(): camera.CameraManager | undefined {
    if (this.cameraManager) {
      return this.cameraManager;
    }
    let cameraManager: camera.CameraManager | undefined = undefined;
    try {
      cameraManager = camera.getCameraManager(GlobalContext.get().getCameraSettingContext());
      console.info(TAG, `getCameraManager success: ${cameraManager}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `getCameraManager failed: ${JSON.stringify(err)}`);
    }
    return cameraManager;
  }

  /**
   * 获取支持指定的相机设备对象
   */
  getSupportedCamerasFn(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let supportedCameras: Array<camera.CameraDevice> = [];
    try {
      supportedCameras = cameraManager.getSupportedCameras();
      console.info(TAG, `getSupportedCameras success: ${this.cameras}, length: ${this.cameras?.length}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `getSupportedCameras failed: ${JSON.stringify(err)}`);
    }
    return supportedCameras;
  }

  /**
   * 创建previewOutput输出对象
   */
  createPreviewOutputFn(cameraManager: camera.CameraManager, previewProfileObj: camera.Profile,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfileObj, surfaceId);
      console.info(TAG, `createPreviewOutput success: ${previewOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `createPreviewOutput failed: ${JSON.stringify(err)}`);
    }
    return previewOutput;
  }

  /**
   * 创建photoOutPut输出对象
   */
  createPhotoOutputFn(cameraManager: camera.CameraManager,
    photoProfileObj: camera.Profile): camera.PhotoOutput | undefined {
    let photoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfileObj);
      console.info(TAG, `createPhotoOutputFn success: ${photoOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `createPhotoOutputFn failed: ${JSON.stringify(err)}`);
    }
    return photoOutput;
  }

  /**
   * 创建videoOutPut输出对象
   */
  createVideoOutputFn(cameraManager: camera.CameraManager, videoProfileObj: camera.VideoProfile,
    surfaceId: string): camera.VideoOutput | undefined {
    let videoOutput: camera.VideoOutput | undefined = undefined;
    try {
      videoOutput = cameraManager.createVideoOutput(videoProfileObj, surfaceId);
      console.info(TAG, `createVideoOutputFn success: ${videoOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `createVideoOutputFn failed: ${JSON.stringify(err)}`);
    }
    return videoOutput;
  }

  /**
   * 创建cameraInput输出对象
   */
  createCameraInputFn(cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice): camera.CameraInput | undefined {
    console.info(TAG, 'createCameraInputFn is called.');
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
      console.info(TAG, 'createCameraInputFn success');
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `createCameraInputFn failed: ${JSON.stringify(err)}`);
    }
    return cameraInput;
  }

  /**
   * 打开相机
   */
  async cameraInputOpenFn(cameraInput: camera.CameraInput): Promise<boolean> {
    let isOpenSuccess = false;
    try {
      await cameraInput.open();
      isOpenSuccess = true;
      console.info(TAG, 'cameraInput open success');
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `createCameraInput failed : ${JSON.stringify(err)}`);
    }
    return isOpenSuccess;
  }

  /**
   * 会话流程
   */
  async sessionFlowFn(cameraManager: camera.CameraManager, cameraInput: camera.CameraInput,
    previewOutput: camera.PreviewOutput, photoOutput: camera.PhotoOutput | undefined,
    videoOutput: camera.VideoOutput | undefined): Promise<void> {
    try {
      // 创建CaptureSession实例
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.PhotoSession;
      } else if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.VideoSession;
      }
      if (this.session === undefined) {
        return;
      }
      this.onSessionErrorChange(this.session);
      // 开始配置会话
      this.session.beginConfig();
      // 把CameraInput加入到会话
      this.session.addInput(cameraInput);
      // 把previewOutput加入到会话
      this.session.addOutput(previewOutput);
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        if (photoOutput === undefined) {
          return;
        }
        // 拍照监听事件
        this.photoOutputCallBack(photoOutput);
        // 把photoOutPut加入到会话
        this.session.addOutput(photoOutput);
      } else if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        if (videoOutput === undefined) {
          return;
        }
        // 把photoOutPut加入到会话
        this.session.addOutput(videoOutput);
      }
      // 提交配置信息
      await this.session.commitConfig();
      if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        this.setVideoStabilizationFn(this.session as camera.VideoSession, camera.VideoStabilizationMode.MIDDLE);
      }
      this.updateSliderValue();
      this.setFocusMode(camera.FocusMode.FOCUS_MODE_AUTO);
      // 开始会话工作
      await this.session.start();
      console.info(TAG, 'sessionFlowFn success');
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `sessionFlowFn fail : ${JSON.stringify(err)}`);
    }
  }

  setVideoStabilizationFn(session: camera.VideoSession, videoStabilizationMode: camera.VideoStabilizationMode): void {
    // 查询是否支持指定的视频防抖模式
    let isVideoStabilizationModeSupported: boolean = session.isVideoStabilizationModeSupported(videoStabilizationMode);
    if (isVideoStabilizationModeSupported) {
      session.setVideoStabilizationMode(videoStabilizationMode);
    }
    console.info(TAG, 'setVideoStabilizationFn success');
  }

  /**
   * 更新滑动条数据
   */
  updateSliderValue(): void {
    let zoomRatioRange = this.getZoomRatioRange();
    if (zoomRatioRange.length !== 0) {
      let zoomRatioMin = zoomRatioRange[0];
      let zoomRatioMax = zoomRatioRange[1] > CommonConstants.ZOOM_RADIO_MAX ? CommonConstants.ZOOM_RADIO_MAX : zoomRatioRange[1];
      let sliderStep =
        zoomRatioRange[1] > CommonConstants.ZOOM_RADIO_MAX ? CommonConstants.ZOOM_RADIO_MAX_STEP : CommonConstants.ZOOM_RADIO_MIN_STEP;
      AppStorage.set<SliderValue>('sliderValue', {
        min: zoomRatioMin,
        max: zoomRatioMax,
        step: sliderStep
      });
    }
  }

  /**
   * 监听拍照事件
   */
  photoOutputCallBack(photoOutput: camera.PhotoOutput): void {
    try {
      // 监听拍照开始
      photoOutput.on('captureStartWithInfo', (err: BusinessError, captureStartInfo: camera.CaptureStartInfo): void => {
        console.info(TAG, `photoOutputCallBack captureStartWithInfo success: ${JSON.stringify(captureStartInfo)}`);
      });
      // 监听拍照帧输出捕获
      photoOutput.on('frameShutter', (err: BusinessError, frameShutterInfo: camera.FrameShutterInfo): void => {
        console.info(TAG, `photoOutputCallBack frameShutter captureId:
          ${frameShutterInfo.captureId}, timestamp: ${frameShutterInfo.timestamp}`);
      });
      // 监听拍照结束
      photoOutput.on('captureEnd', (err: BusinessError, captureEndInfo: camera.CaptureEndInfo): void => {
        console.info(TAG, `photoOutputCallBack captureEnd captureId:
          ${captureEndInfo.captureId}, frameCount: ${captureEndInfo.frameCount}`);
      });
      // 监听拍照异常
      photoOutput.on('error', (data: BusinessError): void => {
        console.info(TAG, `photoOutPut data: ${JSON.stringify(data)}`);
      });
      // TODO 临时注释，因为 'photoAssetAvailable' 不存在
      // photoOutput.on('photoAssetAvailable', (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset) => {
      //   console.info(TAG, 'photoAssetAvailable begin');
      //   if (photoAsset === undefined) {
      //     console.error(TAG, 'photoAsset is undefined');
      //     return;
      //   }
      //   this.handlePhotoAssetCb(photoAsset);
      // });
    } catch (err) {
      console.error(TAG, 'photoOutputCallBack error');
    }
  }

  /**
   * 监听预览事件
   */
  previewOutputCallBack(previewOutput: camera.PreviewOutput): void {
    console.info(TAG, 'previewOutputCallBack is called');
    try {
      previewOutput.on('frameStart', (): void => {
        console.debug(TAG, 'Preview frame started');
      });
      previewOutput.on('frameEnd', (): void => {
        console.debug(TAG, 'Preview frame ended');
      });
      previewOutput.on('error', (previewOutputError: BusinessError): void => {
        console.info(TAG, `Preview output previewOutputError: ${JSON.stringify(previewOutputError)}`);
      });
    } catch (err) {
      console.error(TAG, 'previewOutputCallBack error');
    }
  }

  /**
   * 注册相机状态变化的回调函数
   * @param err - 错误信息（如果有）
   * @param cameraStatusInfo - 相机状态信息
   * @returns 无返回值
   */
  registerCameraStatusChange(err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo): void {
    console.info(TAG, `cameraId: ${cameraStatusInfo.camera.cameraId},status: ${cameraStatusInfo.status}`);
  }

  /**
   * 监听相机状态变化
   * @param cameraManager - 相机管理器对象
   * @returns 无返回值
   */
  onCameraStatusChange(cameraManager: camera.CameraManager): void {
    console.info(TAG, 'onCameraStatusChange is called');
    try {
      cameraManager.on('cameraStatus', this.registerCameraStatusChange);
    } catch (error) {
      console.error(TAG, 'onCameraStatusChange error');
    }
  }

  /**
   * 停止监听相机状态变化
   * @returns 无返回值
   */
  offCameraStatusChange(): void {
    console.info(TAG, 'offCameraStatusChange is called');
    this.cameraManager?.off('cameraStatus', this.registerCameraStatusChange);
  }

  /**
   * 监听相机输入变化
   * @param cameraInput - 相机输入对象
   * @param cameraDevice - 相机设备对象
   * @returns 无返回值
   */
  onCameraInputChange(cameraInput: camera.CameraInput, cameraDevice: camera.CameraDevice): void {
    console.info(TAG, `onCameraInputChange is called`);
    try {
      cameraInput.on('error', cameraDevice, (cameraInputError: BusinessError): void => {
        console.info(TAG, `onCameraInputChange cameraInput error code: ${cameraInputError.code}`);
      });
    } catch (error) {
      console.error(TAG, 'onCameraInputChange error');
    }
  }

  /**
   * 监听捕获会话错误变化
   * @param session - 相机捕获会话对象
   * @returns 无返回值
   */
  onSessionErrorChange(session: camera.PhotoSession | camera.VideoSession): void {
    try {
      session.on('error', (captureSessionError: BusinessError): void => {
        console.info(TAG,
          'onCaptureSessionErrorChange captureSession fail: ' + JSON.stringify(captureSessionError.code));
      });
    } catch (error) {
      console.error(TAG, 'onCaptureSessionErrorChange error');
    }
  }

  async createAVRecorder(): Promise<media.AVRecorder | undefined> {
    let avRecorder: media.AVRecorder | undefined = undefined;
    try {
      avRecorder = await media.createAVRecorder();
    } catch (error) {
      console.error(TAG, `createAVRecorder error: ${error}`);
    }
    return avRecorder;
  }

  initFd(): number {
    console.info(TAG, 'initFd is called');
    let filesDir = getContext().filesDir;
    let filePath = filesDir + `/${Date.now()}.mp4`;
    AppStorage.setOrCreate<string>('filePath', filePath);
    let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    return file.fd;
  }

  async prepareAVRecorder(): Promise<void> {
    console.info(TAG, 'prepareAVRecorder is called');
    let fd = this.initFd();
    let videoConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: {
        audioBitrate: CommonConstants.AUDIO_BITRATE,
        audioChannels: CommonConstants.AUDIO_CHANNELS,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: CommonConstants.AUDIO_SAMPLE_RATE,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4,
        videoBitrate: CommonConstants.VIDEO_BITRATE,
        videoCodec: media.CodecMimeType.VIDEO_AVC,
        videoFrameWidth: this.videoProfileObj.size.width,
        videoFrameHeight: this.videoProfileObj.size.height,
        videoFrameRate: this.videoProfileObj.frameRateRange.max
      },
      url: `fd://${fd.toString()}`,
      rotation: get(this.curCameraDevice, "cameraOrientation")
    };
    console.info(TAG, `prepareAVRecorder videoConfig: ${JSON.stringify(videoConfig)}`);
    await this.avRecorder?.prepare(videoConfig).catch((err: BusinessError): void => {
      console.error(TAG, `prepareAVRecorder prepare err: ${JSON.stringify(err)}`);
    });
  }

  /**
   * 启动录制
   */
  async startVideo(): Promise<void> {
    console.info(TAG, 'startVideo is called');
    try {
      await this.videoOutput?.start();
      await this.avRecorder?.start();
      this.isRecording = true;
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `startVideo err: ${JSON.stringify(err)}`);
    }
    console.info(TAG, 'startVideo End of call');
  }

  /**
   * 停止录制
   */
  async stopVideo(): Promise<void> {
    console.info(TAG, 'stopVideo is called');
    if (!this.isRecording) {
      console.info(TAG, 'not in recording');
      return;
    }
    try {
      if (this.avRecorder) {
        await this.avRecorder.stop();
      }
      if (this.videoOutput) {
        await this.videoOutput.stop();
      }
      this.isRecording = false;
    } catch (error) {
      let err = error as BusinessError;
      console.error(TAG, `stopVideo err: ${JSON.stringify(err)}`);
    }
    console.info(TAG, 'stopVideo End of call');
  }

  /**
   * 闪关灯
   */
  hasFlashFn(flashMode: camera.FlashMode): void {
    // 检测是否有闪关灯
    let hasFlash = this.session?.hasFlash();
    console.debug(TAG, `hasFlash success, hasFlash: ${hasFlash}`);
    // 检测闪光灯模式是否支持
    let isFlashModeSupported = this.session?.isFlashModeSupported(flashMode);
    console.debug(TAG, `isFlashModeSupported success, isFlashModeSupported: ${isFlashModeSupported}`);
    // 设置闪光灯模式
    this.session?.setFlashMode(flashMode);
  }

  /**
   * 焦点
   */
  setFocusPoint(point: camera.Point): void {
    // 设置焦点
    this.session?.setFocusPoint(point);
    console.info(TAG, `setFocusPoint success point: ${JSON.stringify(point)}`);
    // 获取当前的焦点
    let nowPoint: camera.Point | undefined = undefined;
    nowPoint = this.session?.getFocusPoint();
    console.info(TAG, `getFocusPoint success, nowPoint: ${JSON.stringify(nowPoint)}`);
  }

  /**
   * 曝光区域
   */
  isMeteringPoint(point: camera.Point): void {
    // 获取当前曝光模式
    let exposureMode: camera.ExposureMode | undefined = undefined;
    exposureMode = this.session?.getExposureMode();
    console.info(TAG, `getExposureMode success, exposureMode: ${exposureMode}`);
    this.session?.setMeteringPoint(point);
    let exposurePoint: camera.Point | undefined = undefined;
    exposurePoint = this.session?.getMeteringPoint();
    console.info(TAG, `getMeteringPoint exposurePoint: ${JSON.stringify(exposurePoint)}`);
  }

  /**
   * 曝光补偿
   */
  isExposureBiasRange(exposureBias: number): void {
    console.debug(TAG, `setExposureBias value ${exposureBias}`);
    // 查询曝光补偿范围
    let biasRangeArray: Array<number> | undefined = [];
    biasRangeArray = this.session?.getExposureBiasRange();
    console.debug(TAG, `getExposureBiasRange success, biasRangeArray: ${JSON.stringify(biasRangeArray)}`);
    // 设置曝光补偿
    this.session?.setExposureBias(exposureBias);
  }

  /**
   * 对焦模式
   */
  setFocusMode(focusMode: camera.FocusMode): void {
    // 检测对焦模式是否支持
    console.info(TAG, `setFocusMode is called`);
    let isSupported = this.session?.isFocusModeSupported(focusMode);
    console.info(TAG, `setFocusMode isSupported: ${isSupported}`);
    // 设置对焦模式
    if (!isSupported) {
      return;
    }
    this.session?.setFocusMode(focusMode);
  }
}

export default new CameraService();