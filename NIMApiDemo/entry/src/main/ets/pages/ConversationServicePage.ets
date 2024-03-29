import {
  V2NIMConversation,
  V2NIMConversationResult,
  V2NIMError,
  V2NIMErrorImpl,
  V2NIMConversationType,
  V2NIMConversationOption,
  V2NIMConversationService,
  V2NIMConversationOperationResult,
  V2NIMConversationUpdate,
  V2NIMConversationFilter
} from '@nimsdk/base';
import { forEach } from '@nimsdk/vendor';
import { CommonConstants } from '../common/constants/CommonConstants';
import { TitleWithBack } from '../view/TitleWithBack';
import { UserModel } from '../viewmodel/UserModel';
import prompt from '@ohos.prompt';

/**
 * Push Center page, register push token here and commit it to NIM service for the delegation of Harmony push.
 */
@Entry
@Component
export default struct ConversationServicePage {
  build() {
    Column() {
      TitleWithBack({ title: "ConversationService" })
      Scroll() {
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
              sm: CommonConstants.MINE_SPAN_SM,
              md: CommonConstants.MINE_SPAN_MD,
              lg: CommonConstants.MINE_SPAN_LG
            },
            offset: {
              lg: CommonConstants.OFFSET_LG
            }
          }) {
            Column() {
              ConversationPageItemComponent()
            }
            .width(CommonConstants.MINE_PAGE_WIDTH_PERCENT)
            .height(CommonConstants.MINE_PAGE_HEIGHT_PERCENT)
          }
        }
        .margin({
          left: $r('app.float.user_grid_row_margin'),
          right: $r('app.float.user_grid_row_margin')
        })
      }
      .margin({ top: $r('app.float.profile_image_margin_top') })
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.login_page_background'))
  }
}


@Component
struct ConversationPageItemComponent {
  private userModel: UserModel | undefined;
  private conversationService: V2NIMConversationService = this.getUserModel().getNimSdk().conversationService! // Demo启用conversation模块，conversationService不为空
  @State loggerText: string = 'Conversation logger:';

  getUserModel(): UserModel {
    if (!this.userModel) {
      this.userModel = UserModel.getInstance(getContext(this).getApplicationContext());
    }

    return this.userModel
  }

  build() {
    Scroll() {
      Column() {
        Button('getConversationList(offset, limit)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetConversationList()
          })

        Button('getConversationListByOption(offset, limit, option)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetConversationListByOption()
          })

        Button('getConversation(conversationId)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetConversation()
          })

        Button('getConversationListByIds(conversationIds)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetConversationListByIds()
          })

        Button('createConversation(conversationId)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doCreateConversation()
          })

        Button('deleteConversation(conversationId, clearMessage?)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doDeleteConversation()
          })

        Button('deleteConversationListByIds(conversationIds, clearMessage?)', {
          type: ButtonType.Normal,
          stateEffect: true
        })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doDeleteConversationListByIds()
          })

        Button('stickTopConversation(conversationId, stickTop)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doStickTopConversation()
          })

        Button('updateConversation(conversationId, updateInfo)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doUpdateConversation()
          })

        Button('updateConversationLocalExtension(conversationId, localExtension)', {
          type: ButtonType.Normal,
          stateEffect: true
        })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doUpdateConversationLocalExtension()
          })

        Button('getTotalUnreadCount()', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetTotalUnreadCount()
          })

        Button('getUnreadCountByIds(conversationIds)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetUnreadCountByIds()
          })

        Button('getUnreadCountByFilter(filter)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doGetUnreadCountByFilter()
          })

        Button('clearTotalUnreadCount()', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doClearTotalUnreadCount()
          })

        Button('clearUnreadCountByIds(conversationIds)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doClearUnreadCountByIds()
          })

        Button('clearUnreadCountByGroupId(groupId)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doClearUnreadCountByGroupId()
          })

        Button('clearUnreadCountByTypes(types)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doClearUnreadCountByTypes()
          })

        Button('subscribeUnreadCountByFilter(filter)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doSubscribeUnreadCountByFilter()
          })

        Button('unsubscribeUnreadCountByFilter(filter)', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.doUnsubscribeUnreadCountByFilter()
          })

        // sdk interface done


        Button('Clear log', { type: ButtonType.Normal, stateEffect: true })
          .width('100%')
          .borderRadius(8)
          .height(40)
          .margin({ top: 5, bottom: 5 })
          .onClick(() => {
            this.loggerText = 'Conversation logger:';
          })

        Text(this.loggerText)
          .textAlign(TextAlign.Start)
          .margin({ top: 5, right: 5, left: 5, bottom: 200 })
          .padding(5)
          .borderRadius(8)
          .width('100%')
          .backgroundColor("#DDDDDD")
      }
    }
  }

  async doGetConversationList(): Promise<void> {
    let offset: number = 0;
    let limit: number = 100;
    let TAG: string = "getConversationList(" + offset + ", " + limit + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let result: V2NIMConversationResult = await this.conversationService.getConversationList(offset, limit)
      this.logV2NIMConversationResult(TAG, result)

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetConversationListByOption(): Promise<void> {
    let offset: number = 0;
    let limit: number = 100;
    let option: V2NIMConversationOption = {
      conversationTypes: [V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P]
    }

    let TAG: string = "getConversationListByOption(" + offset + ", " + limit + ", " + JSON.stringify(option) + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let result: V2NIMConversationResult = await this.conversationService.getConversationListByOption(offset, limit, option)
      this.logV2NIMConversationResult(TAG, result)

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetConversation(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1";
    let TAG: string = "getConversation(" + conversationId + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let conv: V2NIMConversation = await this.conversationService.getConversation(conversationId)
      if (conv) {
        this.logText(TAG, "convId: " + conv.conversationId)
      } else {
        this.logText(TAG, "not found.")
      }

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetConversationListByIds(): Promise<void> {
    let conversationIds: string[] = ["cjl|1|cjl1", "cjl|2|cjl2"];
    let TAG: string = "getConversationListByIds([" + conversationIds + "])";
    try {
      console.info('Button onClick, ' + TAG)

      let result: V2NIMConversation[] = await this.conversationService.getConversationListByIds(conversationIds)
      this.logText(TAG, this.getConversationIds(result))

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doCreateConversation(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1";
    let TAG: string = "createConversation(" + conversationId + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let conv: V2NIMConversation = await this.conversationService.createConversation(conversationId)
      if (conv) {
        this.logText(TAG, conv.conversationId)
      } else {
        this.logText(TAG, "not found.")
      }

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doDeleteConversation(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1";
    let clearMessage: boolean = true;
    let TAG: string = "deleteConversation(" + conversationId + ", " + clearMessage + ")";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.deleteConversation(conversationId, clearMessage)
      this.logText(TAG, "succeed")

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doDeleteConversationListByIds(): Promise<void> {
    let conversationIds: string[] = ["cjl|1|cjl1", "cjl|2|cjl2"];
    let clearMessage: boolean = true;
    let TAG: string = "deleteConversationListByIds([" + conversationIds + "], " + clearMessage + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let deleteFailedConversationList: V2NIMConversationOperationResult[] = await this.conversationService.deleteConversationListByIds(conversationIds, clearMessage)
      if (deleteFailedConversationList && deleteFailedConversationList.length > 0) {
        let failedLogStr = ""
        deleteFailedConversationList.forEach((convOptRes: V2NIMConversationOperationResult) => {
          failedLogStr += convOptRes.conversationId + "failed, reason: " + convOptRes.error + "\n"
        })
        this.logText(TAG, failedLogStr)
      } else {
        this.logText(TAG, "all succeed")
      }

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doStickTopConversation(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1"
    let stickTop: boolean = true;
    let TAG: string = "stickTopConversation(" + conversationId + ", " + stickTop + ")";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.stickTopConversation(conversationId, stickTop)
      this.logText(TAG, "succeed");

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doUpdateConversation(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1"
    let userInfo: V2NIMConversationUpdate = {
      serverExtension: "serverExtension"
    }
    let TAG: string = "updateConversation(" + conversationId + ", " + JSON.stringify(userInfo) + ")";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.updateConversation(conversationId, userInfo)
      this.logText(TAG, "succeed");

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doUpdateConversationLocalExtension(): Promise<void> {
    let conversationId: string = "cjl|1|cjl1"
    let localExtension: string = "localExtension"
    let TAG: string = "updateConversationLocalExtension(" + conversationId + ", " + localExtension + ")";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.updateConversationLocalExtension(conversationId, localExtension)
      this.logText(TAG, "succeed");

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetTotalUnreadCount(): Promise<void> {
    let TAG: string = "getTotalUnreadCount()";
    try {
      console.info('Button onClick, ' + TAG)

      let unreadCount: number = this.conversationService.getTotalUnreadCount()
      this.logText(TAG, "unread count: " + unreadCount)

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetUnreadCountByIds(): Promise<void> {
    let conversationIds: string[] = ["cjl|1|cjl1", "cjl|2|cjl2"];
    let TAG: string = "getUnreadCountByIds([" + conversationIds + "])";
    try {
      console.info('Button onClick, ' + TAG)

      let unreadCount: number = await this.conversationService.getUnreadCountByIds(conversationIds)
      this.logText(TAG, "unread count: " + unreadCount)

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doGetUnreadCountByFilter(): Promise<void> {
    let filter: V2NIMConversationFilter = {
      conversationTypes: [V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P]
    }
    let TAG: string = "getUnreadCountByFilter(" + JSON.stringify(filter) + ")";
    try {
      console.info('Button onClick, ' + TAG)

      let unreadCount: number = await this.conversationService.getUnreadCountByFilter(filter)
      this.logText(TAG, "unread count: " + unreadCount)

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doClearTotalUnreadCount(): Promise<void> {
    let TAG: string = "clearTotalUnreadCount()";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.clearTotalUnreadCount()
      this.logText(TAG, "succeed");

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doClearUnreadCountByIds(): Promise<void> {
    let conversationIds: string[] = ["cjl|1|cjl1", "cjl|2|cjl2"];
    let TAG: string = "clearUnreadCountByIds([" + conversationIds + "])";
    try {
      console.info('Button onClick, ' + TAG)

      let deleteFailedConversationList: V2NIMConversationOperationResult[] = await this.conversationService.clearUnreadCountByIds(conversationIds)

      if (deleteFailedConversationList && deleteFailedConversationList.length > 0) {
        let failedLogStr = ""
        deleteFailedConversationList.forEach((convOptRes: V2NIMConversationOperationResult) => {
          failedLogStr += convOptRes.conversationId + "failed, reason: " + convOptRes.error + "\n"
        })
        this.logText(TAG, failedLogStr)
      } else {
        this.logText(TAG, "all succeed")
      }

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doClearUnreadCountByGroupId(): Promise<void> {
    let groupId: string = "0123456789"
    let TAG: string = "clearUnreadCountByGroupId(" + groupId + ")";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.clearUnreadCountByGroupId(groupId)
      this.logText(TAG, "succeed")

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doClearUnreadCountByTypes(): Promise<void> {
    let conversationTypes:V2NIMConversationType[] = [V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P]
    let TAG: string = "clearUnreadCountByTypes([" + conversationTypes + "])";
    try {
      console.info('Button onClick, ' + TAG)

      await this.conversationService.clearUnreadCountByTypes(conversationTypes)
      this.logText(TAG, "succeed")

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doSubscribeUnreadCountByFilter(): Promise<void> {
    let filter: V2NIMConversationFilter = {
      conversationTypes: [V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P]
    }
    let TAG: string = "subscribeUnreadCountByFilter(" + JSON.stringify(filter) + ")";
    try {
      console.info('Button onClick, ' + TAG)

      this.conversationService.subscribeUnreadCountByFilter(filter)
      this.logText(TAG, "succeed")

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  async doUnsubscribeUnreadCountByFilter(): Promise<void> {
    let filter: V2NIMConversationFilter = {
      conversationTypes: [V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P]
    }
    let TAG: string = "unsubscribeUnreadCountByFilter(" + JSON.stringify(filter) + ")";
    try {
      console.info('Button onClick, ' + TAG)

      this.conversationService.unsubscribeUnreadCountByFilter(filter)
      this.logText(TAG, "succeed")

    } catch (e) {
      this.logV2Error(TAG, e as Error)
    }
  }

  // ============================ SOME UTILS ==============================================

  getConversationIds(convList: V2NIMConversation[]): string {
    let listIds: string = "";
    convList.forEach((conv: V2NIMConversation, idx: number, _) => {
      listIds += conv.conversationId + "\n";
    })
    return listIds;
  }

  logText(TAG: string, log: string): void {
    this.loggerText += "\n------------\n"
      + TAG + "\n" + log;

    prompt.showToast({
      message: TAG + "\n" + log,
      duration: 2000
    });
  }

  logV2Error(TAG: string, e: Error) {
    if (e instanceof V2NIMErrorImpl) {
      this.logText(TAG, " failed, v2 error, code: " + e.code + " desc: " + e.desc + " detail: " + JSON.stringify(e.detail))
    } else {
      this.logText(TAG, " failed, error: " + e)
      throw e
    }
  }

  logV2NIMConversationResult(TAG: string, result: V2NIMConversationResult) {
    let listIds = this.getConversationIds(result.conversationList);

    let resString: string =
      "offset: " + result.offset + "\n"
        + "finished: " + result.finished + "\n"
        + "list size: " + result.conversationList?.length + "\n"
        + "conversation ids: " + listIds

    this.logText(TAG, "V2NIMConversationResult: " + resString);
  }
}