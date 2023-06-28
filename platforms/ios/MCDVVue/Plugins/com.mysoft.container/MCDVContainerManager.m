//
//  MCDVContainerManager.m
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import "MCDVContainerManager.h"
#import "MCDVContainerItem.h"
#import <CoreEngine/CoreEngine.h>
#import "MCDVContainerWebController.h"

#define KMAXOFCONTAINER 3

NSString *const MCDVContainerErrorDomain = @"MCDVContainerErrorDomain";

@interface MCDVContainerManager ()

@property (nonatomic, strong) NSLock *listenerLock;
@property (nonatomic, strong) NSLock *containerLock;

@property (nonatomic, strong) NSMutableSet<id <MCDVContainerItemDelegate>> *listenerList;
@property (nonatomic, strong) NSMutableArray<MCDVContainerItem *> *containerList;

@end

@implementation MCDVContainerManager

#pragma Singleton
+ (instancetype)shareManager {
    static MCDVContainerManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (NSLock *)listenerLock {
    if (!_listenerLock) {
        _listenerLock = [[NSLock alloc] init];
    }
    return _listenerLock;
}

- (NSLock *)containerLock {
    if (!_containerLock) {
        _containerLock = [[NSLock alloc] init];
    }
    return _containerLock;
}

- (NSMutableSet<id<MCDVContainerItemDelegate>> *)listenerList {
    if (!_listenerList) {
        _listenerList = [NSMutableSet set];
    }
    return _listenerList;
}

- (NSMutableArray<MCDVContainerItem *> *)containerList {
    if (!_containerList) {
        _containerList = [NSMutableArray array];
    }
    return _containerList;
}

- (void)addContainer:(MCDVContainerItem *)container {
    [self.containerLock lock];
    [self.containerList addObject:container];
    [self.containerLock unlock];
}

- (void)removeContainer:(MCDVContainerItem *)container {
    [container.viewController releaseData];
    [self.containerLock lock];
    [self.containerList removeObject:container];
    [self.containerLock unlock];
}

- (NSUInteger)sizeOfContainer {
    [self.containerLock lock];
    NSInteger count = self.containerList.count;
    [self.containerLock unlock];
    return count;
}

- (MCDVContainerItem *)containerWithAppId:(NSString *)appId {
    [self.containerLock lock];
    __block MCDVContainerItem *container = nil;
    [self.containerList enumerateObjectsUsingBlock:^(MCDVContainerItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([appId isEqualToString:item.appId]) {
                container = item;
                *stop = YES;
            }
    }];
    [self.containerLock unlock];
    return container;
}
#pragma API

#pragma Add EventListener
- (void)addEventStatusListener:(id <MCDVContainerItemDelegate>)listener {
    [self.listenerLock lock];
    [self.listenerList addObject:listener];
    [self.listenerLock unlock];
}

- (void)removeEventStatusListener:(id <MCDVContainerItemDelegate>)listener {
    [self.listenerLock lock];
    [self.listenerList removeObject:listener];
    [self.listenerLock unlock];
}

#pragma Create/Initialize

- (MCDVContainerItem *)initializeContainerWithAppId:(NSString *)appId
                                         startPage:(NSString *)startPage
                                        pageConfig:(NSDictionary *)pageConfig
                                         keepAlive:(BOOL)keepAlive
                                             error:(NSError **)error {
    if (error) {
        *error = nil;
    }
    
    if (!appId.length) {
        if (error) {
            NSString *msg = @"id不能为空";
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return nil;
    }
    
    if ([self containerWithAppId:appId]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"创建失败：容器[id: %@]已存在", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return nil;
    }
    
    if ([self sizeOfContainer] >= KMAXOFCONTAINER) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"容器数量超过%d个限制", KMAXOFCONTAINER];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return nil;
    }
    
    if (!startPage.length) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"path不能为空"];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:1001
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return nil;
    }
    
    if (![startPage hasPrefix:@"http"] && ![self isLoacalResourceExist:startPage]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"文件不存在！path:%@",startPage];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:1001
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return nil;
    }
    
    MCDVContainerItem *container = [MCDVContainerItem containerWithAppId:appId startPage:startPage pageConfig:pageConfig keepAlive:keepAlive];
    __weak __typeof(self) weakSelf = self;
    container.onEventStatusChanged = ^(NSString *containerId, MCDVEventStatus status) {
        [weakSelf updateContainer:containerId status:status];
    };
    [self addContainer:container];
    return container;
}

- (void)createContainerWithAppId:(NSString *)appId
                       startPage:(NSString *)startPage
                      pageConfig:(NSDictionary *)pageConfig
                           error:(NSError **)error {
    
    MCDVContainerItem *container = [self initializeContainerWithAppId:appId startPage:startPage pageConfig:pageConfig keepAlive:YES error:error];
    [container prepareForReady];
}

- (NSArray<MCDVContainerItem *> *)allContainer {
    [self.containerLock lock];
    NSArray *containerList = self.containerList;
    [self.containerLock unlock];
    return containerList;
}


#pragma Show if exist
- (void)showContainerWithAppId:(NSString *)appId
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error {
    if (error) {
        *error = nil;
    }
    
    if (!appId.length) {
        if (error) {
            NSString *msg = @"id不能为空";
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return;
    }
    
    MCDVContainerItem *container = [self containerWithAppId:appId];
    if (!container) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]未创建", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
    if (container.isShowing) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]已处于显示状态", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:4
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
//    if (container.isInStack) {
//        // 已经在导航栈中，是否需要挪到栈顶？
//        UINavigationController *navc = viewController.navigationController ?: viewController.customNavigationController;
//        if (navc) {
//            NSMutableArray *stacks = [navc.viewControllers mutableCopy];
//            [stacks removeObject:container.viewController];
//            container.viewController.isStackChanging = YES;
//            navc.viewControllers = stacks;
//            [navc pushViewController:container.viewController animated:YES];
//            container.isInStack = YES;
//            return;
//        }
//        return;
//    }
//    container.isInStack = YES;
    container.isShowing = YES;
    container.status = MCDVEventStatusShow;
    [viewController ce_pushViewController:container.viewController animated:YES];
    [self respondToListenerWith:appId status:MCDVEventStatusShow];
}

#pragma Show if not exist
- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error {
    [self showContainerWithAppId:appId startPage:startPage pageConfig:nil fromViewController:viewController error:error];
}

- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
                    pageConfig:(NSDictionary *)pageConfig
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error {
    [self showContainerWithAppId:appId startPage:startPage pageConfig:pageConfig keepAlive:NO fromViewController:viewController error:error];
}

- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
                    pageConfig:(NSDictionary *)pageConfig
                     keepAlive:(BOOL)keepAlive
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error {
    
    if (!appId.length) {
        if (error) {
            NSString *msg = @"id不能为空";
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: msg}];
        }
        return;
    }
    
    MCDVContainerItem *container = [self containerWithAppId:appId];
    if (!container) {
        // creare container
        container = [self initializeContainerWithAppId:appId startPage:startPage pageConfig:pageConfig keepAlive:keepAlive error:error];
        if (!container) {
            return;
        }
    }else {
        if (![startPage hasPrefix:@"http"] && ![self isLoacalResourceExist:startPage]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"文件不存在！path:%@",startPage];
                *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: msg}];
            }
            return ;
        }
    }
    
    
    if (container.isShowing) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]已处于显示状态", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:4
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
//    if (container.isInStack) {
//        // 已经在导航栈中，是否需要挪到栈顶？
//        UINavigationController *navc = viewController.navigationController ?: viewController.customNavigationController;
//        if (navc) {
//            NSMutableArray *stacks = [navc.viewControllers mutableCopy];
//            [stacks removeObject:container.viewController];
//            container.viewController.isStackChanging = YES;
//            navc.viewControllers = stacks;
//            [navc pushViewController:container.viewController animated:YES];
//            container.isInStack = YES;
//            return;
//        }
//    }
//    container.isInStack = YES;
    container.isShowing = YES;
    container.status = MCDVEventStatusShow;
    [viewController ce_pushViewController:container.viewController animated:YES];
    [self respondToListenerWith:appId status:MCDVEventStatusShow];
}


# pragma Hidden
- (void)hideContainerWithAppId:(NSString *)appId error:(NSError *__autoreleasing *)error {
    MCDVContainerItem *container = [self containerWithAppId:appId];
    if (!container) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]未创建", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
    if (!container.isShowing) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]已处于隐藏状态", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:5
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
//    if (container.isInStack) {
//        [container.viewController.navigationController popViewControllerAnimated:YES];
//    }
//    container.isInStack = NO;
    UINavigationController *navc = container.viewController.navigationController;
    NSMutableArray *stacks = [navc.viewControllers mutableCopy];
    NSUInteger index = [stacks indexOfObject:container.viewController];
    if (index != stacks.count - 1) {
        [stacks removeObject:container.viewController];
        navc.viewControllers = stacks;
    }else {
        [container.viewController.navigationController popViewControllerAnimated:YES];
    }
    container.isShowing = NO;
}


#pragma Destroy
- (void)destroyContainerWithAppId:(NSString *)appId error:(NSError *__autoreleasing *)error {
    MCDVContainerItem *container = [self containerWithAppId:appId];
    if (!container) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"操作失败：容器[id: %@]未创建", appId];
            *error = [NSError errorWithDomain:MCDVContainerErrorDomain
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return;
    }
    
//    if (container.isInStack) {
//        [container.viewController.navigationController popViewControllerAnimated:YES];
//    }
//    container.isInStack = NO;
    UINavigationController *navc = container.viewController.navigationController;
    NSMutableArray *stacks = [navc.viewControllers mutableCopy];
    NSUInteger index = [stacks indexOfObject:container.viewController];
    if (index != stacks.count - 1) {
        [stacks removeObject:container.viewController];
        navc.viewControllers = stacks;
    }else {
        [container.viewController.navigationController popViewControllerAnimated:YES];
    }
    container.isShowing = NO;
    [self removeContainer:container];
}

- (void)updatePageConfig:(NSDictionary *)pageConfig forAppId:(NSString *)appId {
    MCDVContainerItem *container = [self containerWithAppId:appId];
    if (container) {
        [container updateConfig:pageConfig];
    }
}

- (void)updateContainer:(NSString *)containerId status:(MCDVEventStatus)status {
    
    MCDVContainerItem *container = [self containerWithAppId:containerId];
    MCDVEventStatus reaStatus = status == MCDVEventStatusPop ? MCDVEventStatusHidden : status;
    container.status = reaStatus;
    if (status == MCDVEventStatusPop) {
//        container.isInStack = NO;
        container.isShowing = NO;
        if (!container.keepAlive) {
            [self removeContainer:container];
        }
    }
    [self respondToListenerWith:containerId status:reaStatus];
}

- (void)respondToListenerWith:(NSString *)containerId status:(MCDVEventStatus)status {
    [self.listenerLock lock];
    [self.listenerList enumerateObjectsUsingBlock:^(id<MCDVContainerItemDelegate>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(container:onEventStatusChanged:)]) {
            [obj container:containerId onEventStatusChanged:status];
        }
    }];
    [self.listenerLock unlock];
}

- (BOOL)isLoacalResourceExist:(NSString *)path {
    NSString *wwwPath = [NSString stringWithFormat:@"%@/www",kCDVContainerDir];
    NSString *filePath = [wwwPath stringByAppendingPathComponent:path];
    //兼容html后面携带参数
    NSRange range = [filePath rangeOfString:@".html"];
    if (range.location != NSNotFound) {
        filePath = [filePath substringToIndex:range.location+range.length];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return NO;
    }
    return YES;
}

@end
