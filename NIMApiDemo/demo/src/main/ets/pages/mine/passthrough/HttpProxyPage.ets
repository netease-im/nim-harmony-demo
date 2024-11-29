import { V2NIMProxyRequest, V2NIMProxyRequestMethod } from '@nimsdk/base'
import { CommonConstants, processV2ErrorForPrint, shownDialog } from '../../../common/CommonConstants'
import { UserModel } from '../../../viewmodel/UserModel'

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
struct HttpProxyPage {
  @State withZone: boolean = true
  @State zone?: string = undefined
  // @State withPath: boolean = true
  @State path?: string = undefined
  @State method?: number = undefined
  @State withHeader: boolean = true
  @State header?: string = undefined
  @State withBody: boolean = true
  @State body?: string = undefined

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }


  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('HttpProxyPage')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('HttpProxyPage')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({
                bottom: $r('app.float.login_more_margin_bottom'),
                top: $r('app.float.login_more_margin_top')
              })
            Row() {
              Toggle({type:ToggleType.Switch, isOn: this.withZone}).onChange((isOn: boolean) => {
                this.withZone = isOn
              })
              Text('zone')
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
              TextInput({ placeholder: 'zone' })
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.zone = value;
                })
              Line().lineStyle()
            }
            Row() {
              // Toggle({type:ToggleType.Switch, isOn: this.withPath}).onChange((isOn: boolean) => {
              //   this.withPath = isOn
              // })
              Text('path')
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
              TextInput({ placeholder: 'path' })
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.path = value;
                })
              Line().lineStyle()
            }
            Row() {
              Text('method')
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
              TextInput({ placeholder: 'method' })
                .type(InputType.Number)
                .inputStyle()
                .onChange((value: string) => {
                  this.method = parseInt(value);
                })
              Line().lineStyle()
            }
            Row() {
              Toggle({type:ToggleType.Switch, isOn: this.withHeader}).onChange((isOn: boolean) => {
                this.withHeader = isOn
              })
              Text('header')
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
              TextInput({ placeholder: 'header' })
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.header = value;
                })
              Line().lineStyle()
            }
            Row() {
              Toggle({type:ToggleType.Switch, isOn: this.withBody}).onChange((isOn: boolean) => {
                this.withBody = isOn
              })
              Text('body')
                .fontSize($r('app.float.page_title_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_text_color'))
              TextInput({ placeholder: 'body' })
                .type(InputType.Normal)
                .inputStyle()
                .onChange((value: string) => {
                  this.body = value;
                })
              Line().lineStyle()
            }
            Button('请求').onClick((event:ClickEvent) => {
              this.httpProxy()
            })

          }
        }
        .backgroundColor($r('app.color.background'))
        .width(CommonConstants.FULL_PARENT)
        .padding({
          left: $r('app.float.page_padding_hor'),
          right: $r('app.float.page_padding_hor'),
          bottom: $r('app.float.login_page_padding_bottom')
        })
      }
      .size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 })
      .title('http服务代理')
      .titleMode(NavigationTitleMode.Mini)
    }
  }



  async httpProxy(): Promise<void> {
    try {
      const passthroughService = this.getUserModel().getNimSdk().passthroughService // Demo启用passthrough模块，passthroughService不为空
      let proxyReq: V2NIMProxyRequest = {
        path: this.path ?? ''
      }
      if (this.withZone) {
        proxyReq.zone = this.zone ?? ''
      }
      if (this.method != undefined && this.method != null) {
        proxyReq.method = this.method
      }
      if (this.withHeader) {
        proxyReq.header = this.header ?? ''
      }
      if (this.withBody) {
        proxyReq.body = this.body ?? ''
      }

      const res = await passthroughService.httpProxy(proxyReq)
      shownDialog(true, JSON.stringify(res, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }
}