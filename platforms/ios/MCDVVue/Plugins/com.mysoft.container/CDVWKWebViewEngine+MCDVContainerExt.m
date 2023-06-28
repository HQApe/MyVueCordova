//
//  CDVWKWebViewEngine+MCDVContainerExt.m
//  mdev
//
//  Created by zhanghq on 2023/6/9.
//

#import "CDVWKWebViewEngine+MCDVContainerExt.h"
#import <CoreEngine/CoreEngine.h>
#import "MCDVContainerWebController.h"
#if __has_include("CDVWKWebViewEngine.h")
@implementation CDVWKWebViewEngine (MCDVContainerExt)
#else
@implementation CDVWebViewEngine (MCDVContainerExt)
#endif

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CoreEngineSwizzleMethod([self class], @selector(webView:didFailNavigation:withError:), @selector(mctn_ext_webView:didFailNavigation:withError:));
        CoreEngineSwizzleMethod([self class], @selector(webView:decidePolicyForNavigationAction:decisionHandler:), @selector(mctn_ext_webView:decidePolicyForNavigationAction:decisionHandler:));
    });
}

- (void)mctn_ext_webView:(WKWebView*)theWebView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
    if ([self.viewController isKindOfClass:[MCDVContainerWebController class]]) {
        BOOL useErrorPage = [[NSBundle mainBundle].infoDictionary[@"showRefreshWhenWhiteScreen"] isEqualToString:@"true"];
        if (!useErrorPage) {
            // 使用统一错误页时，由CDVWKWebViewEngine+ErrorReload去控制
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CDVPageDidLoadFailedNotification" object:self.webView];
        }
    }
    [self mctn_ext_webView:theWebView didFailNavigation:navigation withError:error];
}

- (void)mctn_ext_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (![self.viewController isKindOfClass:[MCDVContainerWebController class]]) {
        if (!navigationAction.targetFrame.isMainFrame) {
            [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
        }
    }
    [self mctn_ext_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
}

@end
