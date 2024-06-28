/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { window } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { CommonConstants } from '../common/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

export class UIUtils {
  static readonly tag: string = 'UIUtils';

  static setWindowBackGroundColor(context: Context, color: string) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowBackgroundColor(color);
    });
  }

  static setWindowFullScreen(context: Context, isFull: boolean) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowLayoutFullScreen(isFull);
    });
  }

  static setWindowSystemBarVisible(context: Context, names: string[]) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowSystemBarEnable(names as ('status' | 'navigation')[], (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          Logger.error(UIUtils.tag, `Failed to set the system bar to be visible. Cause: ${errCode}`);
          return;
        }
      });
    });
  }

  /**
   * show system picker view
   *
   * @param callback
   */
  static showPickerView(callback: Function, selectedType: picker.PhotoViewMIMETypes, selectedNumber: number) {
    const photoSelectOptions = new picker.PhotoSelectOptions();
    photoSelectOptions.MIMEType = selectedType;
    photoSelectOptions.maxSelectNumber = selectedNumber
    photoSelectOptions.maxSelectNumber = CommonConstants.LIMIT_PICKER_NUM;
    const photoViewPicker = new picker.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then(async (photoSelectResult: picker.PhotoSelectResult) => {
      let uriArr = photoSelectResult.photoUris;
      callback(uriArr);
    }).catch((err: BusinessError) => {
      Logger.error(UIUtils.tag,
        `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    });
  }
}