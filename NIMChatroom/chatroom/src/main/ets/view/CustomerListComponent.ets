//import { CommonConstants } from '../constants/CommonConstants';
//import { DataItem } from '../viewmodel/DataItem';
//import LoginPageViewModel from '../viewmodel/LoginViewModel';
//
///**
// * Customer service page component.
// */
//@Component
//export struct CustomerListComponent {
//  build() {
//    Column() {
//      List() {
//        ForEach(LoginPageViewModel.getContactListItems(), (contactItemInfo: DataItem) => {
//          ListItem() {
//            Row() {
//              Text(contactItemInfo.title)
//                .fontSize($r('app.float.name_text_size'))
//                .fontColor($r('app.color.text'))
//              Blank()
//              Text(contactItemInfo.summary)
//                .fontSize($r('app.float.app_info_sub_title_size'))
//                .fontColor($r('app.color.text_opacity'))
//            }
//            .width(CommonConstants.ROW_WIDTH_PERCENT)
//            .height($r('app.float.list_height'))
//          }
//        }, (contactItemInfo: DataItem, index?: number) => index + JSON.stringify(contactItemInfo));
//      }
//      .divider({
//        strokeWidth: $r('app.float.divider_stroke_width'),
//        color: $r('app.color.divider')
//      })
//    }
//    .width(CommonConstants.DETAIL_COLUMN_WIDTH_PERCENT)
//    .padding({
//      top: $r('app.float.list_padding_top'),
//      bottom: $r('app.float.list_padding_bottom'),
//      left: $r('app.float.list_padding_left'),
//      right: $r('app.float.list_padding_right')
//    })
//    .margin({ top: $r('app.float.name_text_padding_top') })
//    .backgroundColor($r('app.color.start_window_background'))
//    .borderRadius($r('app.float.detail_list_radius'))
//  }
//}