import { abilityAccessCtrl, AbilityConstant, PermissionRequestResult, UIAbility, Want } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { CommonConstants } from '../common/CommonConstants';
import { UserModel } from '../viewmodel/UserModel';

/**
 * Lift cycle management of Ability.
 */
export default class EntryAbility extends UIAbility {
  private isFirstStart: boolean = true

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context,  CommonConstants.PERMISSIONS).then((data: PermissionRequestResult) => {
        console.info('requestPermissionsFromUser' + JSON.stringify(data));
        if (data.authResults[0] !== 0 || data.authResults[1] !== 0) {
          return;
        }

        let windowClass: window.Window | null = null;
        windowStage.getMainWindow((err: BusinessError, data) => {
          let errCode: number = err.code;
          if (errCode) {
            hilog.error(0x0000, 'testTag', 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
            return;
          }
          windowClass = data;
          hilog.info(0x0000, 'testTag', 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

          let type = window.AvoidAreaType.TYPE_SYSTEM;
          let avoidArea = windowClass.getWindowAvoidArea(type);
          let topRectHeight = avoidArea.topRect.height + 200;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        });
        // Main window is created, set main page for this ability
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
        windowStage.loadContent("pages/LoginPage", (err, data) => {
          if (err.code) {
            hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
        });
      }).catch((err: Error) => {
        console.error('requestPermissionsFromUser', 'requestPermissionsFromUser err' + JSON.stringify(err));
      })
    } catch (err) {
      console.error('requestPermissionsFromUser', 'requestPermissionsFromUser err' + JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  // 已废弃主动调用，当前前后台切换由 NIMSDK 负责上报云信服务器
  // onForeground(): void {
  //   // Ability has brought to foreground
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  //   if (this.isFirstStart === false) {
  //     const userModel = UserModel.getInstance(getContext(this)?.getApplicationContext());
  //     userModel.getNimSdk().settingService?.setAppBackground(false, 0)
  //   }
  //
  //   this.isFirstStart = false
  // }
  //
  // onBackground(): void {
  //   // Ability has back to background
  //   hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  //   const userModel = UserModel.getInstance(getContext(this).getApplicationContext());
  //   userModel.getNimSdk().settingService?.setAppBackground(true)
  // }
}