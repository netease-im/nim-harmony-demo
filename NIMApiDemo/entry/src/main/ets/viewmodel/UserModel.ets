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
// import { NIMInitializeOptions, NIMSdk } from 'nim';
import { NIMInterface, NIMInitializeOptions } from 'base';
import { NimRepository } from '../model/NimRepository';
import preferences from '@ohos.data.preferences';
import { NIMServiceOptions } from 'base/Index';

const TAG = '[UserModeL]';
const USER_MODEL = 'userModel';

export class UserModel {
  private nimRepository: NimRepository
  private loginCachePreferences: preferences.Preferences

  constructor(context: common.Context) {
    this.nimRepository = new NimRepository(context)
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
    if (!AppStorage.get<UserModel>(USER_MODEL)) {
      AppStorage.setOrCreate(USER_MODEL, new UserModel(context));
    }
    return AppStorage.get<UserModel>(USER_MODEL) as UserModel;
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