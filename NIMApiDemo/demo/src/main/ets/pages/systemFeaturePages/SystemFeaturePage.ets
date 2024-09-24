import { Constants } from '../../common/Constants'
import router from '@ohos.router'

@Entry
@Component
struct SystemFeaturePage {
  @State
  private items: Array<string> = [
    "WIFI Manager",
  ]

  private routerReflect: Record<string, string> = {
    "WIFI Manager": "pages/systemFeaturePages/wifiManager/WifiManagerTestPage",
  }

  build() {
    Column() {
      Text($r('app.string.system_feature'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.title_font_size'))
        .fontColor($r('app.color.text_color'))
        .textAlign(TextAlign.Center)
        .alignSelf(ItemAlign.Center)
        .height(Constants.INDEX_TITLE_HEIGHT)

      List({ initialIndex: 0 }) {
        ForEach(this.items, (item: string) => {
          ListItem() {
            Button(item)
              .width('61.8%')
              .fontSize(16)
              .margin(5)
              .alignSelf(ItemAlign.Center)
              .onClick(async (event) => {
                router.pushUrl({
                  url: this.routerReflect[item],
                  params: item
                });
              })
          }.width(Constants.FULL_WIDTH)
        }, (item: string) => item)
      }.width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
      .margin({ top: 12 })
    }
  }
}