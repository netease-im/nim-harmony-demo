
import {CommonConstants as Constants, shownDialog, shownListenerDialog} from '../../common/CommonConstants';
import ClassifyModel from '../../viewmodel/ClassifyModel';
import FunctionalModel from '../../viewmodel/CourseModel';
import CourseItem from '../../view/CourseItem';
import ClassifyItem from '../../view/ClassityItem';
import ClassifyViewModel from '../../viewmodel/ClassifyViewModel';
import router from '@ohos.router';
import { UserModel } from '../../viewmodel/UserModel';
import {
  V2NIMClearHistoryNotification,
  V2NIMCustomNotification,
  V2NIMDownloadAttachmentType,
  V2NIMDownloadMessageAttachmentParams,
  V2NIMMessage,
  V2NIMMessageDeletedNotification,
  V2NIMMessagePinNotification,
  V2NIMMessageQuickCommentNotification,
  V2NIMMessageRevokeNotification,
  V2NIMP2PMessageReadReceipt, V2NIMTeamMessageReadReceipt } from '@nimsdk/base';
import NotificationOperations from '../../notification/NotificationOperations';

@Entry
@Component
export default struct MessagePage {
  @State currentClassify: number = 0; // selected classify index.
  @State requestSuccess: boolean = false; // is loading data.
  private classifyList: Array<ClassifyModel> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  private userModel: UserModel | undefined;

  private notificationOperations: NotificationOperations = new NotificationOperations(getContext(this));

  aboutToAppear() {
    // loading data.
    setTimeout(() => {
      this.classifyList = ClassifyViewModel.getLinkData();
      this.requestSuccess = true;
    }, Constants.LOADING_DURATION);
    this.addListener()
  }



  @Builder ClassifyHeader(classifyName: string) {
    Row() {
      Text(classifyName)
        .fontSize($r('app.float.header_font_size'))
        .fontColor($r('app.color.base_font_color'))
        .fontFamily($r('app.string.hei_ti_medium'))
        .fontWeight(Constants.TITLE_FONT_WEIGHT)
    }
    .padding({ left: $r('app.float.item_padding_left') })
    .height($r('app.float.classify_item_height'))
    .width(Constants.FULL_WIDTH_PERCENT)
    .backgroundColor($r('app.color.background'))
  }

  classifyChangeAction(index: number, isClassify: boolean) {
    if (this.currentClassify !== index) {
      // change the classify status.
      this.currentClassify = index;
      if (isClassify) {
        // scroll the course scroll.
        this.scroller.scrollToIndex(index);
      } else {
        // scroll the classify scroll.
        this.classifyScroller.scrollToIndex(index);
      }
    }
  }

  build() {
    Row() {
      if (this.requestSuccess) {
        List({ scroller: this.classifyScroller }) {
          ForEach(this.classifyList, (item: ClassifyModel, index?: number) => {
            ListItem() {
              ClassifyItem({
                classifyName: item.classifyName,
                isSelected: this.currentClassify === index,
                onClickAction: () => {
                  if (index !== undefined) {
                    this.classifyChangeAction(index, true);
                  }
                }
              })
            }
          }, (item: ClassifyModel) => item.classifyName + this.currentClassify)
        }
        .height(Constants.FULL_PARENT)
        .width($r('app.float.classify_item_width'))
        .backgroundColor($r('app.color.classify_background'))
        .scrollBar(BarState.Off)

        List({ scroller: this.scroller }) {
          ForEach(this.classifyList, (classifyItem: ClassifyModel) => {
            ListItemGroup({
              header: this.ClassifyHeader(classifyItem.classifyName),
              space: Constants.COURSE_ITEM_PADDING
            }) {
              ForEach(classifyItem.courseList, (courseItem: FunctionalModel) => {
                ListItem() {
                  CourseItem({ itemStr: JSON.stringify(courseItem) })
                }.onClick( event => {
                  console.info(`${courseItem}`)
                  this.apiFunction(courseItem)
                })
              }, (courseItem: FunctionalModel) => `${courseItem.courseId}`)
            }
          }, (item: ClassifyModel) => `${item.classifyId}`)
        }
        .padding({ left: $r('app.float.item_padding_left'), right: $r('app.float.course_item_padding') })
        .sticky(StickyStyle.Header)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
        .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
      } else {
        Text($r('app.string.loading'))
          .fontFamily($r('app.string.hei_ti_medium'))
          .textAlign(TextAlign.Center)
          .height(Constants.FULL_PARENT)
          .width(Constants.FULL_PARENT)
      }
    }
    .backgroundColor($r('app.color.background'))
  }

  apiFunction(courseItem: FunctionalModel){
    let pageName: string = courseItem.methodName.charAt(0).toUpperCase() + courseItem.methodName.slice(1) + 'Page'
    const url =  'pages/messagePages/' + courseItem.module + '/' + pageName
    router.pushUrl({url: url})
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  addListener() {
  //  // Demo启用message模块，messageService不为空

    this.getUserModel().getNimSdk().messageService!.removeAllListeners()

  //  this.getUserModel().getNimSdk().messageService!.on("onSendMessage", (message: V2NIMMessage) => {
  //    shownListenerDialog('onSendMessage', JSON.stringify(message, null, 2))
  //  })
  //
    this.getUserModel().getNimSdk().messageService!.on("onReceiveMessages", (messages: V2NIMMessage[]) => {
      messages.map(async message => {
        const title: string = message.senderId;
        const text: string = message.text ?? '无内容';
        this.notificationOperations.publishBasicNotification(title, text);
        const catchDir = getContext(this).getApplicationContext().cacheDir
        let fileDir = catchDir + '/nim';
        //if (!fs.accessSync(fileDir)) {
        //  fs.mkdirSync(fileDir);
        //}

        //const randomNum = getRandomNumber(0, 100);

        //const filePath = fileDir + `/${randomNum}.${mediaType}`
        let storageService = this.getUserModel().getNimSdk().storageService! // Demo启用message模块，messageService不为空
        const downloadParams: V2NIMDownloadMessageAttachmentParams = {
          attachment: message.attachment,
          type: V2NIMDownloadAttachmentType.V2NIM_DOWNLOAD_ATTACHMENT_TYPE_THUMBNAIL
        } as V2NIMDownloadMessageAttachmentParams
        const path = await storageService.downloadAttachment(downloadParams, (percent) => {
          console.log(`downloadFile percent: ${percent}`)
        })
        console.log('messageUrl', path)
        shownDialog(true, JSON.stringify(path, null, 2))
      })

      console.info('onReceiveMessages', JSON.stringify(messages, null, 2))
      shownDialog(true, JSON.stringify(JSON.stringify(messages, null, 2)))
    })

      this.getUserModel().getNimSdk().messageService!.on("onReceiveCustomNotifications", (customNotifications: V2NIMCustomNotification[]) => {
        shownListenerDialog('onReceiveCustomNotifications', JSON.stringify(customNotifications, null, 2))
      })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onReceiveP2PMessageReadReceipts", (readReceipts: V2NIMP2PMessageReadReceipt[]) => {
  //    shownListenerDialog('onReceiveP2PMessageReadReceipts', JSON.stringify(readReceipts, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onReceiveTeamMessageReadReceipts", (readReceipts: V2NIMTeamMessageReadReceipt[]) => {
  //    shownListenerDialog('onReceiveTeamMessageReadReceipts', JSON.stringify(readReceipts, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onMessageRevokeNotifications", (message: V2NIMMessageRevokeNotification[]) => {
  //    shownListenerDialog('onMessageRevokeNotifications', JSON.stringify(message, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onMessageDeletedNotifications", (notification: V2NIMMessageDeletedNotification[]) => {
  //    shownListenerDialog('onMessageDeletedNotifications', JSON.stringify(notification, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onClearHistoryNotifications", (notification: V2NIMClearHistoryNotification[]) => {
  //    shownListenerDialog('onClearHistoryNotifications', JSON.stringify(notification, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onMessagePinNotification", (notification:  V2NIMMessagePinNotification) => {
  //    shownListenerDialog('onMessagePinNotification', JSON.stringify(notification, null, 2))
  //  })
  //
  //  this.getUserModel().getNimSdk().messageService!.on("onMessageQuickCommentNotification", (notification:  V2NIMMessageQuickCommentNotification) => {
  //    shownListenerDialog('onMessageQuickCommentNotification', JSON.stringify(notification, null, 2))
  //  })
  //
  }
}