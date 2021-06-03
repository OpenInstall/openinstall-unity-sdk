//
//  OpenIsntallUnity3DBridge.m
//  Unity-iPhone
//
//  Created by cooper on 2018/6/14.
//

#import "OpenIsntallUnity3DBridge.h"
#import "OpenInstallUnity3DCallBack.h"
#import "OpenInstallSDK.h"
#import <AdSupport/AdSupport.h>
#if defined(__IPHONE_14_0)
#import <AppTrackingTransparency/AppTrackingTransparency.h>//适配iOS14
#endif
@implementation OpenIsntallUnity3DBridge

#if defined (__cplusplus)
extern "C" {
#endif
    
    void _config(char*adid)
    {
        NSString *adidStr = [NSString stringWithCString:adid encoding:NSASCIIStringEncoding];
        [OpenInstallSDK initWithDelegate:[OpenInstallUnity3DCallBack defaultManager] advertisingId:adidStr];
    }
    
    void _init()
    {
        if (![OpenInstallUnity3DCallBack defaultManager].isInit) {
            [OpenInstallUnity3DCallBack defaultManager].isInit = YES;
#if defined(__IPHONE_14_0)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            [OpenInstallSDK initWithDelegate:[OpenInstallUnity3DCallBack defaultManager] advertisingId:idfaStr];//不管用户是否授权，都要初始化
            [OpenIsntallUnity3DBridge fitWakeupBehaviour];
        }];
    }else{
        NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [OpenInstallSDK initWithDelegate:[OpenInstallUnity3DCallBack defaultManager] advertisingId:idfaStr];
        [OpenIsntallUnity3DBridge fitWakeupBehaviour];
    }
#else
    NSString *idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [OpenInstallSDK initWithDelegate:[OpenInstallUnity3DCallBack defaultManager] advertisingId:idfaStr];
    [OpenIsntallUnity3DBridge fitWakeupBehaviour];
#endif
            
            
        }
    }
    
    void _openInstallGetInstall(int s)
    {
        _init();
        float time = 8;
        if (s >= 5){
            time = s;
        }
        [[OpenInstallSDK defaultManager] getInstallParmsWithTimeoutInterval:time completed:^(OpeninstallData * _Nullable appData) {
            
            NSString *channelID = @"";
            NSString *datas = @"";
            if (appData.data) {
                datas = [OpenIsntallUnity3DBridge jsonStringWithObject:appData.data];
            }
            if (appData.channelCode) {
                channelID = appData.channelCode;
            }
            NSDictionary *installDicResult = @{@"channelCode":channelID,@"bindData":datas};
            NSString *installJsonStr = [OpenIsntallUnity3DBridge jsonStringWithObject:installDicResult];
            UnitySendMessage([@"OpenInstall" UTF8String], "_installCallback", [installJsonStr UTF8String]);
            
        }];
    }
    
    void _openInstallRegisterWakeUpHanndler()
    {
        _init();
        OpenInstallUnity3DCallBack *callBack = [OpenInstallUnity3DCallBack defaultManager];
        callBack.isRegister = YES;
        if(callBack.wakeUpJson.length != 0)
        {
            UnitySendMessage([@"OpenInstall" UTF8String], "_wakeupCallback", [callBack.wakeUpJson UTF8String]);
            callBack.wakeUpJson = nil;
        }
    }

    void _openInstallReportRegister()
    {
        _init();
        [OpenInstallSDK reportRegister];
    }
    
    void _openInstallReportEffectPoint(char*pointId,long pointValue)
    {
        _init();
        NSString *pointID = [NSString stringWithCString:pointId encoding:NSASCIIStringEncoding];
        [[OpenInstallSDK defaultManager] reportEffectPoint:pointID effectValue:pointValue];
    }
    
#if defined (__cplusplus)
}
#endif

+ (void)fitWakeupBehaviour{
    if ([OpenInstallUnity3DCallBack defaultManager].userActivity) {
        [OpenInstallSDK continueUserActivity:[OpenInstallUnity3DCallBack defaultManager].userActivity];
        [OpenInstallUnity3DCallBack defaultManager].userActivity = nil;
    }
    if ([OpenInstallUnity3DCallBack defaultManager].url) {
        [OpenInstallSDK handLinkURL:[OpenInstallUnity3DCallBack defaultManager].url];
        [OpenInstallUnity3DCallBack defaultManager].url = nil;
    }
}

+ (NSString *)jsonStringWithObject:(id)jsonObject{
    
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    
    if (argumentsJSON.length>2) {argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];}
    
    return argumentsJSON;
}
+ (NSString *)cp_JSONString:(NSArray *)array{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    }else{
        return @"";
    }
}

@end
