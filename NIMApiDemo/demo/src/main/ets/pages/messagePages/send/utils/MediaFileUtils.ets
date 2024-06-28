import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fileIo from '@ohos.file.fs';

const KEY_PICTURE_PATHS = 'paths'

export class MediaFileUtils {
  static readonly tag: string = 'FileUtils';
  static readonly qualityValue: number = 98;
  static readonly formatValue: string = 'image/jpeg';
  static readonly extensionValue: string = 'jpg';
  static options: image.DecodingOptions = {
    desiredDynamicRange: image.DecodingDynamicRange.AUTO,
    index: 0
  };
  /**
   * send picture to cloud
   * @param context
   * @param photo
   * @param index
   */
  static async sendCloudFile(context: Context, photo: PixelMap, index: number) {
    let jsonStr = AppStorage.get<string>(KEY_PICTURE_PATHS);
    let pathsArr:string[] = [];
    if (jsonStr !== undefined) {
      pathsArr = JSON.parse(jsonStr);
      console.debug(MediaFileUtils.tag, `sendCloudFile pathsArr 000 : ${JSON.stringify(pathsArr)}`);
    }

    let pathDir: string = context.distributedFilesDir;
    let filePath: string = `${pathDir}/picture_${index}.jpg`;
    pathsArr.push(filePath);
    AppStorage.setOrCreate(KEY_PICTURE_PATHS, JSON.stringify(pathsArr));
    console.debug(MediaFileUtils.tag, `sendCloudFile pathsArr 1111 : ${JSON.stringify(pathsArr)}`);
    const imagePacker = image.createImagePacker();
    const packOptions: image.PackingOption = {
      format: MediaFileUtils.formatValue,
      quality: MediaFileUtils.qualityValue
    }
    await imagePacker.packing(photo, packOptions).then(async (data: ArrayBuffer) => {
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, data);
      console.debug(MediaFileUtils.tag, `sendCloudFile file size: ${fileIo.statSync(filePath).size}`);
      fs.closeSync(file.fd);
    });
  }

  static async getCloudFile(): Promise<PixelMap[]> {
    let pixelMapArr: PixelMap[] = [];
    let str = AppStorage.get(KEY_PICTURE_PATHS) as string;
    let pathsArr = JSON.parse(str) as Array<string>;
    console.error(MediaFileUtils.tag, `sendCloudFile pathsArr 1111 : ${JSON.stringify(pathsArr)}`);
    pathsArr.forEach((uri) => {
      MediaFileUtils.createPixelMapFromUri(uri).then((pixelMap) => {
        if (pixelMap !== undefined) {
          pixelMapArr.push(pixelMap);
        }
      })
    });
    console.debug(MediaFileUtils.tag, `getCloudFile pathsArr: ${pathsArr.length} pixelMapArr: ${pixelMapArr.length}`);
    return pixelMapArr;
  }

  /**
   * create PixelMap
   * @param uri file uri
   * @returns pixelMap
   */
  static async createPixelMapFromUri(uri: string): Promise<PixelMap | undefined> {
    if (uri === '') {
      return undefined;
    }
    let pixelMap: PixelMap | undefined;
    try {
      let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      let imageResource = image.createImageSource(file.fd);
      pixelMap = imageResource.createPixelMapSync(MediaFileUtils.options);
      fs.closeSync(file);
    } catch (error) {
      console.error(MediaFileUtils.tag, `createPixelMapFromUri error: ${JSON.stringify(error)}`);
    }
    return pixelMap;
  }

  static async createPixelMap(buffer: ArrayBuffer): Promise<PixelMap | undefined> {
    let pixelMap: PixelMap | undefined;
    try {
      let imageResource = image.createImageSource(buffer);
      pixelMap = imageResource.createPixelMapSync(MediaFileUtils.options);
    } catch (error) {
      console.error(MediaFileUtils.tag, `createPixelMap error: ${JSON.stringify(error)}`);
    }
    return pixelMap;
  }

  static async savePicture(buffer: ArrayBuffer): Promise<string> {
    let options: photoAccessHelper.CreateOptions = {
      title: Date.now().toString()
    };
    let accessHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext());
    let photoUri: string =
      await accessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, MediaFileUtils.extensionValue, options);
    let file: fileIo.File = fileIo.openSync(photoUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    await fileIo.write(file.fd, buffer);
    fileIo.closeSync(file);
    console.debug(MediaFileUtils.tag, `savePicture uri: ${photoUri}}`);
    return photoUri;
  }
}