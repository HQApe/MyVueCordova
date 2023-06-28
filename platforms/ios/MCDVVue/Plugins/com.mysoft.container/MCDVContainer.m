//
//  MCDVContainer.m
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import "MCDVContainer.h"
#import <CoreEngine/CoreEngine.h>
#import "MainViewController.h"
#import "MCDVContainerItem.h"
#import "MCDVContainerManager.h"
#import "MCDVContainerWebController.h"

@interface MCDVContainer ()<MCDVContainerItemDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *listenerList;

@property (nonatomic, assign) BOOL isMainApp;

@property (nonatomic, assign) BOOL isContainer;

@end

@implementation MCDVContainer

- (void)pluginInitialize {
    self.isMainApp = [self.viewController isKindOfClass:[MainViewController class]];
    self.isContainer = [self.viewController isKindOfClass:[MCDVContainerWebController class]];
    self.listenerList = [NSMutableArray array];
}

- (void)dispose {
    [[MCDVContainerManager shareManager] removeEventStatusListener:self];
    [self.listenerList removeAllObjects];
}

- (void)ready:(CDVInvokedUrlCommand *)command {
    if (self.isMainApp) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES] callbackId:command.callbackId];
    }else if (self.isContainer){
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO] callbackId:command.callbackId];
    }else {
        // 其它webview的关闭API，暂不支持其它Webview调用
        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
    }
}


- (void)create:(CDVInvokedUrlCommand *)command {
    if (!self.isMainApp) {
        [self sendPluginResultWithCode:1001 message:@"create:仅支持主应用调用" command:command];
        return;
    }
    NSString *appId = _StringValue(command.arguments.firstObject);
    NSString *startPath = _StringValue(command.arguments[1]);
    NSDictionary *config = _DictionaryValue(command.arguments[2]);
    NSError *error = nil;
    [[MCDVContainerManager shareManager] createContainerWithAppId:appId startPage:startPath pageConfig:config error:&error];
    if (error) {
        [self sendPluginResultWithCode:error.code message:error.localizedDescription ?: @"容器创建失败" command:command];
        [self container:appId onEventStatusChanged:MCDVEventStatusError onError:error];
    }else {
        [self sendPluginResult:nil command:command];
    }
}

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    
    MCDVContainerManager *manager = [MCDVContainerManager shareManager];
    if (self.isMainApp) {
        NSArray *containerIds = _ArrayValue(command.arguments.firstObject);
        __block NSMutableArray *containerIdList = [NSMutableArray array];
        for (NSString *containerId in containerIds) {
            MCDVContainerItem *item = [manager containerWithAppId:_StringValue(containerId)];
            if (item) {
                [containerIdList addObject:@{@"id":containerId, @"status": item.statusString ?: @"uncreated"}];
            }else {
                [containerIdList addObject:@{@"id":containerId, @"status": @"uncreated"}];
            }
        }
        if (!containerIdList.count) {
            NSMutableArray<MCDVContainerItem *> *containerList = [[[MCDVContainerManager shareManager] allContainer] mutableCopy];
            [containerList enumerateObjectsUsingBlock:^(MCDVContainerItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                [containerIdList addObject:@{@"id":item.appId, @"status": item.statusString ?: @"uncreated"}];
            }];
        }
        [self sendPluginResult:containerIdList command:command];
        return;
    }else if (self.isContainer) {
        MCDVContainerWebController *viewController = (MCDVContainerWebController *)self.viewController;
        MCDVContainerItem *item = [manager containerWithAppId:viewController.appId];
        [self sendPluginResult:@{@"id":item.appId, @"status": item.statusString ?: @"uncreated"} command:command];
    }else {
        // 其它webview的关闭API，暂不支持其它Webview调用
        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
    }
}


- (void)destroy:(CDVInvokedUrlCommand *)command {
    if (!self.isMainApp && !self.isContainer) {
        // 其它webview的关闭API，暂不支持其它Webview调用
        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
        return;
    }
    MCDVContainerManager *manager = [MCDVContainerManager shareManager];
    NSString *appId = nil;
    if (self.isMainApp) {
        appId = _StringValue(command.arguments.firstObject);
    }else if (self.isContainer) {
        MCDVContainerWebController *viewController = (MCDVContainerWebController *)self.viewController;
        appId = viewController.appId;
    }
    
    NSError *error = nil;
    [manager destroyContainerWithAppId:appId error:&error];
    if (error) {
        [self sendPluginResultWithCode:error.code message:error.localizedDescription command:command];
        [self container:appId onEventStatusChanged:MCDVEventStatusError onError:error];
    }else {
        [self sendPluginResult:nil command:command];
    }
}

- (void)show:(CDVInvokedUrlCommand *)command {
    if (!self.isMainApp && !self.isContainer) {
        // 其它webview的关闭API，暂不支持其它Webview调用
        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
        return;
    }
    MCDVContainerManager *manager = [MCDVContainerManager shareManager];
    NSString *appId = nil;
    UIViewController *fromViewController = nil;
    if (self.isMainApp) {
        appId = _StringValue(command.arguments.firstObject);
        fromViewController = self.viewController;
    }else if (self.isContainer) {
        MCDVContainerWebController *viewController = (MCDVContainerWebController *)self.viewController;
        appId = viewController.appId;
        fromViewController = [CoreEngineUtilities topViewController];
    }
    NSError *error = nil;
    [manager showContainerWithAppId:appId fromViewController:fromViewController error:&error];
    if (error) {
        [self sendPluginResultWithCode:error.code message:error.localizedDescription command:command];
        [self container:appId onEventStatusChanged:MCDVEventStatusError onError:error];
    }else {
        [self sendPluginResult:nil command:command];
    }
}

- (void)hide:(CDVInvokedUrlCommand *)command {
    if (!self.isMainApp && !self.isContainer) {
        // 其它webview的关闭API，暂不支持其它Webview调用
        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
        return;
    }
    MCDVContainerManager *manager = [MCDVContainerManager shareManager];
    NSString *appId = nil;
    if (self.isMainApp) {
        appId = _StringValue(command.arguments.firstObject);
    }else if (self.isContainer) {
        MCDVContainerWebController *viewController = (MCDVContainerWebController *)self.viewController;
        appId = viewController.appId;
    }
    NSError *error = nil;
    [manager hideContainerWithAppId:appId error:&error];
    if (error) {
        [self sendPluginResultWithCode:error.code message:error.localizedDescription command:command];
        [self container:appId onEventStatusChanged:MCDVEventStatusError onError:error];
    }else {
        [self sendPluginResult:nil command:command];
    }
}

//- (void)updateConfig:(CDVInvokedUrlCommand *)command {
//    if (!self.isMainApp && !self.isContainer) {
//        // 其它webview的关闭API，暂不支持其它Webview调用
//        [self sendPluginResultWithCode:1001 message:@"非容器环境，无法操作该API" command:command];
//        return;
//    }
//    MCDVContainerManager *manager = [MCDVContainerManager shareManager];
//    NSString *appId = nil;
//    NSDictionary *config = nil;
//    if (self.isMainApp) {
//        appId = _StringValue(command.arguments.firstObject);
//        config = _DictionaryValue(command.arguments[1]);
//    }else if (self.isContainer) {
//        MCDVContainerWebController *viewController = (MCDVContainerWebController *)self.viewController;
//        appId = viewController.appId;
//        config = _DictionaryValue(command.arguments.firstObject);
//    }
//    [manager updatePageConfig:config forAppId:appId];
//    [self sendPluginResult:nil command:command];
//}

- (void)addEventListener:(CDVInvokedUrlCommand *)command {
    if (self.isMainApp || self.isContainer) {
        [self.listenerList addObject:command.callbackId];
        [[MCDVContainerManager shareManager] addEventStatusListener:self];
    }else {
        // 其它webview暂时不允许调用
        [self sendPluginResultWithCode:10001 message:@"非容器环境，无法操作该API" command:command];
    }
}

//- (void)navigateTo:(CDVInvokedUrlCommand *)command {
//    if (self.isMainApp) {
//        [self sendPluginResultWithCode:10001 message:@"navigateTo:仅支持容器调用" command:command];
//    }else if (self.isContainer){
//        NSString *appId = _StringValue(command.arguments.firstObject);
//        NSString *startPath = _StringValue(command.arguments[1]);
//        NSDictionary *config = _DictionaryValue(command.arguments[2]);
//        BOOL keepAlive = _NumberValue(command.arguments[3]).boolValue;
//        [[MCDVContainerManager shareManager] showContainerWithAppId:appId startPage:startPath pageConfig:config keepAlive:keepAlive fromViewController:self.viewController error:nil];
//    }else {
//        // 其它webview暂时不允许调用
//        [self sendPluginResultWithCode:10001 message:@"非容器环境，无法操作该API" command:command];
//    }
//}

#pragma MCDVContainerItemDelegate

- (void)container:(NSString *)containerId onEventStatusChanged:(MCDVEventStatus)eventStatus {
    [self container:containerId onEventStatusChanged:eventStatus onError:nil];
}

- (void)container:(NSString *)containerId onEventStatusChanged:(MCDVEventStatus)eventStatus onError:(NSError *)error {
    if (self.isMainApp) {
        __weak __typeof(self) weakSelf = self;
        [self.listenerList enumerateObjectsUsingBlock:^(NSString   * _Nonnull callBackId, NSUInteger idx, BOOL * _Nonnull stop) {
            CDVPluginResult *result = nil;
            if (eventStatus == MCDVEventStatusError) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:@[@(eventStatus), containerId, @{@"errCode":@(error.code), @"errMsg":error.localizedDescription ?: @"未知错误"}]];
            }else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[@(eventStatus), containerId]];
            }
            result.keepCallback = @(YES);
            [weakSelf.commandDelegate sendPluginResult:result callbackId:callBackId];
        }];
    } else if (self.isContainer){
        __weak __typeof(self) weakSelf = self;
        [self.listenerList enumerateObjectsUsingBlock:^(NSString   * _Nonnull callBackId, NSUInteger idx, BOOL * _Nonnull stop) {
            CDVPluginResult *result = nil;
            if (eventStatus == MCDVEventStatusError) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:@[@(eventStatus), @{@"errCode":@(error.code), @"errMsg":error.localizedDescription ?: @"未知错误"}]];
            }else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[@(eventStatus)]];
            }
            result.keepCallback = @(YES);
            [weakSelf.commandDelegate sendPluginResult:result callbackId:callBackId];
        }];
    }
}

@end
