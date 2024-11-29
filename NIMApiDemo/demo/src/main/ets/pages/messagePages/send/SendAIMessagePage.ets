import {
    V2NIMAIModelCallMessage,
    V2NIMAIModelConfigParams, V2NIMConversationType,
    V2NIMError,
    V2NIMMessage,
    V2NIMMessageAIConfigParams, V2NIMSendMessageParams,
    V2NIMSendMessageResult
} from '@nimsdk/base';

import { CommonConstants, shownDialog } from '../../../common/CommonConstants';
import { UserModel } from '../../../viewmodel/UserModel';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color')).
  height($r('app.float.login_input_height')).
  fontSize($r('app.float.big_text_size')).
  backgroundColor($r('app.color.background')).
  width(CommonConstants.FULL_PARENT).
  padding({ left: CommonConstants.INPUT_PADDING_LEFT }).
  margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT).height($r('app.float.line_height')).backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_text_color')).
  fontSize($r('app.float.small_text_size')).
  fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct SendAIMessagePage {
  @State conversationId: string = '';
  @State conversationType: V2NIMConversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
  @State text: string = ''
  private accountId: string = ''
  /**
   * 请求/响应的文本内容
   */
  private msg?: string
  /**
   * 类型, 暂时只有 0, 代表文本
   */
  private type?: number
  /**
   * 上下文内容的角色.
   *
   * 注: 请开发者自行判定自己发的消息选 user, 若是机器人发的消息是选 assistant
   */
  private role?: string
  /**
   * 提示词
   */
  private prompt?: string
  /**
   * 模型最大tokens数量
   */
  private maxTokens?: number
  /**
   * 核采样方法的概率阈值
   */
  private topP?: string
  /**
   * 随机性和多样性的程度值
   */
  private temperature?: string
  /**
   * 提示词变量占位符替换. JSON 序列化的字符串
   *
   * 注: 如果 V2NIMAIUser 中的 modelConfig.promptKeys 存在且数组长度不为 0 ，则必填.
   */
  private promptVariables?: string

  @Builder
  imageButton(src: Resource) {
    Button({ type: ButtonType.Circle, stateEffect: true }
    ) {
      Image(src)
    }.
    height($r('app.float.other_login_image_size')).
    width($r('app.float.other_login_image_size')).
    backgroundColor($r('app.color.background'))
  }

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this).getApplicationContext());
  }

  async sendAIMessage(): Promise<void> {
    try {
      console.info(`-----------sendAIMessage----------- \n`)
      let conversationId: string = this.getConversationId()
      let messageService = this.getUserModel().getNimSdk().messageService! // Demo启用message模块，messageService不为空
      const messageCreator = this.getUserModel().getNimSdk().messageCreator
      let message: V2NIMMessage = messageCreator.createTextMessage(this.text)

      const aiParams = {} as V2NIMMessageAIConfigParams
      aiParams.accountId = this.accountId
      aiParams.content = {
        msg: this.msg ?? '',
        type: this.type ?? 0
      }

      const aiMessage = {
        role: this.role,
        msg: this.msg,
        type: this.type
      } as V2NIMAIModelCallMessage

      aiParams.messages = [aiMessage]

      aiParams.promptVariables = this.promptVariables

      aiParams.modelConfigParams = {
        prompt: this.prompt,
        maxTokens: this.maxTokens,
        topP: this.topP,
        temperature: this.temperature
      } as V2NIMAIModelConfigParams

      const sendParams = {} as V2NIMSendMessageParams
      sendParams.aiConfig = aiParams

      let messageResult: V2NIMSendMessageResult = await messageService.sendMessage(message, conversationId, sendParams)
      shownDialog(true, JSON.stringify(messageResult, null, 2))
    } catch (error) {
      shownDialog(false, processV2ErrorForPrint(error))
    }
  }

  getConversationId(): string {
    let conversationId = ''
    switch (this.conversationType) {
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.p2pConversationId(this.conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.teamConversationId(this.conversationId)
        break
      case V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM:
        conversationId = this.getUserModel().getNimSdk().conversationIdUtil.superTeamConversationId(this.conversationId)
        break
    }

    return conversationId
  }

  aboutToAppear() {
    this.conversationId = ''
  }

  build() {
    Row() {
      Navigation() {
        Scroll() {
          Column() {
            Text('SendAIMessage').
              fontSize($r('app.float.page_title_text_size')).
              fontWeight(FontWeight.Medium).
              fontColor($r('app.color.title_text_color'))

            TextInput({ text: this.conversationId, placeholder: this.conversationId }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.conversationId = value;
              }
              )
            Line().lineStyle()

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'p2p', group: 'conversationTypeGroup' }).checked(true).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_P2P
                }
              }
              )
              Text('p2p').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'team', group: 'conversationTypeGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_TEAM
                }
              }
              )
              Text('team').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Radio({ value: 'superTeam', group: 'conversationTypeGroup' }).onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.conversationType = V2NIMConversationType.V2NIM_CONVERSATION_TYPE_SUPER_TEAM
                }
              }
              )
              Text('superTeam').
                fontSize($r('app.float.normal_text_size')).
                fontColor($r('app.color.login_more_text_color')).
                lineHeight(20).
                fontWeight(500)
            }

            Line().lineStyle()

            TextInput({ placeholder: `send message text ` }).
              maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.text = value;
              }
              )

            Line().lineStyle()

            TextInput({ text: this.accountId, placeholder: `accountId` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.accountId = value;
              }
              )

            TextInput({ text: this.msg, placeholder: `请求/响应的文本内容` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.msg = value;
              })

            TextInput({ text: this.msg, placeholder: `类型, 暂时只有 0, 代表文本` }).
              type(InputType.Number).
              inputStyle().
              onChange((value: string) => {
                this.type = parseInt(value);
              })

            Button('选择上下文内容的角色').bindMenu([
              {
                value: 'system',
                action: () => {
                  this.role = 'system'
                }
              },
              {
                value: 'user',
                action: () => {
                  this.role = 'user'
                }
              },
              {
                value: 'assistant',
                action: () => {
                  this.role = 'assistant'
                }
              }
            ])

            TextInput({ text: this.msg, placeholder: `提示词` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.prompt = value;
              })

            TextInput({ text: this.msg, placeholder: `模型最大tokens数量.` }).
              type(InputType.Number).
              inputStyle().
              onChange((value: string) => {
                this.maxTokens = parseInt(value);
              })

            TextInput({ text: this.msg, placeholder: `核采样方法的概率阈值` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.topP = value;
              })
            TextInput({ text: this.msg, placeholder: `随机性和多样性的程度值` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.temperature = value;
              })

            TextInput({ text: this.msg, placeholder: `提示词变量占位符替换. JSON 序列化的字符串` }).
              type(InputType.Normal).
              inputStyle().
              onChange((value: string) => {
                this.promptVariables = value;
              })
            Line().lineStyle()

            Button(('SendAIMessage'), { type: ButtonType.Capsule }).
              width(CommonConstants.BUTTON_WIDTH).
              height($r('app.float.login_button_height')).
              fontSize($r('app.float.normal_text_size')).
              fontWeight(FontWeight.Medium).
              backgroundColor($r('app.color.login_button_color')).
              margin({
                top: $r('app.float.button_margin_top'),
                bottom: $r('app.float.login_button_margin_bottom')
              }
              ).
              onClick(() => {
                this.sendAIMessage()
              }
              )
            Blank()
          }.backgroundColor($r('app.color.background'))
          // .height(CommonConstants.FULL_PARENT)
          .width(CommonConstants.FULL_PARENT).padding({
            left: $r('app.float.page_padding_hor'),
            right: $r('app.float.page_padding_hor'),
            bottom: $r('app.float.login_page_padding_bottom')
          }
          )
        }
      }.
      size({ width: CommonConstants.THOUSANDTH_1000, height: CommonConstants.THOUSANDTH_1000 }).
      title('back').
      titleMode(NavigationTitleMode.Mini)
    }.height(CommonConstants.THOUSANDTH_1000).backgroundColor($r('app.color.primaryBgColor'))
  }
}

function processV2ErrorForPrint(err: V2NIMError): string {
  if (err instanceof Error) {
    let desc = `\n${err.name}\n code: ${err.code}\n message: "${err.message}"\n detail: ${err.detail ?
    JSON.stringify(err.detail) : ''}`
    if (err?.detail?.rawError) {
      desc += `\n rawError: ${err.detail.rawError.message}`
    }
    return desc
  } else {
    return `Caught an exception: ${err}`
  }
}

function getRandomNumber(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}