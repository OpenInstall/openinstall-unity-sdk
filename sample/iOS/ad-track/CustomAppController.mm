//
//  CustomAppController.m
//  Unity-iPhone
//
//  Created by cooper on 2018/6/15.
//

#import "UnityAppController.h"
#import "OpenInstallSDK.h"
#import "OpenInstallUnity3DCallBack.h"
#include "PluginBase/AppDelegateListener.h"
#import <AdSupport/AdSupport.h>//需要使用idfa时引入
#if defined(__IPHONE_14_0)
#import <AppTrackingTransparency/AppTrackingTransparency.h>//适配iOS14
#endif

@interface CustomAppController : UnityAppController<AppDelegateListener>

@end

//如果用户使用了IMPL_APP_CONTROLLER_SUBCLASS宏生成自己的customAppController,请删除该文件，并在自己的customAppController中添加如下初始化和拉起回调，或者按照官网iOS原生的集成方法集成
IMPL_APP_CONTROLLER_SUBCLASS(CustomAppController)

@implementation CustomAppController

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
#if defined(__IPHONE_14_0)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            [OpenInstallSDK initWithDelegate:self advertisingId:idfaStr];//不管用户是否授权，都要初始化
        }];
    }
#else
    NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [OpenInstallSDK initWithDelegate:self advertisingId:idfaStr];
#endif

    UnityRegisterAppDelegateListener(self);
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)onOpenURL:(NSNotification *)notification{
    if (notification.userInfo && [notification.userInfo objectForKey:@"url"]) {
        NSURL *url = [notification.userInfo objectForKey:@"url"];
        [OpenInstallSDK handLinkURL:url];
    }
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
//    [self configOrientation];//部分老版本unity，需要在拉起时进行强制横屏，新版本unity中可能会导致拉起崩溃，建议关闭，具体情况根据测试来定
    
    [OpenInstallSDK continueUserActivity:userActivity];
    Class unity = NSClassFromString(@"UnityAppController");
    if ([unity instancesRespondToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
        [super application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    return YES;
}

- (void)configOrientation{
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

@end
