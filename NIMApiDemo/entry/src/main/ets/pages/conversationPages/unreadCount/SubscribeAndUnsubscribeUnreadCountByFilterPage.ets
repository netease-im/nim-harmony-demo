import { V2NIMConversationFilter, V2NIMConversationType, V2NIMError,
} from '@nimsdk/base';
import { CommonConstants, shownDialog } from '../../../common/constants/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';
import { HashSet } from '@kit.ArkTS';

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
struct SubscribeAndUnsubscribeUnreadCountByFilterPage {
  @State conversationTypes: HashSet<V2NIMConversationType> | undefined = undefined
  @State enableGroupId: boolean = false
  @State conversationGroupId: string = ''
  @State ignoreMuted: boolean | undefined = undefined
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
  async subscribeUnreadCountByFilter(on: boolean): Promise<void> {
    console.info(`----------查询所有未读数 By Filter--------- \n`)
    try {
      // get service
      let conversationService = this.getUserModel().getNimSdk().conversationService! // Demo启用conversation模块，conversationService不为空

      // input
      const filter: V2NIMConversationFilter = {
        conversationTypes: this.conversationTypes ? Array.from(this.conversationTypes) : undefined,
        conversationGroupId: this.enableGroupId ? this.conversationGroupId : undefined,
        ignoreMuted: this.ignoreMuted
      }

      // call interface
      const res = undefined
      if (on) {
        // on
        conversationService.subscribeUnreadCountByFilter(filter)
      } else {
        // off
        conversationService.unsubscribeUnreadCountByFilter(filter)
      }
      console.info(`-----------${on ? 'subscribe' : 'unsubscribe'} 未读数过滤器成功----------- ${res}`)
      shownDialog(true, JSON.stringify(res, null, 2))
    }
    catch (err) {
      console.error(`-----------${on ? 'subscribe' : 'unsubscribe'} 未读数过滤器失败---------- \n`, `${err}`)
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
          Text('SubscribeAndUnsubscribeUnreadCountByFilter')
            .fontSize($r('app.float.page_title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))
          Text('subscribe unread count by filter method')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })
          Text('unsubscribe unread count by filter method')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .margin({ bottom: $r('app.float.login_more_margin_bottom'), top: $r('app.float.login_more_margin_top') })

          // conversation types
          Line().lineStyle()
          Text('conversation types')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .textAlign(TextAlign.Start)
            .width('100%')
          // 全选按钮
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            CheckboxGroup({ group: 'checkboxGroupConversationType' })
              .selectedColor('#007DFF')
              .onChange((itemName: CheckboxGroupResult) => {
                console.info("checkbox group content" + JSON.stringify(itemName))
              })
            Text('全选')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          // 选项1
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'P2P', group: 'checkboxGroupConversationType' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('P2P change is' + on)
                if (typeof this.conversationTypes === 'undefined')
                  this.conversationTypes = new HashSet()
                if (on) {
                  this.conversationTypes.add(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P)
                } else {
                  this.conversationTypes.remove(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P)
                }
              })
            Text('P2P')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }.margin({ left: 36 })

          // 选项2
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'Team', group: 'checkboxGroupConversationType' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('Team change is' + on)
                if (typeof this.conversationTypes === 'undefined')
                  this.conversationTypes = new HashSet()
                if (on) {
                  this.conversationTypes.add(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM)
                } else {
                  this.conversationTypes.remove(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM)
                }
              })
            Text('Team')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }.margin({ left: 36 })

          // 选项3
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'Super team', group: 'checkboxGroupConversationType' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('Super team change is' + on)
                if (typeof this.conversationTypes === 'undefined')
                  this.conversationTypes = new HashSet()
                if (on) {
                  this.conversationTypes.add(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM)
                } else {
                  this.conversationTypes.remove(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM)
                }
              })
            Text('Super team')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }.margin({ left: 36 })

          // 选项4
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'Unknown', group: 'checkboxGroupConversationType' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('Unknown change is' + on)
                if (typeof this.conversationTypes === 'undefined')
                  this.conversationTypes = new HashSet()
                if (on) {
                  this.conversationTypes.add(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_UNKNOWN)
                } else {
                  this.conversationTypes.remove(V2NIMConversationType.V2NIM_CONVERSATION_TYPE_UNKNOWN)
                }
              })
            Text('Unknown')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }.margin({ left: 36 })
          Line().lineStyle()

          // 会话分组
          Text('conversation group id')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .textAlign(TextAlign.Start)
            .width('100%')
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'enable group id' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('enable group id change is' + on)
                this.enableGroupId = on
              })
            Text('enable group id')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }
          TextInput({ placeholder: 'group id, like: 123' })
            .type(InputType.Normal)
            .inputStyle()
            .margin({ top: 0 })
            .onChange((value: string) => {
              this.conversationGroupId = value
            })
          Line().lineStyle()

          // ignoreMuted?
          Text('ignoreMuted')
            .fontSize($r('app.float.normal_text_size'))
            .fontColor($r('app.color.login_more_text_color'))
            .textAlign(TextAlign.Start)
            .width('100%')
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Checkbox({ name: 'ignoreMuted' })
              .selectedColor('#007DFF')
              // .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((on: boolean) => {
                console.info('onlyUnread change is' + on)
                this.ignoreMuted = on
              })
            Text('check')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }
          Line().lineStyle()

          Button(('subscribe'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ top: $r('app.float.login_button_margin_top'), bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.subscribeUnreadCountByFilter(true);
            })
          Button(('unsubscribe'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.login_button_color'))
            .margin({ bottom: $r('app.float.login_button_margin_bottom') })
            .onClick(() => {
              this.subscribeUnreadCountByFilter(false);
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