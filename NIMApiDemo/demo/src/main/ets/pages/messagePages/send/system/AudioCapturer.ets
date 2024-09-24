// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import fs from '@ohos.file.fs';

let avProfile: media.AVRecorderProfile = {
  audioBitrate: 100000, // 音频比特率
  audioChannels: 2, // 音频声道数
  audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
  audioSampleRate: 48000, // 音频采样率
  fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
}


let avConfig: media.AVRecorderConfig = {
  audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
  profile: avProfile,
  url: '', // 参考应用文件访问与管理开发示例新建并读写一个文件
};

export class AudioRecordManager {
  public static instance: AudioRecordManager = new AudioRecordManager()
  private avRecorder?: media.AVRecorder;

  // 初始化
  public setup() {
    if (this.avRecorder === undefined) {
      media.createAVRecorder().then((recorder: media.AVRecorder) => {
        console.log('net ease AudioRecordManager create success');
        this.avRecorder = recorder;
        this.setupAudioRecordListen();
      }, (error: BusinessError) => {
        console.error(`net ease createAVRecorder failed ${error}`);
      })
    }
  }

  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    if (this.avRecorder !== undefined) {
      // 状态机变化回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        console.log(`net ease AudioRecorder current state is ${state}`);
      })
      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error(`net ease AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
      })
    }
  }

  async startRecordingProcess(path: string) {
    if (this.avRecorder !== undefined) {
      await this.avRecorder.release();
      this.avRecorder = undefined;
    }
    // await FileUtils.createFile(path)

    // 1.创建录制实例
    this.avRecorder = await media.createAVRecorder();
    this.setAudioRecorderCallback();
    // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
    let file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    let url = 'fd://' + file.fd

    console.log("net ease AudioRecorder url is: " + url);
    avConfig.url = url;

    // 3.配置录制参数完成准备工作
    await this.avRecorder.prepare(avConfig);
    // 4.开始录制
    await this.avRecorder.start();

    console.log('net ease AudioRecorder start success')
  }

  // 暂停录制对应的流程
  async pauseRecordingProcess() {
    if (this.avRecorder != undefined && this.avRecorder.state === 'started') { // 仅在started状态下调用pause为合理状态切换
      await this.avRecorder.pause();
    }
  }

  // 恢复录制对应的流程
  async resumeRecordingProcess() {
    if (this.avRecorder != undefined && this.avRecorder.state === 'paused') { // 仅在paused状态下调用resume为合理状态切换
      await this.avRecorder.resume();
    }
  }

  // 停止录制对应的流程
  async stopRecordingProcess() {
    if (this.avRecorder != undefined) {
      // 1. 停止录制
      if (this.avRecorder.state === 'started'
        || this.avRecorder.state === 'paused') { // 仅在started或者paused状态下调用stop为合理状态切换
        await this.avRecorder.stop();
      }
      // 2.重置
      await this.avRecorder.reset();
      // 3.释放录制实例
      await this.avRecorder.release();
      this.avRecorder = undefined;
      // 4.关闭录制文件fd
    }
  }

  // 回调监听
  private setupAudioRecordListen() {
    if (this.avRecorder !== undefined) {
      // 状态上报回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        console.log(`net ease current state is ${state}`);
        // 用户可以在此补充状态发生切换后想要进行的动作
      })

      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error(`net ease avRecorder failed, code is ${err.code}, message is ${err.message}`);
      })
    }
  }
}