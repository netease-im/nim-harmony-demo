export interface NavItem {
  icon: Resource;
  icon_selected: Resource;
  text: Resource;
  id: number;
}
// tabId
export enum TabId {
  // HOME,
  CONVERSATION,
  MESSAGE,
  LOCAL_CONVERSATION,
  TEAM,
  SIGNALING,
  MINE
}

export const NavList: NavItem[] = [
  // {
  //   icon: $r('app.media.ic_tabs_home_normal'),
  //   icon_selected: $r('app.media.ic_tabs_home_sel'),
  //   text: $r('app.string.tab_home'),
  //   id: TabId.HOME
  // },
  {
    icon: $r('app.media.ic_tabs_conversation_normal'),
    icon_selected: $r('app.media.ic_tabs_conversation_sel'),
    text: $r('app.string.tab_conversation'),
    id: TabId.CONVERSATION
  },
  {
    icon: $r('app.media.ic_tabs_message_normal'),
    icon_selected: $r('app.media.ic_tabs_message_sel'),
    text: $r('app.string.tab_message'),
    id: TabId.MESSAGE
  },
  {
    icon: $r('app.media.ic_tabs_conversation_normal'),
    icon_selected: $r('app.media.ic_tabs_conversation_sel'),
    text: $r('app.string.tab_local_conversation'),
    id: TabId.CONVERSATION
  },
  {
    icon: $r('app.media.ic_tabs_team_normal'),
    icon_selected: $r('app.media.ic_tabs_team_sel'),
    text: $r('app.string.tab_team'),
    id: TabId.TEAM
  },
  {
    icon: $r('app.media.ic_tabs_signaling_normal'),
    icon_selected: $r('app.media.ic_tabs_signaling_sel'),
    text: $r('app.string.tab_signaling'),
    id: TabId.SIGNALING
  },
  {
    icon: $r('app.media.ic_tabs_mine_normal'),
    icon_selected: $r('app.media.ic_tabs_mine_sel'),
    text: $r('app.string.tab_mine'),
    id: TabId.MINE
  },
]