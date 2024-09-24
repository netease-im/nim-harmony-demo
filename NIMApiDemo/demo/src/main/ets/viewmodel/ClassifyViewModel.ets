
import ClassifyModel from './ClassifyModel';
import FunctionalModel from './CourseModel';
import LinkDataModel from './LinkDataModel';

class ClassifyViewModel {
  /**
   * Get Classify list data
   *
   * @returns Array<ClassifyModel> linkDataList
   */
  getLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    LINK_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }

  getTeamLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    LINK_TEAM_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }

  getConversationLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    CONVERSATION_LINK_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }

  getLocalConversationLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    LOCAL_CONVERSATION_LINK_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }


  getMineLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    LINK_MINE_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }

  getSignallingLinkData(): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    LINK_Signalling_DATA.forEach((item: LinkDataModel) => {
      if (superId !== item.superId) {
        // add the course classify model.
        let classifyItem: ClassifyModel = new ClassifyModel(item.superId, item.superName, []);
        linkDataList.push(classifyItem);
      }
      // add the course model.
      let courseItem: FunctionalModel = new FunctionalModel(superId, item.id, item.module, item.methodName);
      linkDataList[linkDataList.length-1].courseList.push(courseItem);
      superId = item.superId;
    });
    return linkDataList;
  }
}

let classifyViewModel = new ClassifyViewModel();

export default classifyViewModel as ClassifyViewModel;
const LINK_DATA: LinkDataModel[] = [
  new LinkDataModel(1, '收藏Collection', 1, 'collection', 'addCollection'),
  new LinkDataModel(1, '收藏Collection', 2,  'collection','removeCollection'),
  new LinkDataModel(1, '收藏Collection', 3,  'collection','updateCollection'),
  new LinkDataModel(1, '收藏Collection', 4,  'collection', 'getCollectionList'),
  new LinkDataModel(2, 'Pin 功能', 1, 'pin', 'pinMessage'),
  new LinkDataModel(2, 'Pin 功能', 2, 'pin','unpinMessage'),
  new LinkDataModel(2, 'Pin 功能', 3, 'pin','updatePinMessage'),
  new LinkDataModel(2, 'Pin 功能', 4, 'pin','getPinList'),
  new LinkDataModel(3, 'revoke 功能', 1, 'revoke', 'revokeMessage'),
  new LinkDataModel(4, 'Reply 功能', 1, 'reply', 'replyMessage'),
  new LinkDataModel(5, 'get 消息', 1, 'get', 'getMessagesList'),
  new LinkDataModel(5, 'get 消息', 2, 'get', 'getMessagesListByRefers'),
  new LinkDataModel(5, 'get 消息', 3, 'get', 'getMessagesListByIds'),
  new LinkDataModel(5, 'get 消息', 4,'get',  'searchCloudMessages'),
  new LinkDataModel(5, 'get 消息', 5, 'get', 'getThreadMessageList'),
  new LinkDataModel(6, 'delete 消息', 1, 'delete','deleteMessage'),
  new LinkDataModel(6, 'delete 消息', 2, 'delete','deleteMessages'),
  new LinkDataModel(6, 'delete 消息', 3, 'delete','clearHistoryMessage'),
  new LinkDataModel(6, 'delete 消息', 4, 'delete', 'insertLocalMessage'),
  new LinkDataModel(7, 'receipt 消息', 1, 'receipt','sendP2PMessageReceipt'),
  new LinkDataModel(7, 'receipt 消息', 2, 'receipt','getP2PMessageReceipt'),
  new LinkDataModel(7, 'receipt 消息', 3, 'receipt','isPeerRead'),
  new LinkDataModel(8, 'comment 消息', 1, 'comment','addQuickComment'),
  new LinkDataModel(8, 'comment 消息', 2, 'comment','removeQuickComment'),
  new LinkDataModel(8, 'comment 消息', 3, 'comment', 'getQuickCommentList'),
  // new LinkDataModel(9, 'translate', 1, 'translate','translateVoiceToText'),
  new LinkDataModel(10, 'send message', 1, 'send', 'sendTextMessage'),
  new LinkDataModel(10, 'send message', 2, 'send', 'sendTipsMessage'),
  new LinkDataModel(10, 'send message', 3, 'send', 'sendFileMessage'),
  new LinkDataModel(10, 'send message', 4, 'send', 'sendImageMessage'),
  new LinkDataModel(10, 'send message', 5, 'send', 'sendAudioMessage'),
  new LinkDataModel(10, 'send message', 6, 'send', 'sendVideoMessage'),
  new LinkDataModel(10, 'send message', 7, 'send', 'sendLocationMessage'),
  new LinkDataModel(10, 'send message', 8, 'send', 'sendCustomMessage'),
  new LinkDataModel(10, 'send message', 9, 'send', 'sendCallMessage'),
  new LinkDataModel(11, '本地存储', 1, 'persist', 'persistMessage'),
  new LinkDataModel(12, '自定义通知', 1, 'notification', 'CustomNotificationService'),
]

const CONVERSATION_LINK_DATA: LinkDataModel[] = [
  new LinkDataModel(1, 'Conversation 功能', 1, 'conversation', 'getConversationList'),
  new LinkDataModel(1, 'Conversation 功能', 2, 'conversation', 'getConversationListByOption'),
  new LinkDataModel(1, 'Conversation 功能', 3, 'conversation', 'getConversation'),
  new LinkDataModel(1, 'Conversation 功能', 4, 'conversation', 'getConversationListByIds'),
  new LinkDataModel(1, 'Conversation 功能', 5, 'conversation', 'createConversation'),
  new LinkDataModel(1, 'Conversation 功能', 6, 'conversation', 'deleteConversation'),
  new LinkDataModel(1, 'Conversation 功能', 7, 'conversation', 'deleteConversationListByIds'),
  new LinkDataModel(1, 'Conversation 功能', 8, 'conversation', 'stickTopConversation'),
  new LinkDataModel(1, 'Conversation 功能', 9, 'conversation', 'updateConversation'),
  new LinkDataModel(1, 'Conversation 功能', 10, 'conversation', 'updateConversationLocalExtension'),
  new LinkDataModel(2, '未读数 功能', 1, 'unreadCount', 'getTotalUnreadCount'),
  new LinkDataModel(2, '未读数 功能', 2, 'unreadCount', 'getUnreadCountByIds'),
  new LinkDataModel(2, '未读数 功能', 3, 'unreadCount', 'getUnreadCountByFilter'),
  new LinkDataModel(2, '未读数 功能', 4, 'unreadCount', 'clearTotalUnreadCount'),
  new LinkDataModel(2, '未读数 功能', 5, 'unreadCount', 'clearUnreadCountByIds'),
  new LinkDataModel(2, '未读数 功能', 6, 'unreadCount', 'clearUnreadCountByGroupId'),
  new LinkDataModel(2, '未读数 功能', 7, 'unreadCount', 'clearUnreadCountByTypes'),
  new LinkDataModel(2, '未读数 功能', 8, 'unreadCount', 'subscribeAndUnsubscribeUnreadCountByFilter'),
]

const LOCAL_CONVERSATION_LINK_DATA: LinkDataModel[] = [
  new LinkDataModel(1, '本地会话 功能', 1, 'conversation', 'getConversationList'),
  new LinkDataModel(1, '本地会话 功能', 2, 'conversation', 'getConversationListByOption'),
  new LinkDataModel(1, '本地会话 功能', 3, 'conversation', 'getConversation'),
  new LinkDataModel(1, '本地会话 功能', 4, 'conversation', 'getConversationListByIds'),
  new LinkDataModel(1, '本地会话 功能', 5, 'conversation', 'createConversation'),
  new LinkDataModel(1, '本地会话 功能', 6, 'conversation', 'deleteConversation'),
  new LinkDataModel(1, '本地会话 功能', 7, 'conversation', 'deleteConversationListByIds'),
  new LinkDataModel(1, '本地会话 功能', 8, 'conversation', 'stickTopConversation'),
  new LinkDataModel(1, '本地会话 功能', 9, 'conversation', 'updateConversation'),
  new LinkDataModel(1, '本地会话 功能', 10, 'conversation', 'updateConversationLocalExtension'),
  new LinkDataModel(2, '本地未读数 功能', 1, 'unreadCount', 'getTotalUnreadCount'),
  new LinkDataModel(2, '本地未读数 功能', 2, 'unreadCount', 'getUnreadCountByIds'),
  new LinkDataModel(2, '本地未读数 功能', 3, 'unreadCount', 'getUnreadCountByFilter'),
  new LinkDataModel(2, '本地未读数 功能', 4, 'unreadCount', 'clearTotalUnreadCount'),
  new LinkDataModel(2, '本地未读数 功能', 5, 'unreadCount', 'clearUnreadCountByIds'),
  new LinkDataModel(2, '本地未读数 功能', 6, 'unreadCount', 'clearUnreadCountByGroupId'),
  new LinkDataModel(2, '本地未读数 功能', 7, 'unreadCount', 'clearUnreadCountByTypes'),
  new LinkDataModel(2, '本地未读数 功能', 8, 'unreadCount', 'subscribeUnreadCountByFilter'),
  new LinkDataModel(2, '本地未读数 功能', 9, 'unreadCount', 'markConversationRead'),
  new LinkDataModel(2, '本地未读数 功能', 10, 'unreadCount', 'getConversationReadTime'),
]

const LINK_TEAM_DATA: LinkDataModel[] = [
  new LinkDataModel(1, 'Team', 1, 'team', 'createTeam'),
  new LinkDataModel(1, 'Team', 2, 'team', 'updateTeamInfo'),
  new LinkDataModel(1, 'Team', 3, 'team', 'leaveTeam'),
  new LinkDataModel(1, 'Team', 4, 'team', 'getTeamInfo'),
  new LinkDataModel(1, 'Team', 5, 'team', 'getJoinedTeamList'),
  new LinkDataModel(1, 'Team', 6, 'team', 'getJoinedTeamCount'),
  new LinkDataModel(1, 'Team', 7, 'team', 'getTeamInfoByIds'),
  new LinkDataModel(1, 'Team', 8, 'team', 'dismissTeam'),
  new LinkDataModel(1, 'Team', 9, 'team', 'transferTeamOwner'),
  new LinkDataModel(1, 'Team', 10, 'team', 'setTeamChatBannedMode'),
  new LinkDataModel(1, 'Team', 11, 'team', 'getTeamJoinActionInfoList'),
  new LinkDataModel(1, 'Team', 12, 'team', 'searchTeamByKeyword'),
  new LinkDataModel(2, 'TeamMember', 1, 'teamMember', 'inviteMember'),
  new LinkDataModel(2, 'TeamMember', 2, 'teamMember', 'acceptInvitation'),
  new LinkDataModel(2, 'TeamMember', 3, 'teamMember', 'rejectInvitation'),
  new LinkDataModel(2, 'TeamMember', 4, 'teamMember', 'kickMember'),
  new LinkDataModel(2, 'TeamMember', 5, 'teamMember', 'applyJoinTeam'),
  new LinkDataModel(2, 'TeamMember', 6, 'teamMember', 'acceptJoinApplication'),
  new LinkDataModel(2, 'TeamMember', 7, 'teamMember', 'rejectJoinApplication'),
  new LinkDataModel(2, 'TeamMember', 8, 'teamMember', 'updateTeamMemberRole'),
  new LinkDataModel(2, 'TeamMember', 9, 'teamMember', 'updateSelfTeamMemberInfo'),
  new LinkDataModel(2, 'TeamMember', 10, 'teamMember', 'updateTeamMemberNick'),
  new LinkDataModel(2, 'TeamMember', 11, 'teamMember', 'setTeamMemberChatBannedStatus'),
  new LinkDataModel(2, 'TeamMember', 12, 'teamMember', 'getTeamMemberList'),
  new LinkDataModel(2, 'TeamMember', 13, 'teamMember', 'getTeamMemberListByIds'),
  new LinkDataModel(2, 'TeamMember', 14, 'teamMember', 'getTeamMemberInvitor'),
  new LinkDataModel(2, 'TeamMember', 15, 'teamMember', 'searchTeamMembers')
]

const LINK_MINE_DATA: LinkDataModel[] = [
  new LinkDataModel(1, 'User', 1, 'user', 'getUserList'),
  new LinkDataModel(1, 'User', 2, 'user', 'addUserToBlockList'),
  new LinkDataModel(1, 'User', 3, 'user', 'getBlockList'),
  new LinkDataModel(1, 'User', 4, 'user', 'removeUserFromBlockList'),
  new LinkDataModel(1, 'User', 5, 'user', 'updateSelfUserProfile'),
  new LinkDataModel(2, 'Friend', 1, 'friend', 'addFriend'),
  new LinkDataModel(2, 'Friend', 2, 'friend', 'checkFriend'),
  new LinkDataModel(2, 'Friend', 3, 'friend', 'deleteFriend'),
  new LinkDataModel(2, 'Friend', 4, 'friend', 'getFriendByIds'),
  new LinkDataModel(2, 'Friend', 5, 'friend', 'getFriendList'),
  new LinkDataModel(2, 'Friend', 6, 'friend', 'acceptAddApplication'),
  new LinkDataModel(2, 'Friend', 7, 'friend', 'rejectAddApplication'),
  new LinkDataModel(2, 'Friend', 8, 'friend', 'setFriendInfo'),
  new LinkDataModel(2, 'Friend', 9, 'friend', 'getAddApplicationList'),
  new LinkDataModel(3, 'Push', 1, 'push', 'pushService'),
  new LinkDataModel(4, 'Setting', 1, 'setting', 'getConversationMuteStatus'),
  new LinkDataModel(4, 'Setting', 2, 'setting', 'setTeamMessageMuteMode'),
  new LinkDataModel(4, 'Setting', 3, 'setting', 'getTeamMessageMuteMode'),
  new LinkDataModel(4, 'Setting', 4, 'setting', 'setP2PMessageMuteMode'),
  new LinkDataModel(4, 'Setting', 5, 'setting', 'getP2PMessageMuteMode'),
  new LinkDataModel(4, 'Setting', 6, 'setting', 'getP2PMessageMuteList'),
  new LinkDataModel(4, 'Setting', 7, 'setting', 'setPushMobileOnDesktopOnline'),
  new LinkDataModel(4, 'Setting', 8, 'setting', 'setDndConfig'),
  new LinkDataModel(4, 'Setting', 9, 'setting', 'getDndConfig'),
  new LinkDataModel(5, 'Login', 1, 'login', 'fetchChatroomList'),
  new LinkDataModel(5, 'Login', 2, 'login', 'getLoginUser'),
  new LinkDataModel(5, 'Login', 3, 'login', 'getLoginStatus'),
  new LinkDataModel(5, 'Login', 4, 'login', 'getConnectStatus'),
  new LinkDataModel(5, 'Login', 5, 'login', 'getDataSync'),
  new LinkDataModel(5, 'Login', 6, 'login', 'getLoginClients'),
  new LinkDataModel(6, 'storage', 1, 'storage', 'sdkLogDirPath'),
  new LinkDataModel(6, 'storage', 2, 'storage', 'sdkLogPath'),
  new LinkDataModel(6, 'storage', 3, 'storage', 'uploadSDKLogs'),
  new LinkDataModel(6, 'storage', 4, 'storage', 'addCustomStorageScene'),
  new LinkDataModel(6, 'storage', 5, 'storage', 'getStorageSceneList'),
  new LinkDataModel(6, 'storage', 6, 'storage', 'createUploadFileTask'),
  new LinkDataModel(6, 'storage', 7, 'storage', 'uploadFile'),
  new LinkDataModel(6, 'storage', 8, 'storage', 'cancelUploadFile'),
  new LinkDataModel(6, 'storage', 9, 'storage', 'downloadFile'),
  new LinkDataModel(6, 'storage', 10, 'storage', 'cancelDownloadFile'),
  new LinkDataModel(6, 'storage', 11, 'storage', 'shortUrlToLong')
]

const LINK_Signalling_DATA: LinkDataModel[] = [

  new LinkDataModel(1, 'Room', 1, 'signalling', 'createRoom'),
  new LinkDataModel(1, 'Room', 2, 'signalling', 'closeRoom'),
  new LinkDataModel(1, 'Room', 3, 'signalling', 'joinRoom'),
  new LinkDataModel(1, 'Room', 4, 'signalling', 'leaveRoom'),
  new LinkDataModel(1, 'Room', 5, 'signalling', 'delayRoom'),
  new LinkDataModel(1, 'Room', 6, 'signalling', 'call'),
  new LinkDataModel(1, 'Room', 7, 'signalling', 'callSetup'),
  new LinkDataModel(2, '自定义', 1, 'signalling', 'sendControl'),
  new LinkDataModel(3, '查询', 1, 'signalling', 'getChannelInfo'),
  new LinkDataModel(4, '邀请', 1, 'signalling', 'invite'),
  new LinkDataModel(4, '邀请', 2, 'signalling', 'acceptInvite'),
  new LinkDataModel(4, '邀请', 3, 'signalling', 'cancelInvite'),
  new LinkDataModel(4, '邀请', 4, 'signalling', 'rejectInvite'),




]