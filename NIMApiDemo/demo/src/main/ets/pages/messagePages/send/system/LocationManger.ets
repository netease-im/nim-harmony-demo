import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

export class LocationManger {
  //request: geoLocationManager.SingleLocationRequest

  constructor() {
    //this.request = {
    //  'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
    //  'locatingTimeoutMs': 10000
    //}
  }

  public async getLocation(): Promise<geoLocationManager.Location> {
    try {
      const result = await geoLocationManager.getCurrentLocation() as geoLocationManager.Location
// 调用getCurrentLocation获取当前设备位置，通过promise接收上报的位置
      console.log('current location: ' + JSON.stringify(result))
      return result
    } catch (err) {
      console.error("errCode:" + JSON.stringify(err));
      throw err as Error
    }
  }

  public async getAddress(location: geoLocationManager.Location): Promise<string> {
    try {
      const result = await geoLocationManager.getAddressesFromLocation({
        longitude: location.longitude,
        latitude: location.latitude
      } ) as geoLocationManager.GeoAddress[]
      // 调用getCurrentLocation获取当前设备位置，通过promise接收上报的位置
      console.log('current address: ' + JSON.stringify(result))
      return result[0].placeName ?? ''
    } catch (err) {
      console.error("errCode:" + JSON.stringify(err));
      throw err as Error
    }
  }
}