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

- 真机华为 Mate 系列
- 操作系统 HarnomyOS NEXT 2.1.2.5 (Canary1) 以上

> 于“设置”->“关于手机”页面查看
  
## 操作步骤

### 步骤1：创建应用

创建应用，详情官方文档：[点这里](https://netease.im/)

### 步骤2：编译运行

1.打开 NIMAPIDemo 配置签名：

当前 NIMAPIDemo 已经配置好 Huawei Phone 模拟器与部分网易内部 HarmonyOS NEXT 真机的安装证书与 Profile，支持所有模拟器安装应用。若期望将证书移动到私有华为开发者账号体系下，需要按照一下步骤自动生成。更详细步骤详见 [华为-创建 HarmonyOS 应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createapp-0000001146718717)

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


<a name="build-for-use"></a>
### 步骤3：真机运行（可跳过）

如需真机安装，需在以下配置后编译运行，若无需要，可直接跳转至 [Demo 使用](#use-demo):

> PS：真机能否安装依赖 build-profile.json5 中的证书与 Profile 文件配置，

#### 基本概念
##### 密钥(.p12)
包含非对称加密中使用的公钥和私钥，存储在密钥库文件中，格式为.p12，公钥和私钥对用于数字签名和验证。
##### 证书请求文件(.csr)
格式为.csr，全称为Certificate Signing Request，包含密钥对中的公钥和公共名称、组织名称、组织单位等信息，用于向AppGallery Connect申请数字证书。
##### 数字证书(.cer)
格式为.cer，由华为AppGallery Connect颁发。
##### Profile文件(.p7b)
格式为.p7b，包含HarmonyOS应用/服务的包名、数字证书信息、描述应用/服务允许申请的证书权限列表，以及允许应用/服务调试的设备列表（如果应用/服务类型为Release类型，则设备列表为空）等内容，每个应用/服务包中均必须包含一个Profile文件。

#### Generate Key(.p12) + Generate CSR(.csr)
主要分为两步，Generate Key(.p12) + Generate CSR(.csr)，IDE 提供了一个入口生成两个文件。

- 使用 IDE DevEco Studio -> Build -> Generate Key and CSR 按需填入
Key Store File：设置密钥库文件存储路径，并填写p12文件名。
- Key Store Password：设置密钥库密码，必须由大写字母、小写字母、数字和特殊符号中的两种以上字符的组合，长度至少为8位。请记住该密码，后续签名配置需要使用。
- Alias：密钥的别名信息，用于标识密钥名称。请记住该别名，后续签名配置需要使用。也是 Key alias
- Password：密钥对应的密码，与密钥库密码保持一致，无需手动输入。也是 Key password。**完成 .p12 创建 （1/4）**
![apply_profile_1.png](Image/apply_profile_1.png)
- Generate Key and CSR界面，设置CSR文件存储路径和CSR文件名。**完成 .csr 创建 （2/4）**
![apply_profile_2.png](Image/apply_profile_2.png)

#### Generate Certificaiton(.cer)
在 AppGallery Connect 平台使用上一步申请的 .csr 生成 .cer，再用 .cer 生成 .p7b

- 登录AppGallery Connect，选择“用户与访问”。
![apply_profile_3.png](Image/apply_profile_3.png)
- 在左侧导航栏选择“证书管理”，进入证书管理页面，点击“新增证书”。
![apply_profile_4.png](Image/apply_profile_4.png)
- 在弹出的“新增证书”窗口，填写要申请的证书信息，点击“提交”。
- 证书类型：调试证书（有效期 1 年）；发布证书（有效期 3 年）。
- 选取证书申请文件（CSR）：传入本机生成的 .csr 文件
- **完成 .cer 创建（3/4）**，需下载后配置
![apply_profile_5.png](Image/apply_profile_5.png)

#### Generate Profile(.p7b)

在 AppGallery Connect 平台使用上一步申请的 .csr 生成 .cer，再用 .cer 生成 .p7b

- 登录AppGallery Connect
- 点击“我的项目”，找到自己的项目，点击创建完成的HarmonyOS应用；
- 关注左侧导航栏，选择“HarmonyOS应用 > HAP Provision Profile管理
- 点击“添加”，添加“发布”或“调试” Profile 文件
	- 发布：选择 .cer 发布证书
	- 调试：选择 .cer 调试证书，并指定调试设备（真机需要在注册在当前开发账户，模拟器不受限制）
- **完成 .p7b 创建（4/4）**，需下载后配置

![apply_profile_6.png](Image/apply_profile_6.png)

#### 配置签名信息

“准备签名文件”的步骤拿到 4 个重要签名文件，分别作用：

- .p12：本地保存，工程项目配置（重要）
- .csr：本地保存，用户上传 AppGallery Connect -> 用户与访问 -> 证书管理 -> 生成 .cer
- .cer：AppGallery Connect 保存，开发证书，下载后用于工程项目配置
- .p7b：AppGallery Connect 保存，Profile 文件，下载后用于工程项目配置

使用制作的私钥（.p12）文件、在AppGallery Connect中申请的证书（.cer）文件和Profile（.p7b）文件，在DevEco Studio配置工程的签名信息，构建携带发布签名信息的APP。

用 DevEco Studio 打开自己的鸿蒙工程，在 File > Project Structure > Project > Signing Configs > default界面中，取消“Automatically generate signature”勾选项，然后配置工程的签名信息。需要注意的是，除了传入 .p12, .cer, .p7b 以外，需要填入创建 .p12 时的 Key alias 和 Key password，具体规则如下：
> 注意此时要取消“Automatically generate signature”勾选项

![apply_profile_7.png](Image/apply_profile_7.png)

* Store File：选择密钥库文件，文件后缀为.p12。
* Store Password：输入密钥库密码。
* Key Alias：输入密钥的别名信息。
* Key Password：输入密钥的密码。
* Sign Alg：签名算法，固定为SHA256withECDSA。
* Profile File：选择申请的发布Profile文件，文件后缀为.p7b。
* Certpath File：选择申请的发布数字证书文件，文件后缀为.cer。
* OK
* 配置完毕后，Project 的 build-profile.json5 能查看配置结果

#### 配置签名证书指纹

见文档，[“配置签名证书指纹”章节](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/configure-0000001709533666-V2#section081064303716)

* 登录 AppGallery Connect 网站，点击“我的项目”。
* 在项目列表中找到您的项目，在项目中点击需要配置签名证书指纹的应用。
* 在“项目设置 > 常规”页面的“应用”区域，点击“SHA256证书指纹”后的“添加公钥指纹 (HarmonyOS API 9及以上)”生成

#### 配置Client ID

见文档，[“配置Client ID”章节](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V2/configure-0000001709533666-V2#section93453261371)

* 登录AppGallery Connect网站，选择“我的项目”，在项目列表中找到您的项目，下拉页面，获取Client ID。
![apply_profile_8.png](Image/apply_profile_8.png)
* 在工程中entry模块的module.json5文件中，新增metadata并配置client_id，如下所示：
```
"module": {
  "name": "entry",
  "type": "xxx",
  "description": "xxxx",
  "mainElement": "xxxx",
  "deviceTypes": [],
  "pages": "xxxx",
  "abilities": [],
  "metadata": [ // 配置如下信息
    {
      "name": "client_id",
      "value": "xxxxxx"  // 配置为截图中的Client ID
    }
    {
      "name": "app_id",
      "value": "xxxxxx"  // 配置为截图中的 APP ID
    }
  ]
}
```


> 更详细步骤详见 [华为-调试与发布 HarmonyOS 应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-harmonyos-releaseapp-0000001126380068)

## SDK 接入流程
1. 拷贝 sdk har 包到项目文件夹中，例如： entry/libs

   ![libs](Image/sdk_libs.png)

2. DEMO 工程下 oh-package.json5 配置 har 包依赖

   ![dependencies](Image/sdk_dependencies.png)

3. 安装第三方包，点击 Run 'ohpm install'

   ![run_ohmp_install](Image/sdk_run_ohmp_install.png)

4. 同步项目工程，点击 Sync Now

   ![sync_now](Image/sdk_sync_now.png)

5. 源代码引入SDK，创建SDK实例

   ![import](Image/sdk_import.png)

   ![instance](Image/sdk_instance.png)

6. 通过SDK实例获取各业务service，通过业务service进行功能开发

   ![service](Image/sdk_service.png)


<a name="use-demo"></a>
## DEMO 使用


demo 提供 IM 个业务模块 API 的调用事例，便于开发者快速了解 api 的使用方式，下载 demo 代码后，可以直接在模拟器上运行，参考：[真机运行](#build-for-use)

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

#### 离线推送
![push.png](Image/push.png)

以上界面对应的功能接口，都有单独的功能页面进行实现，在接入sdk 时，可以找的对应的接口，进行参考使用。


## 问题反馈

如果您在使用过程中，有任何疑问都可以直接在本工程上提交 issue，或者在云信官网进行咨询。

## 参考
[云信官网](https://netease.im/)

[鸿蒙开发官网](https://developer.harmonyos.com/)
