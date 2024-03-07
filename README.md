# 快速入门

本文介绍在鸿蒙平台下如何快速集成云信 NIMSDK 到项目中。

## 环境要求

- DevEco Studio NEXT Developer Preview1 及以上。
- HarmonyOS SDK API 11 及以上。

## 操作步骤

### 步骤1: 创建应用

创建应用，详情官方文档：[点这里](https://netease.im/)


### 步骤2： 编译运行

1.打开 NIMAPIDemo 配置签名：



2.连接真机，编译运行:


## DEMO 使用

demo 提供 IM 个业务模块 API 的调用事例，便于开发者快速了解 api 的使用方式，下载 demo 代码后，可以直接在模拟器上运行，真机运行参考： 【编译运行】

demo 运行进入登陆界面进行登陆：
体验 demo 可以将 用户名：cjl 秘密： 123456 输入进行登陆：

### Demo 功能模块
#### 登陆界面
<img src="./Image/login.png" width = "200" height = "400" alt="图片名称" align=center />

### 登陆后，显示对应API 使用界面
#### 会话接口
<img src="./Image/conversation.png" width = "200" height = "400" alt="图片名称" align=center />

#### 消息接口
<img src="./Image/message.png" width = "200" height = "400" alt="图片名称" align=center />

#### 群接口
<img src="./Image/team.png" width = "200" height = "400" alt="图片名称" align=center />

#### 用户&好友接口
<img src="./Image/user.png" width = "200" height = "400" alt="图片名称" align=center />

以上界面对应的功能接口，都有单独的功能页面进行实现，在接入sdk 时，可以找的对应的接口，进行参考使用。

## SDK 接入流程

1.拷贝 sdk.har 到项目文件夹中，例如： entry/src/main/libs

2.DEMO 工程下 oh-package.json5 配置 sdk.har 如下图所示：


3.安装第三方包，点击 Run 'ohpm install'


4.调用SDK接口，完成入会流程


## 问题反馈

如果您在使用过程中，有任何疑问都可以直接在本工程上提交 issue，或者在云信官网进行咨询。
