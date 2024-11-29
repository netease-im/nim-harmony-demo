import {
  V2NIMError, V2NIMFriendAddApplication,
  V2NIMFriendAddApplicationStatus,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import CustomDialogWidget from '../../../dialog/CustomDialogWidget';
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
struct DeleteAddApplicationPage {
  @State operatorAccountId: string = ''
  @State postscript: string = ''
  @State status: V2NIMFriendAddApplicationStatus = V2NIMFriendAddApplicationStatus.V2NIM_FRIEND_ADD_APPLICATION_STATUS_INIT
  @State timestamp: number = 0
  @State applicantAccountId: string = ''
  @State recipientAccountId: string = ''
  @State read: boolean = true

  @State isShowProgress: boolean = false;

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

  async deleteAddApplication(): Promise<void> {
    try {
      const friendService = this.getUserModel().getNimSdk().friendService!
      const params = {
        applicantAccountId: this.applicantAccountId,
        recipientAccountId: this.recipientAccountId,
        operatorAccountId: this.operatorAccountId,
        postscript: this.postscript,
        status: this.status,
        timestamp: this.timestamp,
        read: this.read
      } as V2NIMFriendAddApplication

      await friendService.deleteAddApplication(params)
      shownDialog(true, JSON.stringify('success', null, 2))
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
            Text('Delete')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
            Text('delete add application ')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({
              bottom: $r('app.float.login_more_margin_bottom'),
              top: $r('app.float.login_more_margin_top')
            })

            TextInput({ placeholder: '申请者账户id' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.applicantAccountId = value;
            })
            Line().lineStyle()

            TextInput({ placeholder: '被申请人账户id' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.recipientAccountId = value;
            })
            Line().lineStyle()

            TextInput({ placeholder: '操作用户id' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.operatorAccountId = value;
            })
            Line().lineStyle()

            TextInput({ placeholder: 'postscript' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.postscript = value;
            })
            Line().lineStyle()

            TextInput({ placeholder: 'status 1 or 2 or 3' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.status = parseInt(value);
            })
            Line().lineStyle()

            TextInput({ placeholder: 'postscript' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.Normal)
            .inputStyle()
            .onChange((value: string) => {
              this.postscript = value
            })
            Line().lineStyle()

            TextInput({ placeholder: 'timestamp' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.NUMBER_DECIMAL)
            .inputStyle()
            .onChange((value: string) => {
              this.timestamp = parseInt(value)
            })
            Line().lineStyle()
            TextInput({ placeholder: 'read' })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.NUMBER_DECIMAL)
            .inputStyle()
            .onChange((value: string) => {
              this.read = parseInt(value) > 1 ? true : false
            })
            Line().lineStyle()
            Button(('Delete'), { type: ButtonType.Capsule })
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
              this.deleteAddApplication();
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