# 快速入门

本文介绍在鸿蒙平台下如何快速集成云信 NIMSDK 到项目中:
1. 环境要求&真机调试
2. SDK 接入流程
3. Demo 使用
   
通过以上步骤，您可以基本了解鸿蒙NIMSDK 的接入与使用。

## 环境要求
### 编译器
- DevEco Studio NEXT Developer Preview1（4.1.3.500） 及以上。
- HarmonyOS SDK API 11 及以上。
### 设备
- 鸿蒙
  
## 操作步骤

### 步骤1: 创建应用

创建应用，详情官方文档：[点这里](https://netease.im/)


### 步骤2： 编译运行

1.打开 NIMAPIDemo 配置签名：

DevEcho-Studio -> File -> Project Structure
![sign_config_1.png](Image/sign_config_1.png)
Project Structure -> Project -> Signing Configs
![sign_config_2.png](Image/sign_config_2.png)
Signing Configs -> check "Automatically generate signature" -> click "Sing in" 登录授权的华为开发者账号
![sign_config_3.png](Image/sign_config_3.png)
在弹出的浏览器页面点击“允许”，许可颁布应用调试证书
![sign_config_4.png](Image/sign_config_4.png)
显示此页面时，即代表配置完成
![sign_config_5.png](Image/sign_config_5.png)
选择名称为“NIMAPIDemo”的应用和名为“”模拟器后，点击 ▶ 即可在模拟器运行 HarmonyOS NIMSDK API Demo ！
![sign_config_6.png](Image/sign_config_6.png)


2.连接真机，编译运行:

## SDK 接入流程

1.拷贝 sdk.har 到项目文件夹中，例如： entry/src/main/libs

2.DEMO 工程下 oh-package.json5 配置 sdk.har 如下图所示：


3.安装第三方包，点击 Run 'ohpm install'


4.调用SDK接口，完成入会流程

## DEMO 使用

demo 提供 IM 个业务模块 API 的调用事例，便于开发者快速了解 api 的使用方式，下载 demo 代码后，可以直接在模拟器上运行，真机运行参考： 【编译运行】

demo 运行进入登陆界面进行登陆：
体验 demo 可以将 用户名：cjl 秘密： 123456 输入进行登陆：

### Demo 功能模块
#### 登陆界面
![login.png](Image/login.png)

#### 会话接口
![conversation.png](Image/conversation.png)

#### 消息接口
![message.png](Image/message.png)

#### 群接口
![team.png](Image/team.png)

#### 用户&好友接口
![user.png](Image/user.png)

以上界面对应的功能接口，都有单独的功能页面进行实现，在接入sdk 时，可以找的对应的接口，进行参考使用。


## 问题反馈

如果您在使用过程中，有任何疑问都可以直接在本工程上提交 issue，或者在云信官网进行咨询。

## 参考
[云信官网](https://netease.im/)

[鸿蒙开发官网](https://developer.harmonyos.com/)
