import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static instance: GlobalContext;
  private _objects = new Map<string, Object>();
  private cameraSettingContext: common.UIAbilityContext | undefined = undefined;
  public static get(): GlobalContext {
    if (!Boolean(GlobalContext.instance).valueOf()) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getT<T>(value: string): T {
    return this._objects.get(value) as T;
  }

  setObject(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }

  apply(value: string): void {
    const func = this._objects.get(value);
    if (func) {
      (func as Function)();
    }
  }

  public setCameraSettingContext(context: common.UIAbilityContext): void {
    this.cameraSettingContext = context;
  }

  public getCameraSettingContext(): common.UIAbilityContext | undefined {
    return this.cameraSettingContext;
  }
}