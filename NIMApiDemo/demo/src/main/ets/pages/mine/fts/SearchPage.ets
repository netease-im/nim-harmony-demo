import {
  V2NIMError,
  V2NIMMessageSearchExParams,
  V2NIMMessageSearchResult,
  V2NIMMessageService,
  V2NIMMessageType,
  V2NIMSearchKeywordMathType,
} from '@nimsdk/base';

import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';

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
struct SearchPage {
  @State params: V2NIMMessageSearchExParams = {
    conversationId: this.getUserModel().getNimSdk().loginService.getLoginUser() + '|1|cjl1',
    keywordList: ['周', '杰', '伦'],
    keywordMatchType: undefined,
    senderAccountIds: ['cjl1', 'cjl2'],
    messageTypes: [],
    searchStartTime: new Date().getTime(),
    searchTimePeriod: 7 * 24 * 60 * 60 * 1000, // 7 day
    limit: 1,
    pageToken: undefined
  }

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

  async callApi(): Promise<void> {
    try {
      console.info(`-----------search----------- \n`)
      let messageService: V2NIMMessageService =
        this.getUserModel().getNimSdk().messageService! // Demo 启用 searchService 模块，searchService 不为空
      const messageResult: V2NIMMessageSearchResult = await messageService.searchLocalMessages(this.params)
      this.params.pageToken = messageResult.nextPageToken
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  aboutToAppear() {
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('Search')
              .fontSize($r('app.float.page_title_text_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.title_text_color'))
            Text('search message by keyword')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

            TextInput({ text: this.params.conversationId, placeholder: 'conversation id' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                if (value === '') {
                  this.params.conversationId = undefined
                } else {
                  this.params.conversationId = value
                }
              })
            Line().lineStyle()

            TextInput({ text: this.params.keywordList?.toString(), placeholder: `search message by this keyword ` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.keywordList = value.split(',')
              })

            Line().lineStyle()


            Text('match type')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .textAlign(TextAlign.Start)
              .width('100%')
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'or', group: 'matchGroup' }).checked(true)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.params.keywordMatchType = V2NIMSearchKeywordMathType.V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR
                  }
                })
              Text('OR')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'and', group: 'matchGroup' })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.params.keywordMatchType = V2NIMSearchKeywordMathType.V2NIM_SEARCH_KEYWORD_MATH_TYPE_AND
                  }
                })
              Text('AND')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .lineHeight(20)
                .fontWeight(500)
            }

            Line().lineStyle()


            TextInput({ text: this.params.senderAccountIds?.toString(), placeholder: `senders` })
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.senderAccountIds = value.split(',')
              })

            Line().lineStyle()

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'TextMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_TEXT)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_TEXT
                    })
                  }
                })
              Text('include text message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'ImageMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_IMAGE)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_IMAGE
                    })
                  }
                })
              Text('include image message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'AudioMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_AUDIO)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_AUDIO
                    })
                  }
                })
              Text('include audio message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'VideoMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_VIDEO)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_VIDEO
                    })
                  }
                })
              Text('include video message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'LocationMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_LOCATION)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_LOCATION
                    })
                  }
                })
              Text('include location message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'NotificationMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION
                    })
                  }
                })
              Text('include notification message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'NotificationMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION
                    })
                  }
                })
              Text('include notification message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: 'FileMessage' })
                .selectedColor('#007DFF')
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .onChange((on: boolean) => {
                  if (on) {
                    this.params.messageTypes?.push(V2NIMMessageType.V2NIM_MESSAGE_TYPE_FILE)
                  } else {
                    this.params.messageTypes = this.params.messageTypes?.filter(i => {
                      i !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_FILE
                    })
                  }
                })
              Text('include file message')
                .fontSize($r('app.float.normal_text_size'))
                .fontColor($r('app.color.login_more_text_color'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            Line().lineStyle()


            TextInput({ text: this.params.searchStartTime?.toString(), placeholder: 'searchStartTime' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.searchStartTime = (Number.isNaN(Number.parseInt(value))) ? 0 : Number.parseInt(value)
              })
            Line().lineStyle()

            TextInput({ text: this.params.searchTimePeriod?.toString(), placeholder: 'searchTimePeriod' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.searchTimePeriod = (Number.isNaN(Number.parseInt(value))) ? 0 : Number.parseInt(value)
              })
            Line().lineStyle()

            TextInput({ text: this.params.limit?.toString(), placeholder: 'limit' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.limit = (Number.isNaN(Number.parseInt(value))) ? 0 : Number.parseInt(value)
              })
            Line().lineStyle()

            TextInput({ text: this.params.pageToken, placeholder: 'page token' })
              .type(InputType.Normal)
              .inputStyle()
              .onChange((value: string) => {
                this.params.pageToken = (value === '') ? undefined : value
              })
            Line().lineStyle()

            Button(('search message'), { type: ButtonType.Capsule })
              .width(CommonConstants.BUTTON_WIDTH)
              .height($r('app.float.login_button_height'))
              .fontSize($r('app.float.normal_text_size'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('app.color.login_button_color'))
              .margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              })
              .onClick(() => {
                this.callApi()
              })
            Blank()
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
      }
      .size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 })
      .title('back')
      .titleMode(NavigationTitleMode.Mini)
    }.height(CommonConstants.THOUSANDTH_1000)
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
