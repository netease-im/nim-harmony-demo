import { CommonConstants } from '../../../common/constants/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';
import { V2NIMBroadcastNotification,
  V2NIMConversationType,
  V2NIMCustomNotification, V2NIMSendCustomNotificationParams } from 'base';
import promptAction from '@ohos.promptAction';

/**
 * Personal Center page, displaying personal information and app-related settings.
 */
@Entry
@Component
struct CustomNotificationServicePage {
  private userModel: UserModel | undefined;
  @State receiverId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State content: string = '';
  // TextInput多行显示存在Bug，暂时使用单行字符串
  @State sendParams: string = '{"notificationConfig":{"offlineEnabled":false,"unreadEnabled":false},"pushConfig":{"pushEnabled":false,"pushNickEnabled":false,"pushContent":"","pushPayload":"","forcePush":false,"forcePushContent":"","forcePushAccounts":[]},"antispamConfig":{"antispamEnabled":false,"antispamCustomNotification":""},"routeConfig":{"routeEnabled":false,"routeEnvironment":""}}';
  // @State sendParams: string = "{\n" +
  // "  \"notificationConfig\": {\n" +
  // "    \"offlineEnabled\": false,\n" +
  // "    \"unreadEnabled\": false\n" +
  // "  },\n" +
  // "  \"pushConfig\": {\n" +
  // "    \"pushEnabled\": false,\n" +
  // "    \"pushNickEnabled\": false,\n" +
  // "    \"pushContent\": \"\",\n" +
  // "    \"pushPayload\": \"\",\n" +
  // "    \"forcePush\": false,\n" +
  // "    \"forcePushContent\": \"\",\n" +
  // "    \"forcePushAccounts\": []\n" +
  // "  },\n" +
  // "  \"antispamConfig\": {\n" +
  // "    \"antispamEnabled\": false,\n" +
  // "    \"antispamCustomNotification\": \"\"\n" +
  // "  },\n" +
  // "  \"routeConfig\": {\n" +
  // "    \"routeEnabled\": false,\n" +
  // "    \"routeEnvironment\": \"\"\n" +
  // "  }\n" +
  // "}";


  @State log: string = '';

  getUserModel(): UserModel {
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          TextInput({ text: this.receiverId, placeholder: '接收者账号' })
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
              this.receiverId = value;
            })

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'p2p', group: 'conversationTypeGroup' }).checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
                }
              })
            Text('p2p')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'team', group: 'conversationTypeGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM
                }
              })
            Text('team')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Radio({ value: 'superTeam', group: 'conversationTypeGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM
                }
              })
            Text('superTeam')
              .fontSize($r('app.float.normal_text_size'))
              .fontColor($r('app.color.login_more_text_color'))
              .lineHeight(20)
              .fontWeight(500)
          }

          TextInput({ text: this.content, placeholder: '发送内容' })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .height($r('app.float.text_input_height'))
            .placeholderColor($r('app.color.text_input_place_holder'))
            .placeholderFont({ size: $r('app.float.text_input_font_size') })
            .fontSize($r('app.float.text_input_font_size'))
            .backgroundColor($r('app.color.login_input_text_background'))
            .padding({ left: $r('app.float.password_padding_left') })
            .border({
              width: { bottom: $r('app.float.input_border_width') },
              color: $r('app.color.input_border_color'),
              radius: $r('app.float.input_border_radius')
            })
            .margin({ bottom: $r('app.float.input_margin_bottom') })
            .onChange((value: string) => {
              this.content = value;
            })
          TextInput({ text: this.sendParams, placeholder: 'V2NIMSendCustomNotificationParams' })
            .width(CommonConstants.TEXT_INPUT_WIDTH_PERCENT)
            .maxLines(Number.MAX_VALUE)
            .enterKeyType(EnterKeyType.Done)
            .placeholderColor($r('app.color.text_input_place_holder'))
            .placeholderFont({ size: $r('app.float.text_input_font_size') })
            .fontSize($r('app.float.text_input_font_size'))
            .backgroundColor($r('app.color.login_input_text_background'))
            .padding({ left: $r('app.float.password_padding_left') })
            .border({
              width: { bottom: $r('app.float.input_border_width') },
              color: $r('app.color.input_border_color'),
              radius: $r('app.float.input_border_radius')
            })
            .margin({ bottom: $r('app.float.input_margin_bottom') })
            .onChange((value: string) => {
              this.sendParams = value;
            })
          Button('发送自定义通知')
            .width(CommonConstants.BUTTON_WIDTH_PERCENT)
            .height($r('app.float.login_btn_height'))
            .borderRadius($r('app.float.login_btn_border_radius'))
            .fontSize($r('app.float.text_input_font_size'))
            .margin({ top: $r('app.float.register_btn_margin_top') })
            .fontWeight(CommonConstants.LOGIN_TEXT_FONT_WEIGHT)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.login_btn_enabled'))
            .onClick(() => {
              this.sendCustomNotification()
            })
          Text(this.log)
        }
        .width(CommonConstants.MINE_PAGE_WIDTH_PERCENT)
        .height(CommonConstants.MINE_PAGE_HEIGHT_PERCENT)
        .margin({
          left: $r('app.float.user_grid_row_margin'),
          right: $r('app.float.user_grid_row_margin')
        })
        .alignItems(HorizontalAlign.Center)
      }
      .padding($r('app.float.login_operation_area_padding'))
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
    }
    .backgroundColor($r('app.color.login_page_background'))
    .title('CustomNotificationService')
    .titleMode(NavigationTitleMode.Mini)
  }

  sendCustomNotification() {
    let sendParams: V2NIMSendCustomNotificationParams | undefined
    try {
      sendParams = JSON.parse(this.sendParams) as V2NIMSendCustomNotificationParams
    } catch (err) {
      promptAction.showToast(
        {
          message: err.message
        }
      )
    }

    // Demo启用notification模块，notificationService不为空
    this.getUserModel()
      .getNimSdk()
      .notificationService!
      .sendCustomNotification(
        this.getConversationId(this.receiverId, this.conversationType),
        this.content,
        sendParams
      )
      .then((result) => {
        this.log = this.log + "\nsendCustomNotification 成功"
        this.log = this.log + '\n'
      })
      .catch((error: Error) => {
        this.log = this.log + '\nsendCustomNotification 失败:' + JSON.stringify(error)
        this.log = this.log + '\n'
      })

    this.getUserModel()
      .getNimSdk()
      .notificationService!
      .on('onReceiveCustomNotifications', (customNotifications: V2NIMCustomNotification[]) => {
        this.log = this.log + '\nonReceiveCustomNotifications:' + customNotifications.length
        customNotifications.map(customNotification => this.log = this.log + '\n' + JSON.stringify(customNotification));
        this.log = this.log + '\n'
      })

    this.getUserModel()
      .getNimSdk()
      .notificationService!
      .on('onReceiveBroadcastNotifications', (broadcastNotifications: V2NIMBroadcastNotification[]) => {
        this.log = this.log + '\nonReceiveBroadcastNotifications:' + broadcastNotifications.length
        broadcastNotifications.map(broadcastNotification => this.log = this.log + '\n' + JSON.stringify(broadcastNotification));
        this.log = this.log + '\n'
      })
  }

  getConversationId(receiverId: string, conversationType: V2NIMConversationType): string {
    let conversationId = receiverId
    switch (conversationType) {
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.p2pConversationId(conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.teamConversationId(conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.superTeamConversationId(conversationId)
        break
    }

    return conversationId
  }
}