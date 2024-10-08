import { LogLevel, NIMInitializeOptions, NIMInterface, NIMServiceOptions, V2NIMProvidedServiceType } from '@nimsdk/base'
import { V2NIMConversationServiceImpl } from '@nimsdk/conversation'
import { V2NIMConversationGroupServiceImpl } from '@nimsdk/conversationgroup'
import { V2NIMFriendServiceImpl } from '@nimsdk/friend'
import { V2NIMLocalConversationServiceImpl } from '@nimsdk/localconversation'
import { V2NIMClientAntispamUtil, V2NIMMessageServiceImpl } from '@nimsdk/message'
import { NIMSdk } from '@nimsdk/nim'
import { V2NIMSignallingServiceImpl } from '@nimsdk/signalling'
import { V2NIMTeamServiceImpl } from '@nimsdk/team'
import { V2NIMUserServiceImpl } from '@nimsdk/user'
import common from '@ohos.app.ability.common'
import { USER_MODEL_LIST } from '../viewmodel/UserModel'

export class NimRepository {
  private _context: common.Context
  private _mode?: USER_MODEL_LIST

  public constructor(context: common.Context, mode?: USER_MODEL_LIST) {
    this._context = context
    this._mode = mode
  }

  private _nim: NIMInterface | undefined

  public get nim(): NIMInterface {
    if (!this._nim) {
      //this.createDefaultNim(this._context)
    }

    return this._nim!
  }

  createDefaultNim(context: common.Context) {
    console.warn('------------- 创建NIM实例 --------------')
    // 正式服
    const initializeOptions: NIMInitializeOptions = {
      appkey: "45c6af3c98409b18a84451215d0bdd6e",
      logLevel: LogLevel.Debug,
      isOpenConsoleLog: true
      // ...其他属性
    };

    const serviceOptions: NIMServiceOptions = {
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

    this.initNim(initializeOptions, serviceOptions)
    console.log("nim from createDefaultNim: " + this._nim)
  }

  initNim(initializeOptions: NIMInitializeOptions, serviceOptions?: NIMServiceOptions) {
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_TEAM,
      (core, serviceName, serviceConfig) => new V2NIMTeamServiceImpl(core, serviceName, serviceConfig))
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CLIENT_ANTISPAM_UTIL,
      (core, serviceName, serviceConfig) => new V2NIMClientAntispamUtil(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CONVERSATION,
      (core, serviceName, serviceConfig) => new V2NIMConversationServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_LOCAL_CONVERSATION,
      (core, serviceName, serviceConfig) => new V2NIMLocalConversationServiceImpl(core, serviceName, serviceConfig))
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_CONVERSATION_GROUP,
      (core, serviceName, serviceConfig) => new V2NIMConversationGroupServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_MESSAGE,
      (core, serviceName, serviceConfig) => new V2NIMMessageServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_USER,
      (core, serviceName, serviceConfig) => new V2NIMUserServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_FRIEND,
      (core, serviceName, serviceConfig) => new V2NIMFriendServiceImpl(core, serviceName, serviceConfig));
    NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_SIGNALLING,
      (core, serviceName, serviceConfig) => new V2NIMSignallingServiceImpl(core, serviceName, serviceConfig))
    this._nim = NIMSdk.newInstance(this._context, initializeOptions, serviceOptions)
    console.log("nim from initNim: " + this._nim)
  }
}