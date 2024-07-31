import {
    DatabaseOptions,
    NIMHttpServiceConfig,
  NIMInitializeOptions,
  NIMLoginServiceConfig,
    NIMPushServiceConfig,
  NIMServiceOptions,
  V2NIMError
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../common/CommonConstants';
import CustomDialogWidget from '../dialog/CustomDialogWidget';
import { UserModel } from '../viewmodel/UserModel';
import prompt from '@ohos.promptAction';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor($r('app.color.background'))
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  //.margin({ top: $r('app.float.input_margin_top') })
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
struct Initialize1Page {
  // initialize
  @State appkey: string = 'fe416640c8e8a72734219e1847ad2547'
  @State debugLevel: string = 'debug'
  @State xhrConnectTimeout: number = 30000
  @State socketConnectTimeout: number = 30000
  //loginServiceConfig
  @State lbsUrls: string[] = ['https://imtest.netease.im/lbs/webconf']
  @State linkUrl?: string = 'imtest-jd.netease.im:8091'
  @State customClientType?: number = 0
  @State customTag?: string = ''
  //pushServiceConfig
  @State harmonyCertificateName?: string = 'DEMO_HMOS_PUSH'
  //NIMHttpServiceConfig
  @State chunkUploadHost?: string = ''
  @State uploadReplaceFormat?: string = ''
  /**
   * Specifies whether the database is encrypted.
   *
   */
  @State encrypt?: boolean = false
  /**
   * initialization app key
   */
  //@State appKey: string = 'fe416640c8e8a72734219e1847ad2547'

  //serviceOptions
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
  private timeOutId: number = -1;
  private userModel: UserModel | undefined;

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

  async initSDK(): Promise<void> {
    try {
      console.info(`-----------init sdk----------- \n`)
      const initializeOptions = {
        appkey: this.appkey,
        debugLevel: this.debugLevel,
        xhrConnectTimeout: this.xhrConnectTimeout,
        socketConnectTimeout: this.socketConnectTimeout
      } as NIMInitializeOptions

    const serverConfig = {
        loginServiceConfig : {
          lbsUrls: this.lbsUrls,
          linkUrl: this.linkUrl,
          customClientType: this.customClientType,
          customTag: this.customTag
        },
      pushServiceConfig:{
          harmonyCertificateName: this.harmonyCertificateName
      },
      httpServiceConfig: {
          uploadReplaceFormat: this.uploadReplaceFormat,
        chunkUploadHost: this.chunkUploadHost
      },
      databaseServiceConfig: {
          appKey: this.appkey,
        encrypt: this.encrypt
      }

    }as NIMServiceOptions
      this.getUserModel().initNim(initializeOptions, serverConfig)
      prompt.showToast({
        message: 'NIM初始化成功'
      })
    } catch (error) {
      console.log('----------- create 失败 -----------', error)
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
            Text('InitSDK')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))

            Text('init sdk ')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })

            Line().lineStyle()
            Text('init params').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            Text('appkey:').fontWeight(FontWeight.Bold)
            TextInput({ text: this.appkey, placeholder: '' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.appkey = value;
              })

            Row() {
                Text('debugLevel:').fontWeight(FontWeight.Bold)
                TextInput({ text: this.debugLevel, placeholder: '"off" | "error" | "warn" | "log" | "debug"' })
                  //.padding({left: 0, top: 0, bottom: 10})
                  //.textAlign(TextAlign.Start)
                  .type(InputType.Normal)
                  .inputStyle()
                  .onChange((value: string) => {
                    this.debugLevel = value;
                  })
            }.alignItems(VerticalAlign.Center)

            Row() {
              Text('xhrConnectTimeout:').fontWeight(FontWeight.Bold)
              TextInput({ text: `${this.xhrConnectTimeout}`, placeholder: 'xhrConnectTimeout' })
                .placeholderColor($r('app.color.text_input_place_holder'))
                .placeholderFont({ size: $r('app.float.text_input_font_size') })
                .backgroundColor($r('app.color.login_input_text_background'))
                .fontSize($r('app.float.text_input_font_size'))
                .padding({ left: $r('app.float.username_padding_left') })
                .border({
                  width: { bottom: $r('app.float.input_border_width') },
                  color: $r('app.color.input_border_color'),
                  radius: $r('app.float.input_border_radius')
                })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Number)
                .inputStyle()
                .onChange((value: string) => {
                  this.xhrConnectTimeout = parseInt(value);
                })
            }
            Row() {
              Text('socketConnectTimeout:').fontWeight(FontWeight.Bold)
              TextInput({ text: `${this.socketConnectTimeout}`, placeholder: 'socketConnectTimeout' })
                .placeholderColor($r('app.color.text_input_place_holder'))
                .placeholderFont({ size: $r('app.float.text_input_font_size') })
                .backgroundColor($r('app.color.login_input_text_background'))
                .fontSize($r('app.float.text_input_font_size'))
                .padding({ left: $r('app.float.username_padding_left') })
                .border({
                  width: { bottom: $r('app.float.input_border_width') },
                  color: $r('app.color.input_border_color'),
                  radius: $r('app.float.input_border_radius')
                })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.socketConnectTimeout = parseInt(value);
                })
            }
            Line().lineStyle()
            Text('login params').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            Row() {
              Text('lbsUrls:').fontWeight(FontWeight.Bold)
              TextInput({ text: `${this.lbsUrls}`, placeholder: 'lbsUrls 以逗号分隔' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.lbsUrls = value.split(',')
                })
            }
            Row() {
              Text('linkUrl:').fontWeight(FontWeight.Bold)
              TextInput({ text: this.linkUrl, placeholder: 'linkUrl' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.linkUrl = value
                })
            }
            Row() {
              Text('customClientType:').fontWeight(FontWeight.Bold)
              TextInput({ text: `${this.customClientType}`, placeholder: 'customClientType' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.customClientType = parseInt(value)
                })
            }
            Row() {
              Text('customTag:').fontWeight(FontWeight.Bold)
              TextInput({ text: this.customTag, placeholder: 'customTag' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.customTag = value
                })
            }
            Line().lineStyle()

            Text('pushServiceConfig').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            Column() {
              Text('harmonyCertificateName:').fontWeight(FontWeight.Bold)
              TextInput({ text: this.harmonyCertificateName, placeholder: 'harmonyCertificateName' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.harmonyCertificateName = value
                })
            }
            Line().lineStyle()

            Text('httpServiceConfig').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            TextInput({ text: this.chunkUploadHost, placeholder: 'chunkUploadHost' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.chunkUploadHost = value
              })
            TextInput({ text: this.uploadReplaceFormat, placeholder: 'uploadReplaceFormat' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.uploadReplaceFormat = value
              })
            Line().lineStyle()
            Text('databaseServiceConfig').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            TextInput({ text: `${this.encrypt}`, placeholder: 'encrypt' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.encrypt = parseInt(value) > 0 ? true : false
              })
            Line().lineStyle()

            Button(('InitSDK'), { type: ButtonType.Capsule })
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
                this.initSDK();
              })

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
      .title('back')
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}

function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ?
    JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}