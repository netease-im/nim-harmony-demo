import { mediaquery } from '@kit.ArkUI';

/**
 * Media query listener.
 */
class MediaQueryUtil {
  private listener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync(`(height <= 360vp)`);

  /**
   * Method for media query to trigger execution.
   *
   * @param mediaQueryResult Media query result.
   */
  private onPortrait = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    AppStorage.set<boolean>('isMinHeight', mediaQueryResult.matches);
  }

  /**
   * Register listener.
   */
  public register(): void {
    let portraitFunc = this.onPortrait;
    this.listener.on('change', portraitFunc);
  }

  /**
   * Deregister Listener.
   */
  public unRegister(): void {
    let portraitFunc = this.onPortrait;
    this.listener.off('change', portraitFunc);
  }
}

let mediaQueryUtil = new MediaQueryUtil();

export default mediaQueryUtil as MediaQueryUtil;