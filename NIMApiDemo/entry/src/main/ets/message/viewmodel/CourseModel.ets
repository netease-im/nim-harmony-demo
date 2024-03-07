export default class FunctionalModel {
  classifyId: number
  courseId: number
  module: string
  methodName: string

  constructor(classifyId: number, courseId: number, module:string, courseName: string) {
    this.classifyId = classifyId
    this.courseId = courseId
    this.module = module
    this.methodName = courseName
  }
}