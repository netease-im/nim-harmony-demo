import { BusinessError } from '@ohos.base';
import audio from '@ohos.multimedia.audio';

const TAG = 'AudioCapturer';

class Options {
  offset?: number;
  length?: number;
}

export class AudioCapturer {
  context: Context
  bufferSize: number = 0;
  audioCapturer: audio.AudioCapturer | undefined = undefined;
  filepath: string = ''
  audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
    channels: audio.AudioChannel.CHANNEL_2, // 通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
  }
  audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC, // 音源类型
    capturerFlags: 0 // 音频采集器标志
  }
  audioCapturerOptions: audio.AudioCapturerOptions = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo
  }

  constructor(context: Context) {
    this.context = context
  }

  init(callback: (buffer: ArrayBuffer) => void) {
    audio.createAudioCapturer(this.audioCapturerOptions, (err, capturer) => { // 创建AudioCapturer实例
      if (err) {
        console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info(`${TAG}: create AudioCapturer success`);
      this.audioCapturer = capturer;
      if (this.audioCapturer !== undefined) {
        (this.audioCapturer as audio.AudioCapturer).on('readData', callback)
      }
    });
  }

  start() {
    if (this.audioCapturer !== undefined) {
      let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
      if (stateGroup.indexOf((this.audioCapturer as audio.AudioCapturer).state.valueOf()) ===
        -1) { // 当且仅当状态为STATE_PREPARED、STATE_PAUSED和STATE_STOPPED之一时才能启动采集
        console.error(`${TAG}: start failed`);
        return;
      }

      // 启动采集
      (this.audioCapturer as audio.AudioCapturer).start((err: BusinessError) => {
        if (err) {
          console.error('Capturer start failed.');
        } else {
          console.info('Capturer start success.');
        }
      });
    }
  }

  // 停止采集
  stop(callback:(err: BusinessError | null)=>void) {
    if (this.audioCapturer !== undefined) {
      // 只有采集器状态为STATE_RUNNING或STATE_PAUSED的时候才可以停止
      if ((this.audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_RUNNING &&
        (this.audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_PAUSED) {
        console.info('Capturer is not running or paused');
        return;
      }

      //停止采集
      (this.audioCapturer as audio.AudioCapturer).stop((err: BusinessError) => {
        if (err) {
          console.error('Capturer stop failed.');
          callback(err)
        } else {
          //fs.close(file);
          callback(null)
          console.info('Capturer stop success.');
        }
      });
    }
  }

  release() {
    if (this.audioCapturer !== undefined) {
      // 采集器状态不是STATE_RELEASED或STATE_NEW状态，才能release
      if ((this.audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_RELEASED ||
        (this.audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_NEW) {
        console.info('Capturer already released');
        return;
      }

      //释放资源
      (this.audioCapturer as audio.AudioCapturer).release((err: BusinessError) => {
        if (err) {
          console.error('Capturer release failed.');
        } else {
          console.info('Capturer release success.');
        }
      });
    }
  }
}