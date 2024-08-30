import { http } from '@kit.NetworkKit';
import {
  V2NIMClearHistoryNotification,
  V2NIMConnectStatus,
  V2NIMDataSyncState,
  V2NIMDataSyncType,
  V2NIMError,
  V2NIMKickedOfflineDetail,
  V2NIMLoginClient,
  V2NIMLoginClientChange,
  V2NIMLoginOption,
  V2NIMLoginStatus,
  V2NIMMessage,
  V2NIMMessageDeletedNotification,
  V2NIMMessagePinNotification,
  V2NIMMessageQuickCommentNotification,
  V2NIMMessageRevokeNotification,
  V2NIMP2PMessageReadReceipt,
  V2NIMTeamMessageReadReceipt
} from '@nimsdk/base';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import cryptoFramework from '@ohos.security.cryptoFramework';
import { CommonConstants, shownListenerDialog } from '../common/CommonConstants';
import { UserModel } from '../viewmodel/UserModel';

export interface TokenProvider {
  code: number,
  data: string
}

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
  //@State loginOptionValue: string = '{"retryCount":3,"timeout":60000,"forceMode":false,"authType":0,"syncLevel":0}';
  @State forceMode: boolean = false;
  @State retryCount: number = 3;
  @State timeout: number = 60000;
  @State authType: number = 0;
  @State syncLevel: number = 0;
  @State tokenProviderEnabled: boolean = false;
  @State tokenProviderValue: string = '';
  @State tokenProviderAutogen: boolean = false;
  @State reconnectDelayProviderEnabled: boolean = false;
  @State reconnectDelayProviderTimeout: number = 3000;
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
          Text('V2NIMLoginOption').fontWeight(FontWeight.Bold).width(CommonConstants.LOGIN_PAGE_WIDTH_PERCENT)
          Row() {
            Text('forceMode').fontWeight(FontWeight.Bold)
            Checkbox({ name: 'forceMode' })
              .select(this.forceMode)
              .onChange((value: boolean) => {
                this.forceMode = value
              })
            Text('authType:').fontWeight(FontWeight.Bold)
            TextInput({ text: `${this.authType}` })
              .width(30)
              .type(InputType.Number)
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
                this.authType = parseInt(value);
              })
            Text('syncLevel:').fontWeight(FontWeight.Bold)
            TextInput({ text: `${this.syncLevel}` })
              .width(30)
              .type(InputType.Number)
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
                this.syncLevel = parseInt(value);
              })
          }.width(CommonConstants.BUTTON_WIDTH_PERCENT)

          Row() {
            Text('retry count:').fontWeight(FontWeight.Bold)
            TextInput({ text: `${this.retryCount}` })
              .width(50)
              .type(InputType.Number)
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
                this.retryCount = parseInt(value);
              })

            Text('timeout:').fontWeight(FontWeight.Bold)
            TextInput({ text: `${this.timeout}` })
              .width(80)
              .type(InputType.Number)
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
                this.timeout = parseInt(value);
              })
          }.width(CommonConstants.BUTTON_WIDTH_PERCENT)

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
          }
          .width(CommonConstants.BUTTON_WIDTH_PERCENT)

          Row() {
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

          Row() {
            Text('setReconnectDelayProvider').fontWeight(FontWeight.Bold)
            Checkbox()
              .select(this.reconnectDelayProviderEnabled)
              .onChange((value: boolean) => {
                this.reconnectDelayProviderEnabled = value
                if (this.reconnectDelayProviderEnabled) {
                  this.setReconnectDelayProvider(true, this.reconnectDelayProviderTimeout)
                } else {
                  this.setReconnectDelayProvider(false)
                }

              })
            TextInput({ text: `${this.reconnectDelayProviderTimeout}`, placeholder: '重联timeout' })
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
                const timeout = parseInt(value)
                this.reconnectDelayProviderTimeout = timeout
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

  setReconnectDelayProvider(enable: boolean, timeout?: number) {
    if (enable) {
      this.getUserModel().getNimSdk().loginService.setReconnectDelayProvider(
        (delay) => {
          console.info(' setReconnectDelayProvider default: ', delay)
          return timeout
        }
      )
    } else {
      this.getUserModel().getNimSdk().loginService.setReconnectDelayProvider(null)
    }
  }

  async login(context: common.Context) {
    try {
      let loginOption = {
        retryCount: this.retryCount,
        forceMode: this.forceMode,
        authType: this.authType,
        timeout: this.timeout,
        syncLevel: this.syncLevel,
      } as V2NIMLoginOption

      if (this.tokenProviderEnabled) {
        loginOption.tokenProvider = async (accountId: string) => {
          if (this.tokenProviderAutogen) {
            const token = await this.getProviderToken()
            return token
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
        //this.addLoginListener()
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
      let desc = `${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ?
      JSON.stringify(err.detail) : ''}`
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
      this.removeListener();
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

  async getProviderToken(): Promise<string> {
    let httpRequest = http.createHttp();
    const url =
      'http://imtest.netease.im/nimserver/god/mockDynamicToken.action?' + 'appkey=fe416640c8e8a72734219e1847ad2547' +
        `&accid=${this.userName}`
    const repose =
      await httpRequest.request(url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          //extraData: {
          //  'appkey': 'fe416640c8e8a72734219e1847ad2547',
          //  'accid': this.userName
          //}
        })

    console.info('get token :', repose);
    const data = repose.result as string
    const tokenProvider: TokenProvider = JSON.parse(data)
    return tokenProvider.data
  }

  addLoginListener() {
    this.getUserModel().getNimSdk().loginService.on('onLoginStatus', (status: V2NIMLoginStatus) => {
      shownListenerDialog('onLoginStatus', JSON.stringify(status));
    });

    this.getUserModel().getNimSdk().loginService.on('onLoginFailed', (error: V2NIMError) => {
      shownListenerDialog('onLoginStatus', JSON.stringify(error));
    });

    this.getUserModel().getNimSdk().loginService.on('onKickedOffline', (detail: V2NIMKickedOfflineDetail) => {
      shownListenerDialog('onKickedOffline', JSON.stringify(detail));
    });

    this.getUserModel()
      .getNimSdk()
      .loginService
      .on('onLoginClientChanged', (change: V2NIMLoginClientChange, clients: V2NIMLoginClient[]) => {
        shownListenerDialog('onLoginClientChanged', `change ${change},${JSON.stringify(clients)}`);
      });

    this.getUserModel().getNimSdk().loginService.on('onConnectStatus', (status: V2NIMConnectStatus) => {
      shownListenerDialog('onConnectStatus', JSON.stringify(status));
    });

    this.getUserModel().getNimSdk().loginService.on('onDisconnected', (error: V2NIMError) => {
      shownListenerDialog('onDisconnected', JSON.stringify(error));
    });

    this.getUserModel().getNimSdk().loginService.on('onConnectFailed', (error: V2NIMError) => {
      shownListenerDialog('onConnectFailed', JSON.stringify(error));
    });


    this.getUserModel()
      .getNimSdk()
      .loginService
      .on('onDataSync', (type: V2NIMDataSyncType, state: V2NIMDataSyncState, error?: V2NIMError) => {
        shownListenerDialog('onDataSync', `${type}, ${state}, ${JSON.stringify(error)}`);
      });

    this.getUserModel().getNimSdk().messageService!.on("onReceiveMessages", (messages: V2NIMMessage[]) => {
      console.info('onReceiveMessages', JSON.stringify(messages, null, 2))
    })
  }

  removeListener() {
    // Demo启用message模块，messageService不为空
    this.getUserModel().getNimSdk().messageService!.removeAllListeners()
    this.getUserModel().getNimSdk().loginService.removeAllListeners()
    this.getUserModel().getNimSdk().messageService!.off("onSendMessage", (message: V2NIMMessage) => {
      console.info('onSendMessage', JSON.stringify(message, null, 2))
    })

    this.getUserModel().getNimSdk().messageService!.off("onReceiveMessages", (messages: V2NIMMessage[]) => {
      console.info('onReceiveMessages', JSON.stringify(messages, null, 2))
    })

    this.getUserModel().getNimSdk().messageService!.off("onReceiveP2PMessageReadReceipts",
      (readReceipts: V2NIMP2PMessageReadReceipt[]) => {
        console.info('onReceiveP2PMessageReadReceipts', JSON.stringify(readReceipts, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onReceiveTeamMessageReadReceipts",
      (readReceipts: V2NIMTeamMessageReadReceipt[]) => {
        console.info('onReceiveTeamMessageReadReceipts', JSON.stringify(readReceipts, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onMessageRevokeNotifications",
      (message: V2NIMMessageRevokeNotification[]) => {
        console.info('onMessageRevokeNotifications', JSON.stringify(message, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onMessageDeletedNotifications",
      (notification: V2NIMMessageDeletedNotification[]) => {
        console.info('onMessageDeletedNotifications', JSON.stringify(notification, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onClearHistoryNotifications",
      (notification: V2NIMClearHistoryNotification[]) => {
        console.info('onClearHistoryNotifications', JSON.stringify(notification, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onMessagePinNotification",
      (notification: V2NIMMessagePinNotification) => {
        console.info('onMessagePinNotification', JSON.stringify(notification, null, 2))
      })

    this.getUserModel().getNimSdk().messageService!.off("onMessageQuickCommentNotification",
      (notification: V2NIMMessageQuickCommentNotification) => {
        console.info('onMessageQuickCommentNotification', JSON.stringify(notification, null, 2))
      })
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