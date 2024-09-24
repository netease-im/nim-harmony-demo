/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CommonConstants from '../common/CommonConstants';

@Component
export default struct TextCommonWidget {
  @Link content: string;
  private textImage?: Resource;
  private title?: Resource;
  onItemClick = () => {};

  build() {
    Row() {
      Image(this.textImage !== undefined ? this.textImage : '')
        .width($r('app.float.text_image_size'))
        .height($r('app.float.text_image_size'))
        .margin({ left: $r('app.float.image_left_distance') })
      Text(this.title)
        .fontSize($r('app.float.text_size'))
        .margin({ left: $r('app.float.image_left_distance') })
        .height(CommonConstants.FULL_HEIGHT)
      Text(this.content)
        .fontSize($r('app.float.text_size'))
        .textAlign(TextAlign.End)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(CommonConstants.ONE_LINES)
        .margin({
          left: $r('app.float.content_left_distance'),
          right: $r('app.float.content_right_distance')
        })
        .layoutWeight(CommonConstants.WEIGHT_ONE)
        .width(CommonConstants.FULL_WIDTH)
      Image($r('app.media.ic_arrow'))
        .width($r('app.float.arrow_image_width'))
        .height($r('app.float.arrow_image_height'))
        .margin({ right: $r('app.float.arrow_right_distance') })
    }
    .margin({ top: $r('app.float.row_top_distance') })
    .borderRadius($r('app.float.row_radius'))
    .backgroundColor(Color.White)
    .width(CommonConstants.COMMON_DIALOG_WIDTH)
    .height($r('app.float.row_height'))
    .onClick(this.onItemClick)
  }
}