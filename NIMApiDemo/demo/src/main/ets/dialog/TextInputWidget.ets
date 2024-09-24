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
export default struct TextInputWidget {
  private inputImage?: Resource;
  private hintText?: Resource;

  build() {
    Row() {
      Image(this.inputImage !== undefined ? this.inputImage : '')
        .width($r('app.float.input_image_size'))
        .height($r('app.float.input_image_size'))
        .margin({ left: $r('app.float.input_image_left') })
      TextInput({ placeholder: this.hintText })
        .fontSize($r('app.float.input_text_size'))
        .padding({ left: $r('app.float.input_left_inside') })
        .placeholderColor($r('app.color.place_color'))
        .backgroundColor(Color.White)
        .fontWeight(FontWeight.Normal)
        .fontStyle(FontStyle.Normal)
        .fontColor(Color.Black)
        .margin({ right: $r('app.float.input_right_inside') })
        .layoutWeight(CommonConstants.WEIGHT_ONE)
        .height($r('app.float.text_input_height'))
    }
    .margin({ top: $r('app.float.input_row_top') })
    .borderRadius($r('app.float.input_row_radius'))
    .backgroundColor(Color.White)
    .width(CommonConstants.COMMON_DIALOG_WIDTH)
    .height($r('app.float.input_row_height'))
  }
}