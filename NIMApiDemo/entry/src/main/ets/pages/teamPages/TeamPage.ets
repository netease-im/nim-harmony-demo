
import {CommonConstants as Constants, shownListenerDialog} from '../../common/constants/CommonConstants';
import ClassifyModel from '../../message/viewmodel/ClassifyModel';
import FunctionalModel from '../../message/viewmodel/CourseModel';
import CourseItem from '../../message/view/CourseItem';
import ClassifyItem from '../../message/view/ClassityItem';
import ClassifyViewModel from '../../message/viewmodel/ClassifyViewModel';
import router from '@ohos.router';
import { UserModel } from '../../viewmodel/UserModel';
import { V2NIMTeam, V2NIMTeamJoinActionInfo, V2NIMTeamMember } from '@nimsdk/base';

@Entry
@Component
export default struct TeamPage {
  @State currentClassify: number = 0; // selected classify index.
  @State requestSuccess: boolean = false; // is loading data.
  private classifyList: Array<ClassifyModel> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  private userModel: UserModel | undefined;

  aboutToAppear() {
    // loading data.
    setTimeout(() => {
      this.classifyList = ClassifyViewModel.getTeamLinkData();
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
    const url =  'pages/teamPages/' + courseItem.module + '/' + pageName
    router.pushUrl({url: url})
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  addListener() {
    // Demo启用team模块，teamService不为空
    this.getUserModel().getNimSdk().teamService!.on("onSyncStarted", () => {
      shownListenerDialog('onSyncStarted', JSON.stringify('start sync', null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onSyncFinished", () => {
      shownListenerDialog('onSyncFinished', JSON.stringify('sync finished', null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onSyncFailed", () => {
      shownListenerDialog('onSyncFailed', JSON.stringify('sync failed', null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamCreated", (team: V2NIMTeam) => {
      shownListenerDialog('onTeamCreated', JSON.stringify(team, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamDismissed", (team: V2NIMTeam) => {
      shownListenerDialog('onTeamDismissed', JSON.stringify(team, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamJoined", (team: V2NIMTeam) => {
      shownListenerDialog('onTeamJoined', JSON.stringify(team, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamLeft", (team: V2NIMTeam, isKicked: boolean) => {
      shownListenerDialog('onTeamLeft', JSON.stringify(team, null, 2) + `isKicked: ${isKicked}`)
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamInfoUpdated", (team: V2NIMTeam) => {
      shownListenerDialog('onTeamInfoUpdated', JSON.stringify(team, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamMemberJoined", (teamMembers: V2NIMTeamMember[]) => {
      shownListenerDialog('onTeamMemberJoined', JSON.stringify(teamMembers, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamMemberKicked", (operateAccountId: string, teamMembers: V2NIMTeamMember[]) => {
        shownListenerDialog('onTeamMemberKicked', `${operateAccountId}` + JSON.stringify(teamMembers, null, 2))
      })

    this.getUserModel().getNimSdk().teamService!.on("onTeamMemberLeft", (teamMembers: V2NIMTeamMember[]) => {
      shownListenerDialog('onTeamMemberLeft', JSON.stringify(teamMembers, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onTeamMemberInfoUpdated", (teamMembers: V2NIMTeamMember[]) => {
      shownListenerDialog('onTeamMemberInfoUpdated', JSON.stringify(teamMembers, null, 2))
    })

    this.getUserModel().getNimSdk().teamService!.on("onReceiveTeamJoinActionInfo", (joinActionInfo: V2NIMTeamJoinActionInfo) => {
        shownListenerDialog('onReceiveTeamJoinActionInfo', JSON.stringify(joinActionInfo, null, 2))
      })
  }
}