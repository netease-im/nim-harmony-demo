

import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../../common/Constants';

const TAG = '[HttpPerformancePage]';

const STRING_DNS = 'dns';
const STRING_TCP = 'tcp';
const STRING_TLS = 'tls';
const STRING_FIRSTSEND = 'firstSend';
const STRING_FIRSTRECEIVE = 'firstReceive';
const STRING_TOTALFINISH = 'totalFinish';
const STRING_REDIRECT = 'redirect';
const STRING_RESPONSEHEADER = 'responseHeader';
const STRING_RESPONSEBODY = 'responseBody';
const STRING_TOTAL = 'total';

@Entry
@Component
struct HttpPerformancePage {
  @State inputUrl: string = 'https://weblink.netease.im:443';
  @State result: string = '';
  @State timing: http.PerformanceTiming | null = null;
  @State requestTitle: string = "start"

  controller: TextAreaController = new TextAreaController();

  requestHttp(url: string, method: http.RequestMethod): Promise<string> {
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp();
      httpRequest.on('headersReceive', (header) => {
        hilog.info(0x0000, TAG, `url=${url} is error ${JSON.stringify(header)}}`);
      });

      httpRequest.request(
        url,
        {
          expectDataType: http.HttpDataType.STRING,
          method: method,
          header: {
            'content-type': 'multipart/form-data',
          },
          extraData: {},
          usingCache: false,
          priority: 1,
          connectTimeout: 10000,
          readTimeout: 10000,
        }, (err, data) => {
        hilog.info(0x0000, TAG, `------------ requestUrl: ${JSON.stringify(url)}----------`);
        if (!err) {
          this.result =
            `---------- connect Result : ----------
          responseCode:${JSON.stringify(data.responseCode)}
          header:${JSON.stringify(data.header)}
          cookies:${JSON.stringify(data.cookies)}
          -------------------------------------------`;
          hilog.info(0x0000, TAG, `Result:${JSON.stringify(data.result)}`);
          hilog.info(0x0000, TAG, `responseCode:${JSON.stringify(data.responseCode)}`);
          hilog.info(0x0000, TAG, `header:${JSON.stringify(data.header)}`);
          hilog.info(0x0000, TAG, `cookies:${JSON.stringify(data.cookies)}`);

          this.timing = data.performanceTiming;
          this.requestTitle = "success"
          resolve(JSON.stringify(data.result));
        } else {
          this.requestTitle = "failed"
          this.result = `url=${url} is error ${JSON.stringify(err)}}`;
          hilog.info(0x0000, TAG, `url=${url} is error ${JSON.stringify(err)}}`);
          httpRequest.off('headersReceive');
          reject(JSON.stringify(err));
        }
      })
    });
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.index_title'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.title_font_size'))
          .width(Constants.FULL_PERCENT)
          .fontColor($r('app.color.text_color'))
      }
      .width(Constants.INDEX_CONTENT_WIDTH)
      .height(Constants.INDEX_TITLE_HEIGHT)

      Scroll() {
        Column() {
          Text($r('app.string.test_url'))
            .margin({ left: $r('app.float.index_margin_left') })
            .fontWeight(FontWeight.Medium)
          TextArea({ text: this.inputUrl, controller: this.controller })
            .height($r('app.float.input_height'))
            .onChange((value: string) => {
              this.inputUrl = value;
            })
            .margin({
              left: $r('app.float.index_margin_left'),
              right: $r('app.float.index_margin_right'),
              top: $r('app.float.index_margin_top')
            })
          Button($r('app.string.request'))
            .width($r('app.float.button_width'))
            .alignSelf(ItemAlign.Center)
            .margin({ top: $r('app.float.index_margin_top') })
            .onClick(() => {
              this.requestHttp(this.inputUrl, http.RequestMethod.GET);
            })

          Text(this.requestTitle)
            .margin({
              left: $r('app.float.index_margin_left'),
              right: $r('app.float.index_margin_right'),
              top: $r('app.float.index_margin_top')
            })
            .fontWeight(FontWeight.Medium)

          Column() {
            Row() {
              Text($r('app.string.stage_name')).layoutWeight(1)
              Text($r('app.string.stage_time'))
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_DNS).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.dnsTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.start_window_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_TCP).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.tcpTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_TLS).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.tlsTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.start_window_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_FIRSTSEND).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.firstSendTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_FIRSTRECEIVE).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.firstReceiveTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.start_window_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_TOTALFINISH).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.totalFinishTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_REDIRECT).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.redirectTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.start_window_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_RESPONSEHEADER).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.responseHeaderTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_RESPONSEBODY).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.responseBodyTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.start_window_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))

            Row() {
              Text(STRING_TOTAL).layoutWeight(1)
              if (this.timing) {
                Text('' + this.timing?.totalTiming)
              }
            }
            .padding($r('app.float.item_padding'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor($r('app.color.list_item_background'))
            .width(Constants.FULL_WIDTH)
            .height($r('app.float.item_height'))
          }
          .margin({
            left: $r('app.float.index_margin_left'),
            right: $r('app.float.index_margin_right'),
            top: $r('app.float.index_margin_top')
          })
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_WIDTH)
      }
      .layoutWeight(1)
      .width(Constants.FULL_WIDTH)
      .margin({ bottom: $r('app.float.index_margin_bottom') })
    }
  }
}