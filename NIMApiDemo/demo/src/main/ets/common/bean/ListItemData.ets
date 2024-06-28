/**
 * Basic list item data bean.
 */
export class ListItemData {
  /**
   * Indicates list item title.
   */
  title: Resource;

  /**
   * Indicates list item summary.
   */
  summary: Resource;

  constructor(title: Resource, summary: Resource) {
    this.title = title
    this.summary = summary
  }
}