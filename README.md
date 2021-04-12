# openinstall-unity-sdk
 方便 unity 集成使用 openinstall
	
## 导入 openinstall.unitypackage
右击 `Assets` ，选择 `Import Package` 中的 `Custom Package...`    

在文件选择框中选中 `openinstall.unitypackage`，导入所有文件

将 `Assets/Plugins/OpenInstall` 下的 `OpenInstall.prefab` 拖入对应的场景中使用 openinstall 实现业务逻辑

## 平台配置
#### 请根据`使用指南`来做对应配置

### iOS 平台

无需写一句Object-C代码，只需进行如下配置  

_备注_：  
- 如果用户使用了 `IMPL_APP_CONTROLLER_SUBCLASS` 宏生成自己的 `customAppController`文件（或其它自定义名称）,请在该文件中添加一键跳转的回调方法，并删除掉 `Assets/Plugins/iOS/libs` 中的 `CustomAppController.mm` 文件；  

##### 初始化配置

在 Info.plist 文件中配置 appKey 键值对，如下：
``` xml
<key>com.openinstall.APP_KEY</key>
<string>从openinstall官网后台获取应用的appkey</string>
```

#### 以下为iOS一键拉起功能相关配置
##### universal links配置（iOS9以后推荐使用）

对于iOS，为确保能正常跳转，AppID必须开启Associated Domains功能，请到[苹果开发者网站](https://developer.apple.com)，选择Certificate, Identifiers & Profiles，选择相应的AppID，开启Associated Domains。注意：当AppID重新编辑过之后，需要更新相应的mobileprovision证书。(图文配置步骤请看[Unity3d接入指南](https://www.openinstall.io/doc/unity3d_sdk.html))，如果已经开启过Associated Domains功能，进行下面操作：  

- 在左侧导航器中点击您的项目
- 选择 `Capabilities` 标签
- 打开 `Associated Domains` 开关
- 添加 openinstall 官网后台中应用对应的关联域名（openinstall应用控制台->iOS集成->iOS应用配置->关联域名(Associated Domains)）

**以下配置为可选项**  
openinstall可兼容微信openSDK1.8.6以上版本的通用链接跳转功能，注意微信SDK初始化方法中，传入正确格式的universal link链接：  

``` objc
//your_wxAppID从微信后台获取，yourAppkey从openinstall后台获取
[WXApi registerApp:@"your_wxAppID" universalLink:@"https://yourAppkey.openinstall.io/ulink/"];
```

微信开放平台后台Universal links配置，要和上面代码中的保持一致  

![微信后台配置](res/wexinUL.jpg)

- 微信SDK更新参考[微信开放平台更新文档](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html)  

##### scheme配置

在 `Info.plist` 文件中，在 `CFBundleURLTypes` 数组中添加应用对应的 `scheme`，或者在工程“TARGETS-Info-URL Types”里快速添加，图文配置请看[Unity3d接入指南](https://www.openinstall.io/doc/unity3d_sdk.html)  
（scheme的值详细获取位置：openinstall应用控制台->iOS集成->iOS应用配置）

``` xml
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

### Android 平台

##### 简单配置
将 `sample/Android` 目录中的 `AndroidManifest.xml` 文件拷贝到项目的 `Assets/Plugin/Android/` 目录下，并修改文件内容：**将 openinstall 为应用分配的 `appkey` 和 `scheme` 替换至相应位置**  
(scheme的值详细获取位置：openinstall应用控制台->Android集成->Android应用配置)

##### 自定义配置
1. 如果项目已存在自己的 `AndroidManifest.xml` 文件，根据下图标注的内容做相应的更改
![AndroidManifest.xml修改](res/AndroidManifest.png)  

2. 如果需要使用自己的拉起 `Activity` ，可参考 `sample/Android/src` 目录中的 `OiUnityActivity.java` 在拉起 `Activity` 的 `onCreate(Bundle savedInstanceState)` 和 `onNewIntent(Intent intent)` 中添加拉起处理代码

## 使用指南
### 导入命令空间并获取实例
使用 `OpenInstall` 之前，请先导入命名空间
``` c
using io.openinstall.unity;
```
然后通过 `GameObject` 获取 `OpenInstall` 实例
``` c
private OpenInstall openinstall;
void Start () {
    openinstall = GameObject.Find("OpenInstall").GetComponent<OpenInstall>();
}
```
#### 1 初始化
确保用户同意《隐私政策》之后，再初始化 openinstall。参考 [应用合规指南](https://www.openinstall.io/doc/rules.html)
```
openinstall.Init(false);
```

#### 2 快速下载
如果只需要快速下载功能，无需其它功能（携带参数安装、渠道统计、一键拉起），完成初始化相关工作即可


#### 3 一键拉起
##### 完成文档前面iOS和Android介绍的一键拉起相关配置

##### 获取拉起数据
在 `Start` 方法中，获取到实例之后注册拉起回调，这样当 App 被拉起时，会回调方法，并可在回调中获取拉起数据
``` c
openinstall.RegisterWakeupHandler(getWakeupFinish);
```
``` c
public void getWakeupFinish(OpenInstallData wakeupData)
{
    Debug.Log("OpenInstallUnity getWakeupFinish : 渠道编号=" +wakeupData.channelCode 
            + "， 自定义数据=" + wakeupData.bindData);
}
```

#### 4 携带参数安装（高级版功能）
##### 获取安装数据
在应用需要安装参数时，调用以下 api 获取由 SDK 保存的安装参数，可设置超时时长（一般为8～15s），单位秒
``` c
openinstall.GetInstall(10, getInstallFinish);
```
``` c
public void getInstallFinish(OpenInstallData installData)
{
    Debug.Log("OpenInstallUnity getInstallFinish : 渠道编号=" + installData.channelCode 
            + "，自定义数据=" + installData.bindData);
}
```
_备注_：  
- 注意这个安装参数尽量不要自己保存，在每次需要用到的时候调用该方法去获取，因为如果获取成功sdk会保存在本地  
- 该方法可重复获取参数，如需只要在首次安装时获取，可设置标记，详细说明可参考openinstall官网的常见问题

#### 5 渠道统计（高级版功能）
##### SDK 会自动完成访问量、点击量、安装量、活跃量、留存率等统计工作。其它业务相关统计由开发人员代码埋点上报

##### 5.1 注册上报
在用户注册成功后，调用接口上报注册量
``` c
openinstall.ReportRegister();
```
##### 5.2 效果点上报
统计终端用户对某些特殊业务的使用效果，如充值金额，分享次数等等。调用接口前，请先进入 openinstall 管理后台 “效果点管理” 中添加效果点，第一个参数对应管理后台 效果点ID
``` c
openinstall.ReportEffectPoint("effect_test", 1);
```

## 导出apk/api包并上传
- 代码集成完毕后，需要导出安装包上传openinstall后台，openinstall会自动完成所有的应用配置工作。  
- 上传完成后即可开始在线模拟测试，体验完整的App安装/拉起流程；待测试无误后，再完善下载配置信息。  

下面是apk包的上传界面（后台截图）：  

![上传安装包](res/guide2.jpg)

## 广告补充文档
### Android 平台
1、针对广告平台接入，新增配置接口，在调用 init 之前调用。参考 [广告平台对接Android集成指引](https://www.openinstall.io/doc/ad_android.html)
``` js
    OpenInstallParam param = new OpenInstallParam();
    // adEnabled 为 true 表示 openinstall 需要获取广告追踪相关参数，默认为 false
    param.adEnabled = true;
    // oaid 为 null 时，表示交由 openinstall 获取 oaid， 默认为 null
    param.oaid = "通过移动安全联盟获取到的 oaid";
    // gaid 为 null 时，表示交由 openinstall 获取 gaid， 默认为 null
    param.gaid = "通过 google api 获取到的 advertisingId";
    openinstall.Config(param);
```

2、为了精准地匹配到渠道，需要获取设备唯一标识码（IMEI），因此需要做额外的权限申请  
在 AndroidManifest.xml 中添加权限声明 
``` xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```
3、允许插件申请权限并初始化
``` js
    /**
    * 调用初始化，允许 openinstall 请求权限
    * permission 为 true，表示允许 openinstall 申请权限，以便获取 imei
    */
    openinstall.Init(true);
```
### iOS平台
方式一：Unity层传入idfa等参数  
针对广告平台接入，新增配置 Config 接口，在调用 Init 之前调用:    
``` js
    OpenInstallParam param = new OpenInstallParam();
	param.idfa = "获取的idfa值";
    openinstall.Config(param);
```
方式二：直接原生层修改  
1、替换为集成了idfa的代码文件：  

在完成导入openinstall.unitypackage包后，将 `Assets/Plugins/iOS/libs` 目录下的 `OpenIsntallUnity3DBridge.m` 文件，替换为 `sample/iOS/ad-track/` 目录下的 `OpenIsntallUnity3DBridge.m` 文件  

2、参考官网文档，配置plist：  

参考[iOS集成指南](https://www.openinstall.io/doc/ad_ios.html)，开启后台开关，并配置Info.plist文件，添加IDFA的权限申请描述，详细如下：  

```xml
<key>NSUserTrackingUsageDescription</key>
<string>通过后可用于广告的追踪定位</string>
```
