//
//  MCDVContainerItem.h
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import <Foundation/Foundation.h>
#import "MCDVContainerWebController.h"

@interface MCDVContainerItem : NSObject

// 应用Id，唯一标识
@property (nonatomic, strong, readonly) NSString *appId;

// 页面是否保持存活
@property (nonatomic, assign, readonly) BOOL keepAlive;

// 应用配置，包含初始化参数、主题、等，可扩展
@property (nonatomic, copy, readonly) NSDictionary *pageConfig;

// 应用页面所处的状态
@property (nonatomic, assign) MCDVEventStatus status;

@property (nonatomic, copy) NSString *statusString;

// 是否已经被推入栈，如果不考虑页面是否已经在导航栈中，这个属性可以去掉
@property (nonatomic, assign) BOOL isInStack;

// 是否已经显示
@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, copy) void(^onEventStatusChanged)(NSString *containerId,MCDVEventStatus status);

// 运行Webview容器
@property(nonatomic, strong, readonly) MCDVContainerWebController *viewController;

+ (instancetype)containerWithAppId:(NSString *)appId startPage:(NSString *)startPage keepAlive:(BOOL)keepAlive;

+ (instancetype)containerWithAppId:(NSString *)appId startPage:(NSString *)startPage pageConfig:(NSDictionary *)pageConfig keepAlive:(BOOL)keepAlive;

- (void)updateConfig:(NSDictionary *)config;

- (void)prepareForReady;

@end

