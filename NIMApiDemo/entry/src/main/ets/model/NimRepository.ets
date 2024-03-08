import common from '@ohos.app.ability.common'
import { NIMInterface, NIMInitializeOptions, NIMServiceOptions } from 'base'
import { NIMSdk } from 'nim'

export class NimRepository {
  private _context: common.Context
  private _nim: NIMInterface | undefined

  public get nim(): NIMInterface {
    if (!this._nim) {
      this.createDefaultNim(this._context)
    }

    return this._nim!
  }

  constructor(context: common.Context) {
    this._context = context
  }

  createDefaultNim(context: common.Context) {
    console.warn('------------- 创建NIM实例 --------------')

    // let initializeOptions: NIMInitializeOptions = {
    //   appkey: "fe416640c8e8a72734219e1847ad2547",
    //   debugLevel: "debug",
    //   // ...其他属性
    // };
    //
    // let serviceOptions: NIMServiceOptions = {
    //   loginServiceConfig: {
    //     lbsUrls: ['https://imtest.netease.im/lbs/webconf'],
    //     linkUrl: 'imtest-jd.netease.im:8091'
    //   }
    // }

    let initializeOptions: NIMInitializeOptions = {
      appkey: "45c6af3c98409b18a84451215d0bdd6e",
      debugLevel: "debug",
      // ...其他属性
    };

    let serviceOptions: NIMServiceOptions = {
      loginServiceConfig: {
        lbsUrls: ['https://imtest.netease.im/lbs/webconf'],
        linkUrl: 'weblink-harmony-tmp.netease.im:443'
      }
    }

    this._nim = NIMSdk.newInstance(context, initializeOptions, serviceOptions)
    console.log("nim from createDefaultNim: " + this._nim)
  }

  initNim(initializeOptions: NIMInitializeOptions, serviceOptions?: NIMServiceOptions) {
    this._nim = NIMSdk.newInstance(this._context, initializeOptions, serviceOptions)
    console.log("nim from initNim: " + this._nim)
  }
}