//
//  MCDVContainerWebController.h
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import <Cordova/CDV.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>

#ifdef CORDOVA_PLUGIN_SDK_SUPPORT
#import <CordovaPluginLib/CordovaPluginLib.h>
#define kCDVContainerDir \
({\
NSString *dir = [[CordovaPluginLib sharedLib] wwwParentDirectoryForPluginLib]; \
(dir); \
})
#else
#define kCDVContainerDir NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#endif


typedef enum : NSUInteger {
    MCDVEventStatusCreate,      // init
    MCDVEventStatusDestroy,     // dealloc销毁
    MCDVEventStatusShow,        // viewDidAppear
    MCDVEventStatusHidden,      // viewDidDisAppear
    MCDVEventStatusPop,         // 从导航栈中推出，如果不考虑导航栈的替换，可以不用这个状态
    MCDVEventStatusError
} MCDVEventStatus;

@interface MCDVContainerWebController : CDVViewController

// 应用Id，唯一标识
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, assign) BOOL isStackChanging;

@property (nonatomic, copy) void(^onEventStatusChanged)(NSString *containerId, MCDVEventStatus status);

- (instancetype)initWithAppId:(NSString *)appId
                    startPage:(NSString *)startPage
                   pageConfig:(NSDictionary *)pageConfig;

- (void)releaseData;

@end


@interface MCDVContainerCommandDelegate : CDVCommandDelegateImpl
@end

@interface MCDVContainerCommandQueue : CDVCommandQueue
@end

