/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants as Constants, shownListenerDialog } from '../../common/CommonConstants';
import ClassifyModel from '../../viewmodel/ClassifyModel';
import FunctionalModel from '../../viewmodel/CourseModel';
import CourseItem from '../../view/CourseItem';
import ClassifyItem from '../../view/ClassityItem';
import ClassifyViewModel from '../../viewmodel/ClassifyViewModel';
import router from '@ohos.router';
import { UserModel } from '../../viewmodel/UserModel';
import { V2NIMConversation, V2NIMConversationUnreadCountChangedFilter, V2NIMError } from '@nimsdk/base';

@Entry
@Component
export default struct ConversationPage {
  @State currentClassify: number = 0; // selected classify index.
  @State requestSuccess: boolean = false; // is loading data.
  private classifyList: Array<ClassifyModel> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    // loading data.
    setTimeout(() => {
      this.classifyList = ClassifyViewModel.getConversationLinkData();
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
    const url =  'pages/conversationPages/' + courseItem.module + '/' + pageName
    router.pushUrl({url: url})
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }
  
  addListener() {
    // Demo启用message模块，messageService不为空
    this.getUserModel().getNimSdk().conversationService!.removeAllListeners()

    this.getUserModel().getNimSdk().conversationService!.on("onSyncStarted", () => {
      shownListenerDialog('onSyncStarted', JSON.stringify("", null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onSyncFinished", () => {
      shownListenerDialog('onSyncFinished', JSON.stringify("", null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onSyncFailed", (error: V2NIMError) => {
      shownListenerDialog('onSyncFailed', JSON.stringify(error, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onConversationCreated", (conversation: V2NIMConversation) => {
      shownListenerDialog('onConversationCreated', JSON.stringify(conversation, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onConversationDeleted", (conversationIds: string[]) => {
      shownListenerDialog('onConversationDeleted', JSON.stringify(conversationIds, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onConversationChanged", (conversationList: V2NIMConversation[]) => {
      shownListenerDialog('onConversationChanged', JSON.stringify(conversationList, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onTotalUnreadCountChanged", (unreadCount: number) => {
      shownListenerDialog('onTotalUnreadCountChanged', JSON.stringify(unreadCount, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onUnreadCountChangedByFilter", (filter: V2NIMConversationUnreadCountChangedFilter, unreadCount: number) => {
      shownListenerDialog('onUnreadCountChangedByFilter', JSON.stringify({ filter, unreadCount }, null, 2))
    })

    this.getUserModel().getNimSdk().conversationService!.on("onConversationReadTimeUpdated", (conversationId: string, readTime: number) => {
      shownListenerDialog('onConversationReadTimeUpdated', JSON.stringify({conversationId, readTime}, null, 2))
    })
  }
}