import { values } from '@nimsdk/vendor'
import { photoPickerGetUri } from '../model/PictureSelect'

@Component
export struct PictureFiles {
  @Link picture: string
  @State flag: boolean = false

  build() {
    Column(){
      Text('选择一张图片从相册')
        .width(302)
        .height(48)
        .lineHeight(22)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(16)
        .fontWeight(500)
        .textAlign(TextAlign.Start)
        .fontColor('#182431')
      Column() {
        if (!this.flag) {
          Image($r('app.media.ic_folder_add2'))
            .width($r('app.float.default_24'))
            .height($r('app.float.default_24'))
            .objectFit(ImageFit.Contain)
        } else {
          Image(this.picture)
            .width('100%')
            .height('100%')
            .borderRadius($r('app.float.default_24'))
        }
      }
      .width(312)
      .height(147)
      .borderRadius(16)
      .backgroundColor($r('app.color.background'))
      .onClick(async () => {
        await photoPickerGetUri().then(value => {
          this.flag = true
          this.picture = value
        })
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .margin({ bottom: $r('app.float.default_10') })
    .backgroundColor($r('app.color.start_window_background'))
    .width(336)
    .height(213)
    .borderRadius($r('app.float.default_24'))
  }
}