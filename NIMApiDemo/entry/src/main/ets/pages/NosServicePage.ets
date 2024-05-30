import { UploadFileOptions, UploadFileProgress, UploadFileResult } from '@nimsdk/base';
import { CommonConstants } from '../common/constants/CommonConstants';
import { TitleWithBack } from '../view/TitleWithBack';
import fs from '@ohos.file.fs';
import { UserModel } from '../viewmodel/UserModel';

/**
 * Personal Center page, displaying personal information and app-related settings.
 */
@Entry
@Component
struct SyncServicePage {
  private userModel: UserModel | undefined;
  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  build() {
    Column() {
      TitleWithBack({ title: "NosService" })
      Scroll(){
        GridRow({
          columns: {
            sm: CommonConstants.GRID_ROW_SM,
            md: CommonConstants.GRID_ROW_MD,
            lg: CommonConstants.GRID_ROW_LG
          },
          gutter: { x: CommonConstants.GUTTER_X },
          breakpoints: { value: CommonConstants.BREAK_POINT }
        }) {
          GridCol({
            span: {
              sm: CommonConstants.MINE_SPAN_SM,
              md: CommonConstants.MINE_SPAN_MD,
              lg: CommonConstants.MINE_SPAN_LG
            },
            offset: {
              lg: CommonConstants.OFFSET_LG
            }
          }) {
            Column(){
              Button('上传文件')
                .width(CommonConstants.BUTTON_WIDTH_PERCENT)
                .height($r('app.float.login_btn_height'))
                .borderRadius($r('app.float.login_btn_border_radius'))
                .fontSize($r('app.float.text_input_font_size'))
                .margin({ top: $r('app.float.register_btn_margin_top') })
                .fontWeight(CommonConstants.LOGIN_TEXT_FONT_WEIGHT)
                .fontColor(Color.White)
                .backgroundColor($r('app.color.login_btn_enabled'))
                .onClick(() => {
                  const fileDir = getContext(this).getApplicationContext().filesDir
                  // const file = fs.openSync(fileDir + '/TextDir/nim_1_17_2024.txt')
                  const file = fs.openSync(fileDir + '/2309.17421.pdf')
                  const options = {
                    file: file,
                    onUploadProgress: (progress: UploadFileProgress) => {
                      console.info(`onUploadProgress: ${JSON.stringify(progress)}`)
                    }
                  } as UploadFileOptions
                  this.getUserModel().getNimSdk().httpService.uploadFile(options)
                    .then(
                      (result: UploadFileResult) => {
                        AlertDialog.show(
                          {
                            title: '上传成功',
                            message: JSON.stringify(result),
                            autoCancel: true,
                            alignment: DialogAlignment.Bottom,
                            offset: { dx: 0, dy: -20 },
                            gridCount: 3,
                            confirm: {
                              value: 'OK',
                              action: () => {
                                console.info('Button-clicking callback')
                              }
                            },
                            cancel: () => {
                              console.info('Closed callbacks')
                            }
                          }
                        )
                        console.log(`downloadUrl: ${JSON.stringify(result)}`)
                      }
                    )
                    .catch((error: Error) => {
                      AlertDialog.show(
                        {
                          title: '上传失败',
                          message: JSON.stringify(error),
                          autoCancel: true,
                          alignment: DialogAlignment.Bottom,
                          offset: { dx: 0, dy: -20 },
                          gridCount: 3,
                          confirm: {
                            value: 'OK',
                            action: () => {
                              console.info('Button-clicking callback')
                            }
                          },
                          cancel: () => {
                            console.info('Closed callbacks')
                          }
                        }
                      )
                      console.log(`error: ${error} ${JSON.stringify(error)}`)
                    })
                })
            }
            .width(CommonConstants.MINE_PAGE_WIDTH_PERCENT)
            .height(CommonConstants.MINE_PAGE_HEIGHT_PERCENT)
          }
        }
        .margin({
          left: $r('app.float.user_grid_row_margin'),
          right: $r('app.float.user_grid_row_margin')
        })
      }
      .margin({ top: $r('app.float.profile_image_margin_top') })
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.login_page_background'))
  }
}