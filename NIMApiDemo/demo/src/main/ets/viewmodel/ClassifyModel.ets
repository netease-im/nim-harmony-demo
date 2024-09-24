import FunctionalModel from './CourseModel';

/**
 * course classity model
 */
export default class ClassifyModel {
  /**
   * classify id
   */
  classifyId: number;
  /**
   * classify name
   */
  classifyName: string;
  /**
   * course list of the classify.
   */
  courseList: Array<FunctionalModel>;

  public constructor(classifyId: number, classifyName: string, courseList: Array<FunctionalModel>) {
    this.classifyId = classifyId;
    this.classifyName = classifyName;
    this.courseList = courseList;
  }
}