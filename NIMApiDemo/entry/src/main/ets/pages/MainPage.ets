import { CommonConstants } from '../common/constants/CommonConstants'
import MessagePage from './messagePages/MessagePage'
import ConversationPage from './conversationPages/ConversationPage'
import ServiceListPage from './ServiceListPage'
import MinePage from '../pages/mine/MinePage'
import { NavList, TabId } from '../model/NavItemModel'
import TeamPage from './teamPages/TeamPage'
import SignallingPage from './signallingPages/SignallingPage'

@Styles function allSize() {
  .width(CommonConstants.THOUSANDTH_1000)
  .height(CommonConstants.THOUSANDTH_1000)
}

@Entry
@Component
struct MainPage {
  private tabController: TabsController = new TabsController()
  @State currentPage: number = 0

  build() {
    Tabs({barPosition: BarPosition.End, controller: this.tabController}) {
      // TabContent() {
      //   ServiceListPage()
      //     .borderWidth({ bottom: 1 })
      //     .borderColor($r('app.color.primaryBgColor'))
      // }
      // .tabBar(this.TabBuilder(TabId.HOME))
      // .align(Alignment.Start)

      TabContent() {
        ConversationPage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }

      .tabBar(this.TabBuilder(TabId.CONVERSATION))
      TabContent() {
        MessagePage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.MESSAGE))

      TabContent() {
        TeamPage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.TEAM))
      TabContent() {
        SignallingPage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.SIGNALING))

      TabContent() {
        MinePage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.MINE))
    }
    .scrollable(false)
    .allSize()
    .barWidth(CommonConstants.THOUSANDTH_940)
    .barMode(BarMode.Fixed)
    .vertical(false)
    .onChange((index) => {
      this.currentPage = index;
    })
  }

  @Builder TabBuilder(index: number) {
    Column() {
      Image(index === this.currentPage ? NavList[index].icon_selected : NavList[index].icon)
        .width($r('app.float.default_24'))
        .height($r('app.float.default_24'))
        .objectFit(ImageFit.Contain);
      Text(NavList[index].text)
        .fontSize($r('app.float.default_10'))
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .fontColor(this.currentPage === index ? $r('app.color.blueColor') : $r('app.color.tabTitleColor'))
        .margin({ top: $r('app.float.default_4') })
    }.justifyContent(FlexAlign.Center).allSize()
  }
}