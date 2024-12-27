/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 *
 */

export class DeviceUtils {
  static windowPXWidth: number = 0;
  static windowPXHeight: number = 0;
  static rootDirPath: string = '';
  private static msgLineWidth: number = 0;

  static getMessageLineWidth(): number {
    DeviceUtils.msgLineWidth = DeviceUtils.windowPXWidth * 0.75 - vp2px(50);
    return DeviceUtils.msgLineWidth;
  }

  static getPinMessageLineWidth(): number {
    DeviceUtils.msgLineWidth = DeviceUtils.windowPXWidth - vp2px(72);
    return DeviceUtils.msgLineWidth;
  }
}