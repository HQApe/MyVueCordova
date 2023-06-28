//
//  MCDVContainerItem.m
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import "MCDVContainerItem.h"

#import "MCDVContainerWebController.h"

@interface MCDVContainerItem ()
// 应用Id，唯一标识
@property (nonatomic, strong) NSString *appId;

// 页面是否保持存活
@property (nonatomic, assign) BOOL keepAlive;

// 应用配置，包含初始化参数、主题、等，可扩展
@property (nonatomic, copy) NSDictionary *pageConfig;

// 运行Webview容器
@property(nonatomic, strong) MCDVContainerWebController *viewController;

@end

@implementation MCDVContainerItem

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)containerWithAppId:(NSString *)appId startPage:(NSString *)startPage keepAlive:(BOOL)keepAlive {
    return [self containerWithAppId:appId startPage:startPage pageConfig:nil keepAlive:(BOOL)keepAlive];
}

+ (instancetype)containerWithAppId:(NSString *)appId startPage:(NSString *)startPage pageConfig:(NSDictionary *)pageConfig keepAlive:(BOOL)keepAlive {
    MCDVContainerItem *container = [[MCDVContainerItem alloc] initWithAppId:appId pageConfig:pageConfig keepAlive:(BOOL)keepAlive];
    MCDVContainerWebController *viewController = [[MCDVContainerWebController alloc] initWithAppId:appId
                                                                                         startPage:startPage
                                                                                        pageConfig:pageConfig];
    container.viewController = viewController;
    return container;
}

- (instancetype)initWithAppId:(NSString *)appId pageConfig:(NSDictionary *)pageConfig keepAlive:(BOOL)keepAlive {
    if (self = [super init]) {
        _appId = appId;
        _pageConfig = pageConfig;
        _keepAlive = keepAlive;
    }
    return self;
}

- (void)setOnEventStatusChanged:(void (^)(NSString *containerId, MCDVEventStatus status))onEventStatusChanged {
    _onEventStatusChanged = onEventStatusChanged;
    self.viewController.onEventStatusChanged = onEventStatusChanged;
}

- (void)updateConfig:(NSDictionary *)config {
    
}

- (void)prepareForReady {
    [self.viewController.view setNeedsDisplay];
}

- (NSString *)statusString {
    switch (self.status) {
        case MCDVEventStatusCreate:
            return @"created";
            break;
        case MCDVEventStatusDestroy:
            return @"destroy";
            break;
        case MCDVEventStatusShow:
            return @"showing";
            break;
        case MCDVEventStatusHidden:
            return @"hidden";
            break;
        case MCDVEventStatusPop:
            return @"hidden";
            break;
        default:
            return @"uncreated";
            break;
    }
}

@end
