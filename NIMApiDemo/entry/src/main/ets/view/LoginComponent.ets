import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CommonConstants } from '../common/constants/CommonConstants';
import { V2NIMConnectStatus, V2NIMError, V2NIMLoginOption, V2NIMLoginStatus } from '@nimsdk/base';
import cryptoFramework from '@ohos.security.cryptoFramework';
import { UserModel } from '../viewmodel/UserModel';

/**
 * Login page component.
 */
@Component
export struct LoginComponent {
  @StorageProp('isMinHeight') isMinHeight: boolean = false;
  @State connectStatus: string = 'connectStatus:init';
  @State loginStatus: string = 'loginStatus:init';

  @State userName: string = '';
  @State password: string = '';
  @State loginOptionValue: string = '{"retryCount":3,"timeout":60000,"forceMode":false,"authType":0,"syncLevel":0}';

  @State tokenProviderEnabled: boolean = false;
  @State tokenProviderValue: string = '';
  @State tokenProviderAutogen: boolean = false;
  // @State tokenProviderReturnUndefined: boolean = false;

  @State extensionProviderEnabled: boolean = false;
  @State extensionProviderValue: string = '';
  // @State extensionProviderAutogen: boolean = false;
  // @State extensionProviderReturnUndefined: boolean = false;

  aboutToAppear() {
    this.loadLastLoginAccount()
  }

  aboutToDisappear() {
  }

  build() {
    GridRow({
      columns: {
        sm: CommonConstants.GRID_ROW_SM,
        md: CommonConstants.GRID_ROW_MD,
        lg: CommonConstants.GRID_ROW_LG
      },
      gutter: { x: CommonConstants.GUTTER_X },
      breakpoints: { value: CommonConstants.BREAK_POINT }
    }) {
      GridCol({
        span: {
          sm: CommonConstants.SPAN_SM,
          md: CommonConstants.SPAN_MD,
          lg: CommonConstants.SPAN_LG
        },
        offset: {
          sm: CommonConstants.OFFSET_SM,
          md: CommonConstants.OFFSET_MD,
          lg: CommonConstants.OFFSET_LG
        }
      }) {
        Column() {
          // Column() {
          //   Text(this.connectStatus).fontColor(Color.Gray).width('100%').backgroundColor(Color.Yellow)
          //   Text(this.loginStatus).fontColor(Color.Gray).width('100%').backgroundColor(Color.Yellow)
          // }.width('100%')

          TextInput({ text: this.userName, placeholder: $r('app.string.username') })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .height($r('app.float.text_input_height'))
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
            .onChange((value: string) => {
              this.userName = value;
            })

          TextInput({ text: this.password, placeholder: $r('app.string.password') })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .height($r('app.float.text_input_height'))
            .placeholderColor($r('app.color.text_input_place_holder'))
            .placeholderFont({ size: $r('app.float.text_input_font_size') })
            .fontSize($r('app.float.text_input_font_size'))
            .backgroundColor($r('app.color.login_input_text_background'))
            .type(InputType.Password)
            .padding({ left: $r('app.float.password_padding_left') })
            .border({
              width: { bottom: $r('app.float.input_border_width') },
              color: $r('app.color.input_border_color'),
              radius: $r('app.float.input_border_radius')
            })
            .margin({ bottom: $r('app.float.input_margin_bottom') })
            .onChange((value: string) => {
              this.password = value;
            })
        }
      }

      GridCol({
        span: {
          sm: CommonConstants.BUTTON_SPAN_SM,
          md: this.isMinHeight ? CommonConstants.BUTTON_SPAN_MD_SMALL : CommonConstants.BUTTON_SPAN_MD_BIG,
          lg: CommonConstants.BUTTON_SPAN_LG
        },
        offset: {
          sm: CommonConstants.BUTTON_OFFSET_SM,
          md: CommonConstants.BUTTON_OFFSET_MD,
          lg: CommonConstants.BUTTON_OFFSET_LG
        }
      }) {
        Button($r('app.string.login'))
          .width(CommonConstants.BUTTON_WIDTH_PERCENT)
          .height($r('app.float.login_btn_height'))
          .borderRadius($r('app.float.login_btn_border_radius'))
          .fontSize($r('app.float.text_input_font_size'))
          .margin({ top: $r('app.float.register_btn_margin_top') })
          .fontWeight(CommonConstants.LOGIN_TEXT_FONT_WEIGHT)
          .enabled(isLoginButtonClickable(this.userName, this.password))
          .fontColor(isLoginButtonClickable(this.userName, this.password) ?
          Color.White : $r('app.color.login_font_normal'))
          .backgroundColor(isLoginButtonClickable(this.userName, this.password) ?
          $r('app.color.login_btn_enabled') : $r('app.color.login_btn_normal'))
          .onClick(() => {
            this.login(getContext(this).getApplicationContext())
          })
      }

      GridCol({
        span: {
          sm: CommonConstants.BUTTON_SPAN_SM,
          md: this.isMinHeight ? CommonConstants.BUTTON_SPAN_MD_SMALL : CommonConstants.BUTTON_SPAN_MD_BIG,
          lg: CommonConstants.BUTTON_SPAN_LG
        },
        offset: {
          sm: CommonConstants.BUTTON_OFFSET_SM,
          md: CommonConstants.BUTTON_OFFSET_MD,
          lg: CommonConstants.BUTTON_OFFSET_LG
        }
      }) {
        Button($r('app.string.logout'))
          .width(CommonConstants.BUTTON_WIDTH_PERCENT)
          .height($r('app.float.login_btn_height'))
          .borderRadius($r('app.float.login_btn_border_radius'))
          .fontSize($r('app.float.text_input_font_size'))
          .margin({ top: $r('app.float.register_btn_margin_top') })
          .fontWeight(CommonConstants.LOGIN_TEXT_FONT_WEIGHT)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.login_btn_enabled'))
          .onClick(() => {
            this.logout()
          })
      }

      GridCol({
        span: {
          sm: CommonConstants.SPAN_SM,
          md: CommonConstants.SPAN_MD,
          lg: CommonConstants.SPAN_LG
        },
        offset: {
          sm: CommonConstants.OFFSET_SM,
          md: CommonConstants.OFFSET_MD,
          lg: CommonConstants.OFFSET_LG
        }
      }) {
        Column() {
          TextInput({ text: this.loginOptionValue, placeholder: 'V2NIMLoginOption' })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
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
            .onChange((value: string) => {
              this.loginOptionValue = value;
            })

          Row() {
            Text('V2NIMTokenProvider').fontWeight(FontWeight.Bold)
            Checkbox()
              .select(this.tokenProviderEnabled)
              .onChange((value: boolean) => {
                this.tokenProviderEnabled = value
              })
            Text('自动生成').fontWeight(FontWeight.Bold)
            Checkbox()
              .select(this.tokenProviderAutogen)
              .onChange((value: boolean) => {
                this.tokenProviderAutogen = value
              })
          }
          .width(CommonConstants.BUTTON_WIDTH_PERCENT)
          Row() {
            // Text('返回空').fontWeight(FontWeight.Bold)
            // Checkbox()
            //   .select(this.tokenProviderReturnUndefined)
            //   .onChange((value: boolean) => {
            //     this.tokenProviderReturnUndefined = value
            //   })
            TextInput({ text: "", placeholder: 'V2NIMTokenProvider' })
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
              .onChange((value: string) => {
                this.tokenProviderValue = value
              })
          }

          Row() {
            Text('V2NIMLoginExtensionProvider').fontWeight(FontWeight.Bold)
            Checkbox()
              .select(this.extensionProviderEnabled)
              .onChange((value: boolean) => {
                this.extensionProviderEnabled = value
              })
            // Text('自动生成').fontWeight(FontWeight.Bold)
            // Checkbox()
            //   .select(this.extensionProviderAutogen)
            //   .onChange((value: boolean) => {
            //     this.extensionProviderAutogen = value
            //   })
          }
          .width(CommonConstants.BUTTON_WIDTH_PERCENT)
          Row() {
            // Text('返回空').fontWeight(FontWeight.Bold)
            // Checkbox()
            //   .select(this.extensionProviderReturnUndefined)
            //   .onChange((value: boolean) => {
            //     this.extensionProviderReturnUndefined = value
            //   })
            TextInput({ text: "", placeholder: 'V2NIMLoginExtensionProvider' })
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
              .onChange((value: string) => {
                this.extensionProviderValue = value
              })
          }
        }
        .justifyContent(FlexAlign.Start)
      }
    }
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  async loadLastLoginAccount() {
    this.userName = await this.getUserModel().loadLastLoginAccount() as string
    this.password = '123456'
  }

  async saveLastLoginAccount(accid: string) {
    await this.getUserModel().saveLastLoginAccount(accid)
  }

  async md5(value: string) {
    let md5 = cryptoFramework.createMd("MD5");
    await md5.update({ 'data': stringToUint8Array(value) })
    return uint8ArrayToHex((await md5.digest()).data)
  }

  async login(context: common.Context) {
    try {
      let loginOption = JSON.parse(this.loginOptionValue) as V2NIMLoginOption

      if (this.tokenProviderEnabled) {
        loginOption.tokenProvider = async (accountId: string) => {
          if (this.tokenProviderAutogen) {
            return "AutoGen Result";
          } else {
            return this.tokenProviderValue
          }
        }
      }

      if (this.extensionProviderEnabled) {
        loginOption.loginExtensionProvider = (accountId: string) => {
          return this.extensionProviderValue
        }
      }

      try {
        let token = await this.md5(this.password)
        await this.getUserModel().getNimSdk().loginService.login(this.userName, token, loginOption)
        const accid = this.getUserModel().getNimSdk().loginService.getLoginUser()
        console.log('----------- 登录成功 -----------')
        this.saveLastLoginAccount(accid)
        AlertDialog.show(
          {
            title: '登录成功',
            message: accid,
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            offset: { dx: 0, dy: -20 },
            gridCount: 3,
            confirm: {
              value: 'OK',
              action: () => {
                console.info('Button-clicking callback')
                router.pushUrl({
                  url: 'pages/MainPage'
                });
              }
            },
            cancel: () => {
              console.info('Closed callbacks')
            }
          }
        )
      } catch (error) {
        console.log('----------- 登录失败 -----------', error)
        AlertDialog.show(
          {
            title: '登录失败',
            message: processV2ErrorForPrint(error),
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            offset: { dx: 0, dy: -20 },
            gridCount: 3,
            confirm: {
              value: 'OK',
              action: () => {
                console.info('Button-clicking callback')
              }
            },
            cancel: () => {
              console.info('Closed callbacks')
            }
          }
        )
      }

    } catch (err) {
      let desc = `${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ? JSON.stringify(err.detail) : ''}`
      if (err?.detail?.rawError) {
        desc += `\n rawError: ${err.detail.rawError.message}`
      }
      console.error(`----------- 登录失败 ----------- \n`, processV2ErrorForPrint(err))
      return
    }

    this.getUserModel().getNimSdk().loginService.on("onLoginStatus", (status: V2NIMLoginStatus) => {
      switch (status) {
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGOUT:
          console.log("status => logout");
          this.loginStatus = "logout"
          break;
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED:
          console.log("status => logined");
          this.loginStatus = "logined"
          break;
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINING:
          console.log("status => logining");
          this.loginStatus = "logining"
          break;
      }
    })

    this.getUserModel().getNimSdk().loginService.on("onConnectStatus", (status: V2NIMConnectStatus) => {
      switch (status) {
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_DISCONNECTED:
          console.log("connectStatus => disconnected");
          this.connectStatus = "disconnected"
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_CONNECTED:
          console.log("connectStatus => connected");
          this.connectStatus = "connected"
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_CONNECTING:
          console.log("connectStatus => connecting");
          this.connectStatus = "connecting"
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_WAITING:
          console.log("connectStatus => waiting for reconnect");
          this.connectStatus = "waiting for reconnect"
          break;
      }
    })
  }


  async logout() {
    try {
      const accid = this.getUserModel().getNimSdk().loginService.getLoginUser()
      await this.getUserModel().getNimSdk().loginService.logout()
      console.log('----------- 登出成功 -----------')
      AlertDialog.show(
        {
          title: '登出成功',
          message: accid,
          autoCancel: true,
          alignment: DialogAlignment.Bottom,
          offset: { dx: 0, dy: -20 },
          gridCount: 3,
          confirm: {
            value: 'OK',
            action: () => {
              console.info('Button-clicking callback')
            }
          },
          cancel: () => {
            console.info('Closed callbacks')
          }
        }
      )
    } catch (error) {
      console.log('----------- 登出失败 -----------', error)
      AlertDialog.show(
        {
          title: '登出失败',
          message: processV2ErrorForPrint(error),
          autoCancel: true,
          alignment: DialogAlignment.Bottom,
          offset: { dx: 0, dy: -20 },
          gridCount: 3,
          confirm: {
            value: 'OK',
            action: () => {
              console.info('Button-clicking callback')
            }
          },
          cancel: () => {
            console.info('Closed callbacks')
          }
        }
      )
    }
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

/**
 * Calculate login button clickable by the input of username and password.
 *
 * @return {boolean} isLoginButtonClickable.
 */
function isLoginButtonClickable(userName: string, password: string): boolean {
  return userName !== '' && password !== '';
}

function stringToUint8Array(str: string): Uint8Array {
  let arr: number[] = [];
  for (let i = 0; i < str.length; i++) {
    arr.push(str.charCodeAt(i));
  }
  return new Uint8Array(arr);
}

function uint8ArrayToHex(array: Uint8Array): string {
  return Array.from(array).map(b => b.toString(16).padStart(2, '0')).join('');
}
