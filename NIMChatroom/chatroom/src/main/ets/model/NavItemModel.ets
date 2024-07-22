export interface NavItem {
  icon: Resource;
  icon_selected: Resource;
  text: Resource;
  id: number;
}
// tabId
export enum TabId {
  // HOME,
  CLIENT,
  INSTANCE,
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
    text: $r('app.string.tab_client'),
    id: TabId.CLIENT
  },
  {
    icon: $r('app.media.ic_tabs_message_normal'),
    icon_selected: $r('app.media.ic_tabs_message_sel'),
    text: $r('app.string.tab_instance'),
    id: TabId.INSTANCE
  },
  // {
  //   icon: $r('app.media.ic_tabs_team_normal'),
  //   icon_selected: $r('app.media.ic_tabs_team_sel'),
  //   text: $r('app.string.tab_team'),
  //   id: TabId.TEAM
  // },
  // {
  //   icon: $r('app.media.ic_tabs_mine_normal'),
  //   icon_selected: $r('app.media.ic_tabs_mine_sel'),
  //   text: $r('app.string.tab_mine'),
  //   id: TabId.MINE
  // },
]