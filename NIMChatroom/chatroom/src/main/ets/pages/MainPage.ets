import { CommonConstants } from '../constants/CommonConstants'
import { NavList, TabId } from '../model/NavItemModel'
import { ChatroomClientPage } from './ChatroomClientPage'
import { ChatroomInstancePage } from './ChatroomInstancePage'

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
        ChatroomClientPage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.CLIENT))

      TabContent() {
        ChatroomInstancePage()
          .borderWidth({ bottom: 1 })
          .borderColor($r('app.color.primaryBgColor'))
      }
      .tabBar(this.TabBuilder(TabId.INSTANCE))

      // TabContent() {
      //   TeamPage()
      //     .borderWidth({ bottom: 1 })
      //     .borderColor($r('app.color.primaryBgColor'))
      // }
      // .tabBar(this.TabBuilder(TabId.TEAM))

      // TabContent() {
      //   MinePage()
      //     .borderWidth({ bottom: 1 })
      //     .borderColor($r('app.color.primaryBgColor'))
      // }
      // .tabBar(this.TabBuilder(TabId.MINE))
    }
    .scrollable(false)
    .barWidth(CommonConstants.THOUSANDTH_940)
    .barMode(BarMode.Fixed)
    .vertical(false)
    .onChange((index: number) => {
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
    }.justifyContent(FlexAlign.Center)
  }
}