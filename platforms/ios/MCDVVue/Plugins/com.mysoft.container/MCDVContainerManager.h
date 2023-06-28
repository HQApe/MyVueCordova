//
//  MCDVContainerManager.h
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import <Foundation/Foundation.h>
#import "MCDVContainerItem.h"

@protocol MCDVContainerItemDelegate <NSObject>

@optional
- (void)container:(NSString *)containerId onEventStatusChanged:(MCDVEventStatus)eventStatus;

@end

@interface MCDVContainerManager : NSObject

+ (instancetype)shareManager;

#pragma Add EventListener
- (void)addEventStatusListener:(id <MCDVContainerItemDelegate>)listener;
- (void)removeEventStatusListener:(id <MCDVContainerItemDelegate>)listener;

- (MCDVContainerItem *)containerWithAppId:(NSString *)appId;

#pragma Create/Initialize
- (void)createContainerWithAppId:(NSString *)appId
                       startPage:(NSString *)startPage
                      pageConfig:(NSDictionary *)pageConfig
                           error:(NSError **)error;

- (NSArray<MCDVContainerItem *> *)allContainer;


#pragma Show if exist
- (void)showContainerWithAppId:(NSString *)appId
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error;

#pragma Show if not exist
- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error;

- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
                    pageConfig:(NSDictionary *)pageConfig
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error;

- (void)showContainerWithAppId:(NSString *)appId
                     startPage:(NSString *)startPage
                    pageConfig:(NSDictionary *)pageConfig
                     keepAlive:(BOOL)keepAlive
            fromViewController:(UIViewController *)viewController
                         error:(NSError **)error;


# pragma Hidden
- (void)hideContainerWithAppId:(NSString *)appId error:(NSError **)error;;


#pragma Destroy
- (void)destroyContainerWithAppId:(NSString *)appId error:(NSError **)error;

- (void)updatePageConfig:(NSDictionary *)pageConfig forAppId:(NSString *)appId;

@end

