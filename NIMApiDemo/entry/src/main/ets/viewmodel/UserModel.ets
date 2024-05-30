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

import common from '@ohos.app.ability.common';
import { NIMInterface, NIMInitializeOptions } from '@nimsdk/base';
import { NimRepository } from '../model/NimRepository';
import preferences from '@ohos.data.preferences';
import { NIMServiceOptions } from '@nimsdk/base';

export enum USER_MODEL_LIST {
  REL = 'userModel',
  TEST = 'userModel-test'
}
export class UserModel {
  public static USER_MODEL: USER_MODEL_LIST = USER_MODEL_LIST.REL

  private nimRepository: NimRepository
  private loginCachePreferences: preferences.Preferences

  constructor(context: common.Context, test?: boolean) {
    this.nimRepository = new NimRepository(context, test)
    this.nimRepository.nim.loginService.on('onKickedOffline', detail => {
      console.log("onKickedOffline:" + JSON.stringify(detail))
      this.saveLastLoginAccount("")
    })
    this.loginCachePreferences = preferences.getPreferencesSync(context, {'name': 'loginCache'})
  }

  /**
   * Get user model instance.
   *
   * @returns discover model instance.
   */
  public static getInstance(context: common.Context): UserModel {
    if (!AppStorage.get<UserModel>(UserModel.USER_MODEL)) {
      switch (UserModel.USER_MODEL) {
        case USER_MODEL_LIST.TEST:
          AppStorage.setOrCreate(UserModel.USER_MODEL, new UserModel(context, true));
          break
        default:
          AppStorage.setOrCreate(UserModel.USER_MODEL, new UserModel(context));
          break
      }
    }
    return AppStorage.get<UserModel>(UserModel.USER_MODEL) as UserModel;
  }

  public initNim(initializeOptions: NIMInitializeOptions, serviceOptions?: NIMServiceOptions) {
    this.nimRepository.initNim(initializeOptions, serviceOptions);
  }

  public getNimSdk(): NIMInterface {
    return this.nimRepository.nim;
  }

  public async loadLastLoginAccount() {
    return this.loginCachePreferences.get("lastAccid", "")
  }

  async saveLastLoginAccount(accid: string) {
    this.loginCachePreferences.put("lastAccid", accid)
    this.loginCachePreferences.flush()
  }


}