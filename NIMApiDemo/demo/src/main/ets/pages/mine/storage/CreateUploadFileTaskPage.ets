import {
  V2NIMError, V2NIMFriendAddMode, V2NIMFriendAddParams, V2NIMUploadFileParams,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
import { UserModel } from '../../../viewmodel/UserModel';
import fs from '@ohos.file.fs';
import { fileIo } from '@kit.CoreFileKit';
@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor($r('app.color.background'))
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT)
  .height($r('app.float.line_height'))
  .backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct CreateUploadFileTaskPage {
  @State accountIds: string = ''
  @State isShowProgress: boolean = false;
  @State sceneName: string = 'nim_default_im'
  private timeOutId: number = -1;
  private userModel: UserModel | undefined;
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogWidget({
      hobbies: $hobbies
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    offset: {
      dx: 0,
      dy: -20
    }
  });

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
    }
    .height($r('app.float.other_login_image_size'))
    .width($r('app.float.other_login_image_size'))
    .backgroundColor($r('app.color.background'))
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  getRandomNumber(min: number, max: number): number {
    return Math.random() * (max - min) + min;
  }

  async createUploadFileTask() {
    try {
      const catchDir = getContext(this).getApplicationContext().cacheDir
      let fileDir = catchDir + '/nim';
      if (!fs.accessSync(fileDir)) {
        fs.mkdirSync(fileDir);
      }

      const randomNum = this.getRandomNumber(1, 4);

      const filePath = fileDir + '/fig' + `${randomNum}` + '.png'
      let file = await fileIo.open(filePath, fileIo.OpenMode
        .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer = getContext(this).resourceManager.getMediaContentSync($r('app.media.img').id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen = await fileIo.write(file.fd, buffer.buffer);
      console.info('write success,len=' + writeLen);
      const randomNum1 = this.getRandomNumber(1, 4);
      const filePath1 = fileDir + '/fig' + `${randomNum1}` + '.png'
      let file1 = await fileIo.open(filePath1, fileIo.OpenMode
      .READ_WRITE | fileIo.OpenMode.CREATE);
      let buffer1 = getContext(this).resourceManager.getMediaContentSync($r('app.media.love').id);
      // Write the read ArrayBuffer to the new media file.
      let writeLen1 = await fileIo.write(file1.fd, buffer1.buffer);
      console.info('write success,len=' + writeLen1);
      const storageService = this.getUserModel().getNimSdk().storageService!

      const taskParams = {
        filePath: filePath,
        sceneName: this.sceneName
      } as V2NIMUploadFileParams

      const taskParams1 = {
        filePath: filePath1,
        sceneName: this.sceneName
      } as V2NIMUploadFileParams

      const fileTask = storageService.createUploadFileTask(taskParams)

    storageService.uploadFile(fileTask, (progress: number)=> {
      //console.info(`uploadFile progress ${fileTask?.taskId}`, progress)
    }).then(url => {
      console.info(`uploadFile progress 0 ${fileTask?.taskId}`, url)
    }).catch((err: Error) => {
      console.info(`uploadFile progress ${fileTask?.taskId}`, err)
    })

      const fileTask1 = storageService.createUploadFileTask(taskParams1)

      storageService.uploadFile(fileTask1, (progress: number)=> {
        //console.info(`uploadFile progress ${fileTask1?.taskId}`, progress)
      }).then(url => {
        console.info(`uploadFile progress 0 ${fileTask1?.taskId}`, url)
      }).catch((err: Error) => {
        console.info(`uploadFile progress ${fileTask?.taskId}`, err)
      })

      shownDialog(true, JSON.stringify(fileTask1, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  aboutToAppear(): void {
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('CreateUploadFileTaskPage')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('create upload file task page')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            Button(('Create'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.login_button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.createUploadFileTask();
              })

            if (this.isShowProgress) {
              LoadingProgress()
                .color($r('app.color.loading_color'))
                .width($r('app.float.login_progress_size'))
                .height($r('app.float.login_progress_size'))
                .margin({ top: $r('app.float.login_progress_margin_top') })
            }
            Blank()
          }
        }
        .backgroundColor($r('app.color.background'))
        // .height(CommonConstants.FULL_PARENT)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          left: $r('app.float.page_padding_hor'),
          right: $r('app.float.page_padding_hor'),
          bottom: $r('app.float.login_page_padding_bottom')
        })
      }
      .size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 })
      .title('上传日志')
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}

function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ? JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}