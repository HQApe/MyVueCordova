//
//  MCDVContainer.h
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCDVContainer : CDVPlugin


- (void)create:(CDVInvokedUrlCommand *)command;
- (void)getInfo:(CDVInvokedUrlCommand *)command;


- (void)destroy:(CDVInvokedUrlCommand *)command;
- (void)show:(CDVInvokedUrlCommand *)command;
- (void)hide:(CDVInvokedUrlCommand *)command;

//- (void)updateConfig:(CDVInvokedUrlCommand *)command;

- (void)addEventListener:(CDVInvokedUrlCommand *)command;

//- (void)navigateTo:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
