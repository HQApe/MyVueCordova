//
//  MCDVContainerScriptMessageDelegate.m
//  appName
//
//  Created by 龙章辉 on 2021/6/17.
//

#import "MCDVContainerScriptMessageDelegate.h"

@implementation MCDVContainerScriptMessageDelegate
- (void)dealloc {
    NSLog(@"%s", __func__);
}
- (instancetype)initWithDelegate:(id<MCDVContainerScriptMessageHandler>)scriptDelegate{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}


@end
