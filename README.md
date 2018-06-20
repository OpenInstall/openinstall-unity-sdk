
## 导入 openinstall.unitypackage
右击 `Assets` ，选择 `Import Package` 中的 `Custom Package...`    

在文件选择框中选中 `openinstall.unitypackage`，导入所有文件

将 `Assets/Plugins/OpenInstall` 下的 `OpenInstall.prefab` 拖入对应的场景中使用 openinstall 实现业务逻辑

## 平台配置

#### iOS 平台

无需写一句Object-C代码，只需进行如下配置  

_备注（例外）：  
1、如果用户使用了 `IMPL_APP_CONTROLLER_SUBCLASS` 宏生成自己的 `customAppController`,请在自己的 `customAppController` 中添加初始化方法和拉起回调方法，并删除掉 `Assets/Plugins/iOS/libs` 中的 `CustomAppController.mm` 文件；  
2、如果用户使用了 iOS9.0 新 API `application:openURL:options:`，请在新 API 中添加 `if ([OpenInstallSDK handLinkURL:url]) return YES;` 回调判断_

##### 初始化配置

在 Info.plist 文件中配置 appKey 键值对，如下：
``` plist
<key>com.openinstall.APP_KEY</key>
<string>从openinstall官网后台获取应用的appkey</string>
```
##### universal links配置（iOS9以后推荐使用）

对于iOS，为确保能正常跳转，AppID必须开启 Associated Domains 功能，请到 [苹果开发者平台](https://developer.apple.com)，选择 `Certificate, Identifiers & Profiles`，选择相应的 AppID，开启 Associated Domains。注意：当AppID重新编辑过之后，需要更新相应的 mobileprovision 证书。(详细步骤请看[openinstall官网](https://www.openinstall.io)后台文档，universal link从后台获取)

##### scheme配置

在 `Info.plist` 文件中，在 `CFBundleURLTypes` 数组中添加应用对应的 `scheme`

``` plist
	<key>CFBundleURLTypes</key>
	<array>
	    <dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>openinstall</string>
		<key>CFBundleURLSchemes</key>
		<array>
		    <string>"从openinstall官网后台获取应用的scheme"</string>
		</array>
	    </dict>
	</array>
```

#### Android 平台
将 sample 目录中的 `AndroidManifest.xml` 文件拷贝到项目的 `Assets/Plugin/Android/` 目录下，并修改文件内容：将 openinstall 为应用分配的 `appkey` 和 `scheme` 替换至相应位置

## 使用指南

使用 `OpenInstall` 之前，请先导入命名空间
``` c
using io.openinstall.unity;
```
然后通过 `GameObject` 获取 `OpenInstall` 实例
``` c
private OpenInstall openinstall;
// Use this for initialization
void Start () {
    openinstall = GameObject.Find("OpenInstall").GetComponent<OpenInstall>();
}
```

#### 获取拉起数据
在 `Start` 方法中，获取到实例之后注册拉起回调，这样当 App 被拉起时，会回调方法，并可在回调中获取拉起数据
``` c
openinstall.registerWakeupHandler(getWakeupFinish);
```
``` c
public void getWakeupFinish(OpenInstallData wakeupData)
{
    Debug.Log("OpenInstallUnity getWakeupFinish : 渠道编号=" +wakeupData.channelCode 
            + "， 自定义数据=" + wakeupData.bindData);
}
```
#### 获取安装数据
在应用需要安装参数时，调用以下 api 获取由 SDK 保存的安装参数，可设置超时时长，单位秒
``` c
openinstall.getInstall(8, getInstallFinish);
```
``` c
public void getInstallFinish(OpenInstallData installData)
{
    Debug.Log("OpenInstallUnity getInstallFinish : 渠道编号=" + installData.channelCode 
            + "，自定义数据=" + installData.bindData);
}
```
#### 渠道统计
SDK 会自动完成访问量、点击量、安装量、活跃量、留存率等统计工作。其它业务相关统计由开发人员代码埋点上报
##### 注册上报
在用户注册成功后，调用接口上报注册量
``` c
openinstall.reportRegister();
```
##### 效果点上报
统计终端用户对某些特殊业务的使用效果，如充值金额，分享次数等等。调用接口前，请先进入 openinstall 管理后台 “效果点管理” 中添加效果点，第一个参数对应管理后台 效果点ID
``` c
openinstall.reportEffectPoint("effect_test", 1);
```