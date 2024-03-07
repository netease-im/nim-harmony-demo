import mediaQuery from '@ohos.mediaquery';

/**
 * Media query listener.
 */
class MediaQueryModel {
  private listener = mediaQuery.matchMediaSync(`(height <= 360vp)`);

  /**
   * Method for media query to trigger execution.
   *
   * @param mediaQueryResult Media query result.
   */
  private onPortrait(mediaQueryResult: mediaQuery.MediaQueryResult): void {
    AppStorage.Set<boolean>('isMinHeight', mediaQueryResult.matches);
  }

  /**
   * Register listener.
   */
  public register(): void {
    // let portraitFunc = this.onPortrait.bind(this);
    // this.listener.on('change', portraitFunc);
  }

  /**
   * Deregister Listener.
   */
  public unRegister(): void {
    // let portraitFunc = this.onPortrait.bind(this);
    // this.listener.off('change', portraitFunc);
  }
}

let mediaQueryModel = new MediaQueryModel();

export default mediaQueryModel as MediaQueryModel;