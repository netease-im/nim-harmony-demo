import { LogLevel, NIMInitializeOptions, NIMServiceOptions, V2NIMError } from '@nimsdk/base';
import prompt from '@ohos.promptAction';
import { CommonConstants, shownDialog } from '../common/CommonConstants';
import CustomDialogWidget from '../dialog/CustomDialogWidget';
import { UserModel } from '../viewmodel/UserModel';

export enum ServerConfig {
  TEST = 0,
  REL = 1,
  CUSTOM = 2
}

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
struct InitializePage {
  // initialize
  @State appkey: string = '45c6af3c98409b18a84451215d0bdd6e'
  @State logLevel: LogLevel = LogLevel.Debug
  @State xhrConnectTimeout: number = 30000
  @State socketConnectTimeout: number = 30000
  @State isOpenConsoleLog: boolean = true
  //loginServiceConfig
  @State lbsUrls: string[] = ['https://lbs.netease.im/lbs/webconf.jsp']
  @State linkUrl?: string = 'weblink.netease.im:443'
  @State customClientType?: number = 0
  @State customTag?: string = ''
  @State isHttps: boolean = true
  //pushServiceConfig
  @State harmonyCertificateName?: string = 'DEMO_HMOS_PUSH'
  //NIMHttpServiceConfig
  @State chunkUploadHost?: string = ''
  @State uploadReplaceFormat?: string = ''
  @State downloadHost?: string = ''
  @State downloadReplaceFormat?: string = ''
  @State model: number = 0
  @State securityLevel: number = 1
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
        logLevel: this.logLevel,
        isOpenConsoleLog: this.isOpenConsoleLog,
        xhrConnectTimeout: this.xhrConnectTimeout,
        socketConnectTimeout: this.socketConnectTimeout
      } as NIMInitializeOptions

      const serverConfig = {
        loginServiceConfig: {
          lbsUrls: this.lbsUrls,
          linkUrl: this.linkUrl,
          customClientType: this.customClientType,
          customTag: this.customTag,
          isHttps: this.isHttps
        },
        pushServiceConfig: {
          harmonyCertificateName: this.harmonyCertificateName
        },
        httpServiceConfig: {
          uploadReplaceFormat: this.uploadReplaceFormat,
          chunkUploadHost: this.chunkUploadHost
        },
        storageServiceConfig: {
          downloadHost: this.downloadHost,
          downloadReplaceFormat: this.downloadReplaceFormat
        },
        databaseServiceConfig: {
          appKey: this.appkey,
          encrypt: this.encrypt,
          securityLevel: this.securityLevel
        }

      } as NIMServiceOptions

      this.getUserModel().initNim(initializeOptions, serverConfig)
      prompt.showToast({
        message: 'NIM初始化成功'
      })
      console.log('----------- NIM初始化设置 -----------')
      console.log('NIM initialize options', JSON.stringify(initializeOptions))
      console.log('NIM service options', JSON.stringify(serverConfig))
      console.log('----------- NIM初始化设置 -----------')
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
            Text('init params').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            Row() {
              Text('appkey:').fontWeight(FontWeight.Bold)
              TextInput({ text: this.appkey, placeholder: '' })
                .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
                .type(InputType.Normal)
                .inputStyle()
                .fontSize(14)
                .onChange((value: string) => {
                  this.appkey = value;
                })
            }

            Row() {
              Text('logLevel:').fontWeight(FontWeight.Bold)
              TextInput({
                text: this.logLevel,
                placeholder: '"Error" | "Warn" | "Info" | "Debug"'
              })//.padding({left: 0, top: 0, bottom: 10})
                //.textAlign(TextAlign.Start)
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  if (value === LogLevel.Debug) {
                    this.logLevel = LogLevel.Debug
                  }
                  if (value === LogLevel.Info) {
                    this.logLevel = LogLevel.Info
                  }
                  if (value === LogLevel.Warn) {
                    this.logLevel = LogLevel.Warn
                  }
                  if (value === LogLevel.Error) {
                    this.logLevel = LogLevel.Error
                  }
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

            Text('isOpenConsoleLog')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'true', group: 'consoleLogGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.isOpenConsoleLog = true
                  }
                })
              Text('true')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'false', group: 'consoleLogGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.isOpenConsoleLog = false
                  }
                })
              Text('false')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
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

            Text('isHttps')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'true', group: 'isHttpsGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.isHttps = true
                  }
                })
              Text('true')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'false', group: 'isHttpsGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.isHttps = false
                  }
                })
              Text('false')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()

            Text('pushServiceConfig').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            Row() {
              Text('CertificateName:').fontWeight(FontWeight.Bold)
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
            Text('storageServiceConfig').fontColor(Color.Blue).fontWeight(FontWeight.Medium)
            TextInput({ text: this.downloadHost, placeholder: 'downloadHost' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.downloadHost = value
              })
            TextInput({ text: this.downloadReplaceFormat, placeholder: 'downloadReplaceFormat' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.downloadReplaceFormat = value
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
            TextInput({ text: `${this.securityLevel}`, placeholder: 'securityLevel' })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.securityLevel = parseInt(value)
              })
            Line().lineStyle()
            // REL

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'REL', group: 'initGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.changeModel(1)
                  }
                })
              Text('REL')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            // TEST
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'TEST', group: 'initGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.changeModel(0)
                  }
                })
              Text('TEST')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            // CUSTOM
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'CUSTOM', group: 'initGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.changeModel(2)
                  }
                })
              Text('CUSTOM')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

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
      .title('初始化设置')
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(CommonConstants.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }

  changeModel(model: number) {
    console.warn('------------- 创建NIM实例 --------------')
    this.model = model
    let initializeOptions: NIMInitializeOptions = {
      appkey: "xxx",
    }

    let serviceOptions: NIMServiceOptions = {
      loginServiceConfig: {},
    }
    // 测试服
    if (this.model === 0) {
      initializeOptions = {
        appkey: "fe416640c8e8a72734219e1847ad2547",
        logLevel: LogLevel.Debug,
        isOpenConsoleLog: true
        // ...其他属性
      };

      serviceOptions = {
        loginServiceConfig: {
          lbsUrls: ['https://imtest-gy.netease.im/lbs/webconf'],
          linkUrl: 'weblink-dev-gy.netease.im:443'
        },
        pushServiceConfig: {
          harmonyCertificateName: "DEMO_HMOS_PUSH"
        },
        databaseServiceConfig: {
          encrypt: false,
          appKey: "fe416640c8e8a72734219e1847ad2547",
        }
      }

      this.appkey = 'fe416640c8e8a72734219e1847ad2547'
      this.logLevel = LogLevel.Debug
      this.xhrConnectTimeout = 30000
      this.socketConnectTimeout = 30000
      this.lbsUrls = ['https://imtest.netease.im/lbs/webconf']
      this.linkUrl = 'imtest-jd.netease.im:8091'
      this.customClientType = 0
      this.customTag = ''
      //pushServiceConfig
      this.harmonyCertificateName = 'DEMO_HMOS_PUSH'
      //NIMHttpServiceConfig
      this.chunkUploadHost = ''
      this.uploadReplaceFormat = ''
    } else if (this.model === 1) {
      // 正式服
      initializeOptions = {
        appkey: "45c6af3c98409b18a84451215d0bdd6e",
        logLevel: LogLevel.Debug,
        isOpenConsoleLog: true
        // ...其他属性
      };

      serviceOptions = {
        loginServiceConfig: {
          lbsUrls: ['https://lbs.netease.im/lbs/webconf.jsp'],
          linkUrl: 'weblink.netease.im:443'
        },
        pushServiceConfig: {
          harmonyCertificateName: "DEMO_HMOS_PUSH"
        },
        databaseServiceConfig: {
          encrypt: false,
          appKey: "45c6af3c98409b18a84451215d0bdd6e",
        }
      }

      this.appkey = '45c6af3c98409b18a84451215d0bdd6e'
      this.logLevel = LogLevel.Debug
      this.xhrConnectTimeout = 30000
      this.socketConnectTimeout = 30000
      this.lbsUrls = ['https://lbs.netease.im/lbs/webconf.jsp']
      this.linkUrl = 'weblink.netease.im:443'
      this.customClientType = 0
      this.customTag = ''
      //pushServiceConfig
      this.harmonyCertificateName = 'DEMO_HMOS_PUSH'
      //NIMHttpServiceConfig
      this.chunkUploadHost = 'https://yunxinent-demo.netease.im'
      this.uploadReplaceFormat = 'https://yunxinent-demo.netease.im/yunxin/{object}'
      this.downloadHost = ''
      this.downloadReplaceFormat = ''
      this.encrypt = false
      this.securityLevel = 1
    } else if (this.model === 2) {
      // 私有化
      initializeOptions = {
        appkey: "c3a82b40cd2b0998cb11afbcdeff1837",
        logLevel: LogLevel.Debug,
        isOpenConsoleLog: true
        // ...其他属性
      };

      serviceOptions = {
        loginServiceConfig: {
          lbsUrls: ['https://yunxinent-demo.netease.im/lbs/webconf.jsp'],
          linkUrl: 'yunxinent-demo.netease.im'
        },
        pushServiceConfig: {
          harmonyCertificateName: "DEMO_HMOS_PUSH"
        },
        httpServiceConfig: {
          chunkUploadHost: 'https://yunxinent-demo.netease.im',
          uploadReplaceFormat: 'https://yunxinent-demo.netease.im/yunxin/{object}'
        },
        databaseServiceConfig: {
          encrypt: false,
          appKey: "c3a82b40cd2b0998cb11afbcdeff1837",
        }
      }

      this.appkey = 'c3a82b40cd2b0998cb11afbcdeff1837'
      this.logLevel = LogLevel.Debug
      this.xhrConnectTimeout = 30000
      this.socketConnectTimeout = 30000
      this.lbsUrls = ['https://yunxinent-demo.netease.im/lbs/webconf.jsp']
      this.linkUrl = 'yunxinent-demo.netease.im'
      this.customClientType = 0
      this.customTag = ''
      //pushServiceConfig
      this.harmonyCertificateName = 'DEMO_HMOS_PUSH'
      //NIMHttpServiceConfig
      this.chunkUploadHost = 'https://yunxinent-demo.netease.im'
      this.uploadReplaceFormat = 'https://yunxinent-demo.netease.im/yunxin/{object}'
      this.encrypt = false
    } else {
      console.error('unknown config')
    }
    //this.initNim(initializeOptions, serviceOptions)
    //// this._nim = NIMSdk.newInstance(context, initializeOptions, serviceOptions)
    //console.log("nim from createDefaultNim: " + this._nim)
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