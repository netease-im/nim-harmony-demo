import common from '@ohos.app.ability.common'
import { LogLevel, NIMInitializeOptions, NIMServiceOptions, V2NIMProvidedServiceType } from '@nimsdk/base'
import { NIMSdk } from '@nimsdk/nim'
import { NIMInterface } from '@nimsdk/base'
import { V2NIMTeamServiceImpl } from '@nimsdk/team'
import { V2NIMConversationServiceImpl } from '@nimsdk/conversation'
import { V2NIMUserServiceImpl } from '@nimsdk/user';
import { V2NIMFriendServiceImpl } from '@nimsdk/friend';
import { V2NIMClientAntispamUtil, V2NIMMessageServiceImpl } from '@nimsdk/message';
import { V2NIMConversationGroupServiceImpl } from '@nimsdk/conversationgroup';
import { V2NIMSignallingServiceImpl } from '@nimsdk/signalling'
import { USER_MODEL_LIST } from '../viewmodel/UserModel'
import { V2NIMLocalConversationServiceImpl } from '@nimsdk/localconversation'

export class NimRepository {
  private _context: common.Context
  private _nim: NIMInterface | undefined
  private _mode?: USER_MODEL_LIST

  public get nim(): NIMInterface {
    if (!this._nim) {
      this.createDefaultNim(this._context)
    }

    return this._nim!
  }

  constructor(context: common.Context, mode?: USER_MODEL_LIST) {
    this._context = context
    this._mode = mode
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
      appkey: "xxx",
    }

    let serviceOptions: NIMServiceOptions = {
      loginServiceConfig :{

      },
    }
    // // 测试服
    // if (this._mode === USER_MODEL_LIST.TEST) {
    //   initializeOptions = {
    //     appkey: "fe416640c8e8a72734219e1847ad2547",
    //     logLevel: LogLevel.Debug,
    //     // ...其他属性
    //   };
    //
    //   serviceOptions = {
    //     loginServiceConfig: {
    //       lbsUrls: ['https://imtest-gy.netease.im/lbs/webconf'],
    //       linkUrl: 'weblink-dev-gy.netease.im:443'
    //     },
    //     pushServiceConfig: {
    //       harmonyCertificateName: "DEMO_HMOS_PUSH"
    //     },
    //     databaseServiceConfig:{
    //       encrypt: false,
    //       appKey: "fe416640c8e8a72734219e1847ad2547",
    //     }
    //   }
    // } else if (this._mode === USER_MODEL_LIST.CUSTOM) {
    //   // 私有化
    //   initializeOptions = {
    //     appkey: "c3a82b40cd2b0998cb11afbcdeff1837",
    //     logLevel: LogLevel.Debug,
    //     // ...其他属性
    //   };
    //
    //   serviceOptions = {
    //     loginServiceConfig: {
    //       lbsUrls: ['https://yunxinent-demo.netease.im/lbs/webconf.jsp'],
    //       linkUrl: 'yunxinent-demo.netease.im'
    //     },
    //     pushServiceConfig: {
    //       harmonyCertificateName: "DEMO_HMOS_PUSH"
    //     },
    //     httpServiceConfig: {
    //       chunkUploadHost: 'https://yunxinent-demo.netease.im',
    //       uploadReplaceFormat: 'https://yunxinent-demo.netease.im/yunxin/{object}'
    //     },
    //     databaseServiceConfig:{
    //       encrypt: false,
    //       appKey: "c3a82b40cd2b0998cb11afbcdeff1837",
    //     }
    //   }
    // } else {
      // 正式服
      initializeOptions = {
        appkey: "45c6af3c98409b18a84451215d0bdd6e",
        logLevel: LogLevel.Debug,
        // ...其他属性
      };

      serviceOptions = {
        loginServiceConfig: {
          lbsUrls: ['https://lbs.netease.im/lbs/webconf.jsp'],
          linkUrl: 'weblink.netease.im:443'
        },
        pushServiceConfig: {
          harmonyCertificateName: "DEMO_HMOS_PUSH"
        },
        databaseServiceConfig: {
          encrypt: false,
          appKey: "45c6af3c98409b18a84451215d0bdd6e",
        }
      }
    // }
    this.initNim(initializeOptions, serviceOptions)
    // this._nim = NIMSdk.newInstance(context, initializeOptions, serviceOptions)
    console.log("nim from createDefaultNim: " + this._nim)
  }

  initNim(initializeOptions: NIMInitializeOptions, serviceOptions?: NIMServiceOptions) {
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_TEAM, (core, serviceName, serviceConfig) => new V2NIMTeamServiceImpl(core, serviceName, serviceConfig))
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CLIENT_ANTISPAM_UTIL, (core, serviceName, serviceConfig) => new V2NIMClientAntispamUtil(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CONVERSATION, (core, serviceName, serviceConfig) => new V2NIMConversationServiceImpl(core, serviceName, serviceConfig));
    // NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_LOCAL_CONVERSATION, (core, serviceName, serviceConfig) => new V2NIMLocalConversationServiceImpl(core, serviceName, serviceConfig))
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CONVERSATION_GROUP, (core, serviceName, serviceConfig) => new V2NIMConversationGroupServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_MESSAGE, (core, serviceName, serviceConfig) => new V2NIMMessageServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_USER, (core, serviceName, serviceConfig) => new V2NIMUserServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_FRIEND, (core, serviceName, serviceConfig) => new V2NIMFriendServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_SIGNALLING, (core, serviceName, serviceConfig) => new V2NIMSignallingServiceImpl(core, serviceName, serviceConfig))
    this._nim = NIMSdk.newInstance(this._context, initializeOptions, serviceOptions)
    console.log("nim from initNim: " + this._nim)
  }
}