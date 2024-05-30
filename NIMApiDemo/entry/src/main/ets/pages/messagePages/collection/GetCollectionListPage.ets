import {
  V2NIMCollection,
  V2NIMCollectionOption,
  V2NIMError,
  V2NIMQueryDirection,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/constants/CommonConstants';
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
struct GetCollectionListPage {
  @State beginTime: number = 0
  @State endTime: number = 0
  @State limit: number = 0

  @State directionType: boolean = true

  private anchorCollection?: V2NIMCollection
  private collectionType?: number
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
  async getCollectionListByOption(): Promise<void> {
    console.info(`----------getCollectionListByOption-------- \n`)
    try {
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const params :V2NIMCollectionOption = {
        beginTime: this.beginTime,
        endTime: this.endTime,
        direction: this.directionType ? V2NIMQueryDirection.V2NIM_QUERY_DIRECTION_DESC : V2NIMQueryDirection
          .V2NIM_QUERY_DIRECTION_ASC,
        limit: this.limit,
        collectionType: this.collectionType
      }

      const res = await messageService.getCollectionListByOption(params)
      console.info(`-----------getCollectionListByOption成功----------- ${res}`)
      shownDialog(true, JSON.stringify(res, null, 2))
    }
    catch (err) {
      console.error(`-----------getCollectionListByOption失败---------- \n`, `${err}`)
      shownDialog(false, processV2ErrorForPrint(err))
      return
    }
  }
  aboutToAppear(): void {

  }

  aboutToDisappear() {
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('GetCollectionList')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('get collection list')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })
          TextInput({ placeholder: 'beginTime' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.beginTime = parseInt(value)
            })
          Line().lineStyle()
          TextInput({ placeholder: 'endTime'})
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.endTime = parseInt(value)
            })
          Line().lineStyle()
          TextInput({  placeholder: 'direction' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.directionType = Boolean(value)
            })
          Line().lineStyle()
          TextInput({  placeholder: 'limit' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.limit = parseInt(value)
            })
          Line().lineStyle()
          TextInput({ placeholder: `collectionType` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.collectionType = parseInt(value)
            })

          Line().lineStyle()

          // Button(('anchor'), { type: ButtonType.Capsule })
          //   .width(CommonConstants.BUTTON_WIDTH)
          //   .height($r('app.float.login_button_height'))
          //   .fontSize($r('app.float.normal_text_size'))
          //   .fontWeight(FontWeight.Medium)
          //   .backgroundColor($r('app.color.login_button_color'))
          //   .margin({ top: $r('app.float.login_button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
          //   .onClick(() => {
          //     this.addCollection();
          //   })

          Button(('get'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.login_button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.getCollectionListByOption();
            })
          Blank()

        }
        .backgroundColor($r('app.color.background'))
        .height(CommonConstants.FULL_PARENT)
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

  // async addCollection(): Promise<void> {
  //   if (this.collectionData === '') {
  //     prompt.showToast({
  //       message: $r('app.string.input_empty_tips')
  //     })
  //   } else {
  //     try {
  //       console.info(`-----------add消息----------- \n`)
  //       // let conversationId: string = 'cjl64|1|cjl1'
  //       let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
  //
  //       let params: V2NIMAddCollectionParams = {
  //         collectionType: this.collectionType,
  //         collectionData: this.collectionData,
  //         serverExtension: this.serverExtension
  //       }
  //
  //       this.collection = await messageService.addCollection(params)
  //       shownDialog(true, JSON.stringify(this.collection, null, 2))
  //     } catch (error) {
  //       console.log('----------- add失败 -----------', error)
  //       shownDialog(false, processV2ErrorForPrint(error))
  //     }
  //   }
  // }
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