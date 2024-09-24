import { Constants } from '../../../common/Constants'
import { wifiManager } from '@kit.ConnectivityKit'
import Logger from '../../../utils/Logger'

enum ClickActionEnum {
  KEY_GET_SIGNAL_LEVEL = 'getSignalLevel',
  KEY_GET_LINKED_INFO = 'getLinkedInfo',
  KEY_IS_CONNECTED = 'isConnected',
  KEY_GET_IP_INFO = 'getIpInfo',
  KEY_GET_IPV6_INFO = 'getIpv6Info',
  KEY_GET_COUNTRY_CODE = 'getCountryCode',
  KEY_IS_BAND_TYPE_SUPPORTED = 'isBandTypeSupported',
  KEY_IS_METERED_HOTSPOT = 'isMeteredHotspot',
}

@Entry
@Component
struct WifiManagerTestPage {
  static TAG = "WifiManagerTestPage"
  @State
  resultText: string = ""

  @State
  private items: Array<string> = [
    ClickActionEnum.KEY_GET_SIGNAL_LEVEL, // 查询WLAN信号强度
    ClickActionEnum.KEY_GET_LINKED_INFO, // 获取WLAN连接信息
    ClickActionEnum.KEY_IS_CONNECTED, // 查询WLAN是否已连接
    ClickActionEnum.KEY_GET_IP_INFO, // 获取IP信息
    ClickActionEnum.KEY_GET_IPV6_INFO, // 获取IPV6信息
    ClickActionEnum.KEY_GET_COUNTRY_CODE, // 获取IPV6信息
    ClickActionEnum.KEY_IS_BAND_TYPE_SUPPORTED, // 获取IPV6信息
    ClickActionEnum.KEY_IS_METERED_HOTSPOT, // 获取IPV6信息
  ]

  build() {
    Column() {
      Text($r('app.string.wifi_manager'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.title_font_size'))
        .fontColor($r('app.color.text_color'))
        .textAlign(TextAlign.Center)
        .alignSelf(ItemAlign.Center)
        .height(Constants.INDEX_TITLE_HEIGHT)
      Text(this.resultText)
        .width(Constants.FULL_WIDTH)
      List({ initialIndex: 0 }) {
        ForEach(this.items, (item: ClickActionEnum) => {
          ListItem() {
            Button(item.valueOf())
              .width('61.8%')
              .fontSize(16)
              .margin(5)
              .alignSelf(ItemAlign.Center)
              .onClick(async (event) => {
                this.performOnClick(item)
              })
          }.width(Constants.FULL_WIDTH)
        }, (item: ClickActionEnum) => item.valueOf())
      }.width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
      .margin({ top: 12 })
    }
  }

  private performOnClick(key: ClickActionEnum) {
    let actionResult = ''
    switch (key) {
    case ClickActionEnum.KEY_GET_SIGNAL_LEVEL:
      let signalLevel = wifiManager.getSignalLevel(0, 0)
      actionResult = "signalLevel = " + signalLevel
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_GET_LINKED_INFO:
      wifiManager.getLinkedInfo().then((linkedInfo: wifiManager.WifiLinkedInfo) => {
        actionResult = "linkedInfo = " + JSON.stringify(linkedInfo)
        this.resultText = actionResult
        Logger.info(WifiManagerTestPage.TAG, actionResult)
        return linkedInfo
      }).catch((err: Error) => {
        actionResult = key + " failed: " + err
        this.resultText = actionResult
        Logger.info(WifiManagerTestPage.TAG, actionResult)
        return undefined
      })
      break
    case ClickActionEnum.KEY_IS_CONNECTED:
      let connected = wifiManager.isConnected()
      actionResult = "connected = " + connected
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_GET_IP_INFO:
      let ipInfo: wifiManager.IpInfo = wifiManager.getIpInfo()
      actionResult = "ipInfo = " + JSON.stringify(ipInfo)
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_GET_IPV6_INFO:
      let ipv6Info: wifiManager.Ipv6Info = wifiManager.getIpv6Info()
      actionResult = "ipv6Info = " + JSON.stringify(ipv6Info)
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_GET_COUNTRY_CODE:
      let countryCode: string = wifiManager.getCountryCode()
      actionResult = "countryCode = " + countryCode
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_IS_BAND_TYPE_SUPPORTED:
      let supportBandType2G: boolean = wifiManager.isBandTypeSupported(wifiManager.WifiBandType.WIFI_BAND_2G)
      let supportBandType5G: boolean = wifiManager.isBandTypeSupported(wifiManager.WifiBandType.WIFI_BAND_5G)
      let supportBandType6G: boolean = wifiManager.isBandTypeSupported(wifiManager.WifiBandType.WIFI_BAND_6G)
      let supportBandType60G: boolean = wifiManager.isBandTypeSupported(wifiManager.WifiBandType.WIFI_BAND_60G)
      let supportBandType: Record<string, boolean> = {
        '2G': supportBandType2G,
        '5G': supportBandType5G,
        '6G': supportBandType6G,
        '60G': supportBandType60G,
      }
      actionResult = "isBandTypeSupported = " + JSON.stringify(supportBandType)
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    case ClickActionEnum.KEY_IS_METERED_HOTSPOT:
      let isMeteredHotspot: boolean = wifiManager.isMeteredHotspot()
      actionResult = "isMeteredHotspot = " + isMeteredHotspot
      this.resultText = actionResult
      Logger.info(WifiManagerTestPage.TAG, actionResult)
      break
    }
  }
}