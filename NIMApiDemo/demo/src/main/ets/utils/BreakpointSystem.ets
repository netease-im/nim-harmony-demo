
import mediaQuery from '@ohos.mediaquery';
import { CommonConstants } from '../common/CommonConstants';
import Logger from './Logger';

declare interface BreakPointTypeOption<T> {
  sm?: T,
  md?: T,
  lg?: T,
  xl?: T,
  xxl?: T
}

export class BreakpointType<T> {
  options: BreakPointTypeOption<T>;

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option;
  }

  getValue(currentPoint: string): T {
    switch (currentPoint) {
      case CommonConstants.BREAKPOINT_SM:
        return this.options.sm as T;
      case CommonConstants.BREAKPOINT_MD:
        return this.options.md as T;
      case CommonConstants.BREAKPOINT_LG:
        return this.options.lg as T;
      default:
        return this.options.sm as T;
    }
  }
}

export class BreakpointSystem {
  private readonly listener_key = 'change';
  private readonly tag: string = 'BreakpointSystem';
  private currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  private smListener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_SM);
  private mdListener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_MD);
  private lgListener: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_LG);

  private updateCurrentBreakpoint(breakpoint: string): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      Logger.info(this.tag, `updateCurrentBreakpoint: ${this.currentBreakpoint}`);
      AppStorage.setOrCreate(CommonConstants.BREAKPOINT_NAME, this.currentBreakpoint);
    }
  }

  private isBreakpointSM = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_SM);
    }
  }
  private isBreakpointMD = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_MD);
    }
  }
  private isBreakpointLG = (mediaQueryResult: mediaQuery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(CommonConstants.BREAKPOINT_LG);
    }
  }

  public register(): void {
    this.smListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_SM);
    this.smListener.on(this.listener_key, this.isBreakpointSM);
    this.mdListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_MD);
    this.mdListener.on(this.listener_key, this.isBreakpointMD);
    this.lgListener = mediaQuery.matchMediaSync(CommonConstants.RANGE_LG);
    this.lgListener.on(this.listener_key, this.isBreakpointLG);
  }

  public unregister(): void {
    this.smListener.off(this.listener_key, this.isBreakpointSM);
    this.mdListener.off(this.listener_key, this.isBreakpointMD);
    this.lgListener.off(this.listener_key, this.isBreakpointLG);
  }
}