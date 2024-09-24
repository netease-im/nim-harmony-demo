
import { picker } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit';

let uris: Array<string> = [];

export async function photoPickerGetUri(): Promise<string> {
  try {
    let PhotoSelectOptions = new picker.PhotoSelectOptions()
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
    PhotoSelectOptions.maxSelectNumber = 1
    let photoPicker = new picker.PhotoViewPicker()
    await photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult:
    picker.PhotoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      uris = PhotoSelectResult.photoUris
    }).catch((err: BusinessError) => {
      console.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    })
  } catch (error) {
    let err = error as BusinessError;
    console.error('PhotoViewPicker failed with err: ' + err.message);
  }

  return uris[0].toString()
}