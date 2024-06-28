import LoginPageViewModel from '../viewmodel/LoginViewMode';
import { CommonConstants } from '../common/CommonConstants';
import type { ListItemData } from '../common/bean/ListItemData';

/**
 * Personal page component.
 */
@Component
export default struct MinePageContentComponent {
  build() {
    Column() {
      List() {
        ForEach(LoginPageViewModel.getPersonalListItems(), (item: ListItemData) => {
          ListItem() {
            MinePageItemComponent({ itemTitle: item.title })
          }
        }, (item: ListItemData, index) => index + JSON.stringify(item))
      }
      .divider({
        strokeWidth: $r('app.float.divider_stroke_width'),
        color: $r('app.color.item_divider')
      })
    }
    .backgroundColor(Color.White)
    .margin({ top: $r('app.float.mine_content_column_margin_top') })
    .border({
      radius: $r('app.float.mine_content_column_border')
    })
    .padding({
      left: $r('app.float.mine_content_column_padding_left'),
      top: $r('app.float.mine_content_column_padding_top'),
      right: $r('app.float.mine_content_column_padding_right'),
      bottom: $r('app.float.mine_content_column_padding_top')
    })
  }
}

@Component
struct MinePageItemComponent {
  private itemTitle: Resource = {} as Resource

  build() {
    Row() {
      Text(this.itemTitle)
        .width(CommonConstants.MINE_PAGE_TEXT_WIDTH_PERCENT)
        .height($r('app.float.item_text_height'))
        .fontSize($r('app.float.item_text_font_size'))
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
      Button('Ok', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
        .height(40)
        .onClick(()=>{
          console.info('Button onClick')
        })
    }
  }
}