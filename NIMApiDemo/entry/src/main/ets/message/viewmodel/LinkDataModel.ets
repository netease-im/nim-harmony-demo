export default class LinkDataModel {
  /**
   * parentId
   */
  superId: number
  /**
   * ParentName
   */
  superName: string
  id: number
  module: string
  methodName: string

  constructor(superId: number, superName: string, id: number, module: string, methodName: string) {
    this.superId = superId
    this.superName = superName
    this.id = id
    this.module = module
    this.methodName = methodName
  }
}