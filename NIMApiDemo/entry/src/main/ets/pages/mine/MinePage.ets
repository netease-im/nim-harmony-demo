import {CommonConstants as Constants, shownListenerDialog} from '../../common/constants/CommonConstants';
import ClassifyModel from '../../message/viewmodel/ClassifyModel';
import FunctionalModel from '../../message/viewmodel/CourseModel';
import CourseItem from '../../message/view/CourseItem';
import ClassifyItem from '../../message/view/ClassityItem';
import ClassifyViewModel from '../../message/viewmodel/ClassifyViewModel';
import router from '@ohos.router';
import { UserModel } from '../../viewmodel/UserModel';
import { V2NIMFriend, V2NIMFriendAddApplication,
  V2NIMFriendAddRejection,
  V2NIMFriendDeletionType, V2NIMUser } from '@nimsdk/base';

@Entry
@Component
export default struct MinePage {
  @State currentClassify: number = 0; // selected classify index.
  @State requestSuccess: boolean = false; // is loading data.
  private classifyList: Array<ClassifyModel> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  private userModel: UserModel | undefined;

  aboutToAppear() {
    // loading data.
    setTimeout(() => {
      this.classifyList = ClassifyViewModel.getMineLinkData();
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
    const url =  'pages/mine/' + courseItem.module + '/' + pageName
    router.pushUrl({url: url})
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  addListener() {
    // Demo启用user模块，userService不为空
    this.getUserModel().getNimSdk().userService!.on("onUserProfileChanged", (users: V2NIMUser[]) => {
      shownListenerDialog('onUserProfileChanged', JSON.stringify(users, null, 2))
    })

    this.getUserModel().getNimSdk().userService!.on("onBlockListAdded", (user: V2NIMUser) => {
      shownListenerDialog('onBlockListAdded', JSON.stringify(user, null, 2))
    })

    this.getUserModel().getNimSdk().userService!.on("onBlockListRemoved", (accountId: string) => {
      shownListenerDialog('onBlockListRemoved', JSON.stringify(accountId, null, 2))
    })

    // Demo启用friend模块，friendService不为空
    this.getUserModel().getNimSdk().friendService!.on("onFriendAdded", (friend: V2NIMFriend) => {
      shownListenerDialog('onFriendAdded', JSON.stringify(friend, null, 2))
    })

    this.getUserModel().getNimSdk().friendService!.on("onFriendDeleted", (accountId: string, deletionType: V2NIMFriendDeletionType) => {
      shownListenerDialog('onFriendDeleted', JSON.stringify(`${accountId} + ${deletionType}`, null, 2))
    })

    this.getUserModel().getNimSdk().friendService!.on("onFriendAddApplication", (application: V2NIMFriendAddApplication) => {
      shownListenerDialog('onFriendAddApplication', JSON.stringify(application, null, 2))
    })

    this.getUserModel().getNimSdk().friendService!.on("onFriendAddRejected", (rejection: V2NIMFriendAddRejection) => {
      shownListenerDialog('onFriendAddRejected', JSON.stringify(rejection, null, 2))
    })

    this.getUserModel().getNimSdk().friendService!.on("onFriendInfoChanged", (friend: V2NIMFriend) => {
      shownListenerDialog('onFriendInfoChanged', JSON.stringify(friend, null, 2))
    })
  }
}