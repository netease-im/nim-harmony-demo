import Logger from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';

export class DataUtils {
  static readonly tag: string = 'DataUtils';
  static context: Context;

  static fromResToNumber(resource: Resource): number {
    let num = 0;
    if (resource === undefined) {
      Logger.error(DataUtils.tag, 'fromResToNumber resource is undefined!');
      return num;
    }
    try {
      num = DataUtils.context.resourceManager.getNumber(resource.id);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      Logger.info(DataUtils.tag, `fromResToNumber failed, error code: ${code}, message: ${message}.`);
    }
    return num;
  }

  static fromResToString(resource: Resource): string {
    let str = '';
    if (resource === undefined) {
      Logger.error(DataUtils.tag, 'fromResToString resource is undefined!');
      return str;
    }
    try {
      str = DataUtils.context.resourceManager.getStringSync(resource.id);
      Logger.info(DataUtils.tag, `fromResToString str: ${str}.`);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      Logger.info(DataUtils.tag, `fromResToString failed, error code: ${code}, message: ${message}.`);
    }
    return str;
  }
}