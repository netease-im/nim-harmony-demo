
import ClassifyModel from './ClassifyModel';
import FunctionalModel from './CourseModel';
import LinkDataModel from './LinkDataModel';

class ClassifyViewModel {
  /**
   * Get Classify list data
   *
   * @returns Array<ClassifyModel> linkDataList
   */
  getLinkData(type: LinkDataType): Array<ClassifyModel> {
    let linkDataList: Array<ClassifyModel> = [];
    let superId: number = 0;
    let linkData : LinkDataModel[] = []
    switch (type) {
      case LinkDataType.CLIENT:
        linkData = CLIENT_DATA
        break;
      case LinkDataType.MESSAGE:
        linkData = MESSAGE_DATA
        break;
    }
    linkData.forEach((item: LinkDataModel) => {
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

export enum LinkDataType {
  CLIENT = 0,
  MESSAGE = 1
}

let classifyViewModel = new ClassifyViewModel();

export default classifyViewModel as ClassifyViewModel;
const CLIENT_DATA: LinkDataModel[] = [
  new LinkDataModel(1, 'Client', 1, 'client', 'newInstance'),
  new LinkDataModel(1, 'Client', 2,  'client','destroyInstance'),
  new LinkDataModel(1, 'Client', 3,  'client','getInstance'),
  new LinkDataModel(1, 'Client', 4,  'client', 'getInstanceList'),
  new LinkDataModel(1, 'Client', 5, 'client', 'destroyAll'),
  new LinkDataModel(1, 'Client', 6, 'client','enter'),
  new LinkDataModel(1, 'Client', 7, 'client','exit'),
  new LinkDataModel(1, 'Client', 8, 'client','getChatroomInfo'),
  // new LinkDataModel(1, 'Client', 9, 'client', 'getChatroomService'),
  // new LinkDataModel(1, 'Client', 10, 'client', 'getStorageService'),
  new LinkDataModel(1, 'Client', 11, 'client', 'setListener'),
  // new LinkDataModel(1, 'Client', 12, 'client', 'removeChatroomClientListener'),
]

const MESSAGE_DATA: LinkDataModel[] = [
  new LinkDataModel(1, 'Message', 1, 'message', 'sendMessage'),
  new LinkDataModel(1, 'Message', 2, 'message', 'getMessageList'),
  new LinkDataModel(1, 'Message', 3, 'message', 'getMessageListByTag'),
  new LinkDataModel(2, 'Info', 1, 'info', 'updateChatroomInfo'),
  new LinkDataModel(2, 'Info', 2, 'info', 'updateChatroomLocationInfo'),
  new LinkDataModel(2, 'Info', 3, 'info', 'updateChatroomTags'),
  new LinkDataModel(3, 'Member', 1, 'member', 'getMemberListByOption'),
  new LinkDataModel(3, 'Member', 2, 'member', 'getMemberListByTag'),
  new LinkDataModel(3, 'Member', 3, 'member', 'getMemberCountByTag'),
  new LinkDataModel(3, 'Member', 4, 'member', 'setMemberBlockedStatus'),
  new LinkDataModel(3, 'Member', 5, 'member', 'setMemberChatBannedStatus'),
  new LinkDataModel(3, 'Member', 6, 'member', 'setMemberTempChatBanned'),
  new LinkDataModel(3, 'Member', 7, 'member', 'setTempChatBannedByTag'),
  new LinkDataModel(3, 'Member', 8, 'member', 'updateMemberRole'),
  new LinkDataModel(3, 'Member', 9, 'member', 'updateSelfMemberInfo'),
  new LinkDataModel(3, 'Member', 10, 'member', 'kickMember'),
]
