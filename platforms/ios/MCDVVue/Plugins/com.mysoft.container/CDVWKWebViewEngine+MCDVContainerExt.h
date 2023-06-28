//
//  CDVWKWebViewEngine+MCDVContainerExt.h
//  mdev
//
//  Created by zhanghq on 2023/6/9.
//

#if __has_include("CDVWKWebViewEngine.h")
#import "CDVWKWebViewEngine.h"
@interface CDVWKWebViewEngine (MCDVContainerExt)

@end

#else
#import <WebKit/WebKit.h>
#import <Cordova/CDV.h>
@interface CDVWebViewEngine : CDVPlugin <CDVWebViewEngineProtocol, WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong, readonly) id <WKUIDelegate> uiDelegate;

- (void)allowsBackForwardNavigationGestures:(CDVInvokedUrlCommand*)command;

@end

@interface CDVWebViewEngine (MCDVContainerExt)

@end
#endif
