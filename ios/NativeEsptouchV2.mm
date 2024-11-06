#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RCT_EXTERN_MODULE(NativeEsptouchV2, NSObject)

// 初始化方法
RCT_EXTERN_METHOD(espProvisionerInit)

// 同步相关方法
RCT_EXTERN_METHOD(stopSync)
RCT_EXTERN_METHOD(startSyncWithDelegate)

// 配网相关方法
RCT_EXTERN_METHOD(startProvisioning:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopProvisioning)

// 状态查询方法
RCT_EXTERN_METHOD(isProvisioning:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isSyncing:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
