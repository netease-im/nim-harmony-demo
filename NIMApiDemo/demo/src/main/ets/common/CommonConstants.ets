/**
 * Common Constants for all features.
 */
import { V2NIMError } from '@nimsdk/base/';
import { camera } from '@kit.CameraKit';
import { Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';

export class CommonConstants {
  /**
   * Permissions.
   */
  static readonly PERMISSIONS: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION', 'ohos.permission.MICROPHONE'];
  static readonly locationRequest: geoLocationManager.CurrentLocationRequest = {
    'priority': geoLocationManager.LocationRequestPriority.ACCURACY,
    'scenario': geoLocationManager.LocationRequestScenario.UNSET,
    'maxAccuracy': 0
  };

  static readonly FONT_WEIGHT_500: number = 500;
  static readonly THOUSANDTH_940: string = '94%'; // ‘90%’
  static readonly THOUSANDTH_1000: string = '100%'; // ‘100%’
  /**
   * The number of columns for SM device.
   */
  static readonly GRID_ROW_SM: number = 4;

  /**
   * The number of columns for MD device.
   */
  static readonly GRID_ROW_MD: number = 8;

  /**
   * The number of columns for LG device.
   */
  static readonly GRID_ROW_LG: number = 12;

  /**
   * The gutter of x direction device.
   */
  static readonly GUTTER_X: number = vp2px(12);

  /**
   * The span of page for SM device.
   */
  static readonly SPAN_SM: number = 4;

  /**
   * The span of page for MD device.
   */
  static readonly SPAN_MD: number = 6;

  /**
   * The span of page for MD device.
   */
  static readonly SPAN_LG: number = 8;

  /**
   * The span of privacy statement for SM device.
   */
  static readonly PRIVACY_SPAN_SM: number = 2;

  /**
   * The span of privacy statement for MD device.
   */
  static readonly PRIVACY_SPAN_MD: number = 4;

  /**
   * The span of privacy statement for LG device.
   */
  static readonly PRIVACY_SPAN_LG: number = 4;

  /**
   * The span of mine page for SM device.
   */
  static readonly MINE_SPAN_SM: number = 4;

  /**
   * The span of mine page for MD device.
   */
  static readonly MINE_SPAN_MD: number = 8;

  /**
   * The span of mine for LG device.
   */
  static readonly MINE_SPAN_LG: number = 8;

  /**
   * The span of login component button for SM device.
   */
  static readonly BUTTON_SPAN_SM: number = 4;

  /**
   * The span of login component button for MD device if break point is smaller than 360vp.
   */
  static readonly BUTTON_SPAN_MD_SMALL: number = 3;

  /**
   * The span of login component button for MD device if break point is not smaller than 360vp.
   */
  static readonly BUTTON_SPAN_MD_BIG: number = 6;

  /**
   * The span of login component button for LG device.
   */
  static readonly BUTTON_SPAN_LG: number = 8;

  /**
   * The offset for SM device.
   */
  static readonly OFFSET_SM: number = 1;

  /**
   * The offset for MD device.
   */
  static readonly OFFSET_MD: number = 1;

  /**
   * The offset for LG device.
   */
  static readonly OFFSET_LG: number = 2;

  /**
   * The offset of privacy statement component for SM device.
   */
  static readonly PRIVACY_OFFSET_SM: number = 1;

  /**
   * The offset of privacy statement component for MD device.
   */
  static readonly PRIVACY_OFFSET_MD: number = 2;

  /**
   * The offset of privacy statement component for LG device.
   */
  static readonly PRIVACY_OFFSET_LG: number = 4;

  /**
   * The offset of login component button for SM device.
   */
  static readonly BUTTON_OFFSET_SM: number = 0;

  /**
   * The offset of login component button for MD device.
   */
  static readonly BUTTON_OFFSET_MD: number = 2;

  /**
   * The offset of login component button for LG device.
   */
  static readonly BUTTON_OFFSET_LG: number = 4;

  /**
   * The break point for page.
   */
  static readonly BREAK_POINT: Array<string> = ['320vp', '600vp', '820vp'];

  /**
   * Login scroll layout weight.
   */
  static readonly LOGIN_SCROLL_LAYOUT_WEIGHT: number = 1;

  /**
   * Registration success page scroll layout weight.
   */
  static readonly SCROLL_LAYOUT_WEIGHT: number = 1;

  /**
   * Mine page column layout weight.
   */
  static readonly COLUMN_LAYOUT_WEIGHT: number = 1;

  /**
   * Mine page list size.
   */
  static readonly LIST_SIZE: number = 2;

  static readonly LABEL_FONT_WEIGHT: number = 400;

  /**
   * Title font weight.
   */
  static readonly TITLE_FONT_WEIGHT: number = 500;

  /**
   * Login text font weight.
   */
  static readonly LOGIN_TEXT_FONT_WEIGHT: number = 500;

  /**
   * Button font weight of registration page.
   */
  static readonly BUTTON_FONT_WEIGHT: number = 500;

  /**
   * Text font weight of registration page.
   */
  static readonly TEXT_FONT_WEIGHT: number = 500;

  /**
   * User nickname text font weight.
   */
  static readonly NICKNAME_FONT_WEIGHT: number = 500;

  static readonly SERVICE_LIST_URL: string = 'pages/ServiceListPage';
  static readonly CUSTOM_NOTIFICATION_SERVICE_URL: string = 'pages/CustomNotificationServicePage';
  static readonly PUSH_SERVICE_URL: string = 'pages/PushServicePage';
  static readonly CONVERSATION_SERVICE_URL: string = 'pages/ConversationServicePage';
  static readonly NOS_SERVICE_URL: string = 'pages/NosServicePage';
  static readonly INITIALIZE_PAGE_URL: string = 'pages/InitializePage';

  /**
   * Mine page url.
   */
  static readonly MINE_PAGE_URL: string = 'pages/mine/MinePage';

  /**
   * Registration success page url.
   */
  static readonly REGISTRATION_SUCCESS_PAGE_URL: string = 'pages/RegistrationSuccessPage';

  /**
   * Privacy page url.
   */
  static readonly PRIVACY_PAGE_URL: string = 'pages/PrivacyPage';

  /**
   * Customer service page url.
   */
  static readonly CUSTOMER_SERVICE_PAGE_URL: string = 'pages/CustomerServicePage';

  /**
   * Percent of the text input.
   */
  static readonly TEXT_INPUT_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of divider width.
   */
  static readonly DIVIDER_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of the button width.
   */
  static readonly BUTTON_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of the flex width.
   */
  static readonly FLEX_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of the login page width.
   */
  static readonly LOGIN_PAGE_WIDTH_PERCENT: string = '100%';

  /**
   * Full percent of the width.
   */
  static readonly FULL_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of the registration success page width.
   */
  static readonly REGISTRATION_PAGE_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of the registration success page height.
   */
  static readonly REGISTRATION_PAGE_HEIGHT_PERCENT: string = '100%';

  /**
   * Percent of text width in mine page.
   */
  static readonly MINE_PAGE_TEXT_WIDTH_PERCENT: string = '50%';

  /**
   * Percent of the mine page width.
   */
  static readonly MINE_PAGE_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of column width in customer service page.
   */
  static readonly CUSTOMER_COLUMN_WIDTH_PERCENT: string = '100%';

  /**
   * Percent of column height in customer service page.
   */
  static readonly CUSTOMER_COLUMN_HEIGHT_PERCENT: string = '100%';

  /**
   * Percent of column height in mine page.
   */
  static readonly MINE_PAGE_HEIGHT_PERCENT: string = '100%';

  /**
   * Percent of the row width.
   */
  static readonly ROW_WIDTH_PERCENT: string = '100%';

  /**
   * Scroll height percentage setting.
   */
  static readonly SCROLL_HEIGHT_PERCENT: string = '100%';

  /**
   * Percent of the column width in detail page.
   */
  static readonly DETAIL_COLUMN_WIDTH_PERCENT: string = '93%';
  /**
   * Input length of the account.
   */
  static readonly INPUT_ACCOUNT_LENGTH = 100;

  /**
   *  Input length of the password.
   */
  static readonly INPUT_PASSWORD_LENGTH = 8;

  /**
   *  Left padding of the input box
   */
  static readonly INPUT_PADDING_LEFT = 0;

  /**
   * Delay time of simulated login
   */
  static readonly LOGIN_DELAY_TIME = 2000;

  /**
   * Common Spacing of Components
   */
  static readonly COMMON_SPACE = 12;

  /**
   * Title text of the home page
   */
  static readonly HOME_TITLE = '首页';

  /**
   * Title text of the setting page
   */
  static readonly MINE_TITLE = '我的';

  /**
   * Spacing of other login methods
   */
  static readonly LOGIN_METHODS_SPACE = 44;

  /**
   * The width or height of the component is spread across the parent component.
   */
  static readonly FULL_PARENT = '100%';

  /**
   * The width of button
   */
  static readonly BUTTON_WIDTH = '90%';

  /**
   * The width of setting list
   */
  static readonly SET_LIST_WIDTH = '42%';

  /**
   * Home tab index
   */
  static readonly HOME_TAB_INDEX = 0;

  /**
   * Mine tab index
   */
  static readonly MINE_TAB_INDEX = 1;

  /**
   * title line number 2.
   */
  static readonly TITLE_LINE_NUMBER: number = 2;
  /**
   * loading duration 2000.
   */
  static readonly LOADING_DURATION: number = 200;
  /**
   * course item padding 12.
   */
  static readonly COURSE_ITEM_PADDING: number = 12;

  /**
   * VIDEO_FRAME.
   */
  static readonly MAX_VIDEO_FRAME: number = 60;
  /**
   * default zoom radio min.
   */
  static readonly ZOOM_RADIO_MIN: number = 1;

  /**
   * default zoom radio max.
   */
  static readonly ZOOM_RADIO_MAX: number = 6;

  /**
   * default zoom radio step.
   */
  static readonly ZOOM_RADIO_MAX_STEP: number = 0.1;
  /**
   * default zoom radio step.
   */
  static readonly ZOOM_RADIO_MIN_STEP: number = 0.01;
  /**
   * AUDIO_BITRATE.
   */
  static readonly AUDIO_BITRATE: number = 48000;

  /**
   * AUDIO_CHANNELS.
   */
  static readonly AUDIO_CHANNELS: number = 2;

  /**
   * AUDIO_SAMPLE_RATE.
   */
  static readonly AUDIO_SAMPLE_RATE: number = 48000;

  /**
   * VIDEO_BITRATE.
   */
  static readonly VIDEO_BITRATE: number = 512000;

  /**
   * Limit picker num
   */
  static readonly LIMIT_PICKER_NUM = 18;

  /**
   * Camera preview width
   */
  static readonly PREVIEW_WIDTH: number = 1920;

  /**
   * Camera preview height
   */
  static readonly PREVIEW_HEIGHT: number = 1080;

  /**
   * Camera photo profile
   */
  static readonly CAMERA_SIZE: camera.Size[] = [{ width: 1920, height: 1080 }, {
    width: 1440,
    height: 1080
  }];

  /**
   * Grid num two
   */
  static readonly GRID_NUM_TWO = "1fr 1fr";

  /**
   * Grid num four
   */
  static readonly GRID_NUM_FOUR = "1fr 1fr 1fr 1fr";

  /**
   * White color
   */
  static readonly WHITE_COLOR = "#FFFFFF";

  /**
   * Black color
   */
  static readonly BLACK_COLOR = "#000000";

  /**
   * Gray color
   */
  static readonly GRAY_COLOR = "#F1F3F5";

  /**
   * Breakpoint sm
   */
  static readonly BREAKPOINT_SM: string = 'sm';

  /**
   * Breakpoint md
   */
  static readonly BREAKPOINT_MD: string = 'md';

  /**
   * Breakpoint lg
   */
  static readonly BREAKPOINT_LG: string = 'lg';

  /**
   * Breakpoint range sm
   */
  static readonly RANGE_SM: string = '(320vp<=width<600vp)';

  /**
   * Breakpoint range md
   */
  static readonly RANGE_MD: string = '(600vp<=width<840vp)';

  /**
   * Breakpoint range lg
   */
  static readonly RANGE_LG: string = '(840vp<=width)';

  /**
   * Breakpoint value sm/md/lg
   */

  static readonly BREAKPOINT_VALUE: Array<string> = ['320vp', '600vp', '840vp'];

  /**
   * Window status
   */
  static readonly WINDOW_STATUS:string = 'status';

  /**
   * Window navigation
   */
  static readonly WINDOW_NAVIGATION:string = 'navigation';

  /**
   * AppStorage key breakpoint
   */
  static readonly BREAKPOINT_NAME: string = 'breakpoint';

  /**
   * AppStorage key title
   */
  static readonly KEY_TITLE: string = 'title';

  /**
   * AppStorage key description
   */
  static readonly KEY_DESCRIPTION: string = 'description';

  /**
   * AppStorage key cloud picture path
   */
  static readonly KEY_PICTURE_PATHS: string = 'paths';

  /**
   * AppStorage key moving picture
   */
  static readonly KEY_MOVING_DATA: string = 'moving_data';

  /**
   * Params key uri
   */
  static readonly KEY_PARAMS_URI: string = 'uri';

  /**
   * Params key data
   */
  static readonly KEY_PARAMS_DATA: string = 'data';

  /**
   * Collaboration insert bufferType
   */
  static readonly BUFFER_TYPE:string = 'general.image';

  /**
   * AppStorage key page change
   */
  static readonly KEY_PAGE_CHANGE: string = 'page_change'
}

export async function shownDialog(result: boolean, message: string): Promise<void> {
  AlertDialog.show(
    {
      title: result? 'Success' : 'Failed',
      message: message,
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      confirm: {
        value: 'OK',
        action: () => {
          console.info('Button-clicking callback')
        }
      },
      cancel: () => {
        console.info('Closed callbacks')
      }
    }
  )
}

export async function shownListenerDialog(title: string, message: string): Promise<void> {
  AlertDialog.show(
    {
      title: title,
      message: message,
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      confirm: {
        value: 'OK',
        action: () => {
          console.info('Button-clicking callback')
        }
      },
      cancel: () => {
        console.info('Closed callbacks')
      }
    } as AlertDialogParamWithConfirm
  )
}

export function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ? JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}