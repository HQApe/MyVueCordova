//
//  MCDVContainerScriptMessageDelegate.h
//  appName
//
//  Created by 龙章辉 on 2021/6/17.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol MCDVContainerScriptMessageHandler <NSObject>

@required

/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
/*
 解决mwebview插件中已经实现userContentController:didReceiveScriptMessage:
 从而分类中方法不被调用
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end


//解决循环引用导致内存不释放，退出控制器时不走dealloc
@interface MCDVContainerScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic,weak)id<MCDVContainerScriptMessageHandler> scriptDelegate;


- (instancetype)initWithDelegate:(id<MCDVContainerScriptMessageHandler>)scriptDelegate;

@end

NS_ASSUME_NONNULL_END
