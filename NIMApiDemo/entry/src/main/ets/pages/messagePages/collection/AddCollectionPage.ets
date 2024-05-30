import prompt from '@ohos.promptAction';
import { V2NIMAddCollectionParams, V2NIMError, V2NIMMessage, V2NIMSendMessageResult } from '@nimsdk/base';
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
struct AddCollectionPage {
  @State collectionType: number = 0;
  @State collectionData: string = '';
  @State serverExtension: string = '';

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

  async addCollection(): Promise<void> {
    if (this.collectionData === '') {
      prompt.showToast({
        message: $r('app.string.input_empty_tips')
      })
    } else {
      try {
        console.info(`-----------addCollection ----------- \n`)
        // let conversationId: string = 'cjl64|1|cjl1'
        let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空

        let params: V2NIMAddCollectionParams = {
          collectionType: this.collectionType,
          collectionData: this.collectionData,
          serverExtension: this.serverExtension
        }
        messageService.addCollection(params)
        const collection = await messageService.addCollection(params)
        shownDialog(true, JSON.stringify(collection, null, 2))
      } catch (error) {
        console.log('----------- addCollection 失败 -----------', error)
        shownDialog(false, processV2ErrorForPrint(error))
      }
    }
  }
  aboutToAppear(): void {
    this.collectionType = 32
    this.collectionData = 'collectionData'
    this.serverExtension = 'serverExtension123'
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          Text('AddCollection')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('add collection method')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })
          TextInput({ placeholder: $r('app.string.collection_type') })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Number)
            .inputStyle()
            .onChange((value: string) => {
              this.collectionType = parseInt(value)
            })
          Line().lineStyle()
          TextInput({ text: this.collectionData, placeholder: $r('app.string.collection_data') })
            .maxLength(100)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.collectionData = value;
            })
          Line().lineStyle()
          TextInput({ placeholder: `server extension ` })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.serverExtension = value;
            })

          Line().lineStyle()

          Button(('add'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.login_button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.addCollection();
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