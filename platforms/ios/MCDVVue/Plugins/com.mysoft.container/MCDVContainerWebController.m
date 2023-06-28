//
//  MCDVContainerWebController.m
//  mdev
//
//  Created by zhanghq on 2023/6/2.
//

#import "MCDVContainerWebController.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import <SDWebImage/SDWebImage.h>
#import <CoreEngine/CoreEngine.h>
#import "MCDVContainerAlertView.h"
#import "MCDVContainerMenuView.h"
#import "MCDVContainerScriptMessageDelegate.h"

#if __has_include("CDVStatusBar.h")
#import "CDVStatusBar.h"
#endif


#define kWebViewCloseFuncitonName @"close"

@interface MCDVContainerWebController ()

{
    MBProgressHUD *hud;
    BOOL _hadRelease;
    BOOL _hadPop;
}

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *locationHref;
@property (nonatomic, assign) BOOL backToOriginPosition;
@property (nonatomic, strong) NSString *closeParams;
@property (nonatomic, strong) UIView *failLoadView;
@property (nonatomic, strong) NSDictionary *pageConfig;
@property (nonatomic, strong) UIImage *longpressImage;
@property (nonatomic, assign) BOOL injectAllPlugin;
@property (nonatomic, strong) NSArray *injectPluginIds;
@property (nonatomic, strong) NSArray *injectPluginFeatures;
@property (nonatomic, strong) NSString *cordovaPluginsJSContent; //cordova_plugins.js内容
@property (nonatomic, strong) MCDVContainerAlertView *longPressAlertView;

@property (nonatomic, strong) UIImageView *naviBgImgView;
@property (nonatomic, strong) NSDictionary *navigationSettings;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSString *barTitle;
@end

@implementation MCDVContainerWebController

- (instancetype)initWithAppId:(NSString *)appId startPage:(NSString *)startPage pageConfig:(NSDictionary *)pageConfig
{
    if (self = [super init])
    {
        _commandQueue = [[MCDVContainerCommandQueue alloc] initWithViewController:self];
        _commandDelegate = [[MCDVContainerCommandDelegate alloc] initWithViewController:self];
        _urlString = startPage;
        _hadRelease = NO;
        _closeParams = nil;
        _pageConfig = pageConfig;
        self.startPage = startPage;
        _appId = appId;
        _navigationSettings = nil;
        if ([pageConfig.allKeys containsObject:@"navigationBar"]) {
            _navigationSettings = _DictionaryValue(pageConfig[@"navigationBar"]);
        }
        [self checkNeedInjectPlugins];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [self releaseData];
    if (self.onEventStatusChanged) {
        self.onEventStatusChanged(self.appId, MCDVEventStatusDestroy);
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (parent == nil) {
        if (self.isStackChanging) {
            // 正在切换导航栈，暂时被移除而已
            self.isStackChanging = NO;
            return;
        }
        if (_hadPop) {
            return;
        }
        _hadPop = YES;
        if (self.onEventStatusChanged) {
            self.onEventStatusChanged(self.appId, MCDVEventStatusPop);
        }
    }else {
        _hadPop = NO;
    }
}

- (void)releaseData
{
    //防止前端多次调用close方法
    if (!_hadRelease) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self._wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self._wkWebView removeObserver:self forKeyPath:@"title"];
        [self._wkWebView removeObserver:self forKeyPath:@"loading"];
        [self._wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kWebViewCloseFuncitonName];
        [self._wkWebView stopLoading];
        NSLog(@"*************开始释放webview*************");
    }
    _hadRelease = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self loadlaunchView];
    [self initNavigationView];
    [self initProgress];
    [self webViewSetting];
    [self setUserAgent];
    [self createFailLoadView];
    [self updateConstraint];
    [self refreshWebView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCDVPageDidLoad:) name:CDVPageDidLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCDVPluginReset:) name:CDVPluginResetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWebviewDidLoadFailedNotification:)
                                                 name:@"CDVPageDidLoadFailedNotification" object:nil];
    
    self.onEventStatusChanged(self.appId, MCDVEventStatusCreate);
}

- (void)onCDVPageDidLoad:(NSNotification *)notification {
    if ([notification.object isEqual:self.webView]) {
        [self autoInjectCordovaToRemoteJS:notification.object];
        [self addWKWebViewLongPress];
    }
}

- (void)onCDVPluginReset:(NSNotification *)notification {
    if ([notification.object isEqual:self.webView]) {
        _failLoadView.hidden = YES;
    }
}

- (void)onWebviewDidLoadFailedNotification:(NSNotification *)notification {
    if ([notification.object isEqual:self.webView]) {
        _failLoadView.hidden = NO;
    }
}

- (void)onAppWillEnterForeground
{

}
- (void)deviceOrientation:(UIInterfaceOrientation)orientation annimation:(BOOL)annimation{

    NSTimeInterval an = annimation?0.3:0;
    [UIView animateWithDuration:an
                     animations:^{
                         NSNumber *value = [NSNumber numberWithInteger:orientation];
                         [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                     }];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight;
    [self refreshWebViewFrame:isLandscape];
}

- (void)refreshWebViewFrame:(BOOL)isLandscape
{
    CGFloat sWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat sHeight = MAX(self.view.frame.size.width, self.view.frame.size.height);
    if (isLandscape) {

        sWidth = MAX(self.view.frame.size.width, self.view.frame.size.height);
        sHeight = MIN(self.view.frame.size.width, self.view.frame.size.height);
    }
    [self.view setFrame:CGRectMake(0, 0, sWidth, sHeight)];
    [self.view layoutIfNeeded];
    [self updateConstraint];
}

- (CGFloat)safeAreaInsetsLeft
{
    CGFloat safeLeft = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;

        safeLeft = safeAreaInsets.left;
    }
    return safeLeft;
}
- (CGFloat)safeAreaInsetsRight
{
    CGFloat safeRight = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;

        safeRight = safeAreaInsets.right;
    }
    return safeRight;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat safeLeft = [self safeAreaInsetsLeft];
    CGFloat safeRight = [self safeAreaInsetsRight];
    CGRect webviewFrame = self.webView.frame;
    
    if (self.adjustSafeArea) {
        CGFloat webviewHeight = SCREEN_SIZE_HEIGHT - safeAreaInsetsBottom;
        if (_naviBgImgView) {
            webviewFrame.origin.y = CGRectGetMaxY(_naviBgImgView.frame);
            webviewHeight -= CGRectGetMaxY(_naviBgImgView.frame);
        }else {
            webviewFrame.origin.y = safeAreaInsetsTop;
            webviewHeight -= safeAreaInsetsTop;
        }
        
        if (self.isLandscape) {
            webviewFrame.origin.x = safeLeft;
            webviewFrame.size.width = SCREEN_SIZE_WIDTH - safeLeft - safeRight;
        }else {
            webviewFrame.origin.x = 0;
            webviewFrame.size.width = SCREEN_SIZE_WIDTH;
        }
        webviewFrame.size.height = webviewHeight;
    }else{
        if (_naviBgImgView) {
            webviewFrame.origin.y = CGRectGetMaxY(_naviBgImgView.frame);
            webviewFrame.size.height = SCREEN_SIZE_HEIGHT - CGRectGetMaxY(_naviBgImgView.frame);
        }else {
            CGFloat offsexStatusBar = 0;
#if __has_include("CDVStatusBar.h")
            CDVStatusBar *statusBar = [self.commandDelegate getCommandInstance:@"StatusBar"];
            offsexStatusBar = statusBar.statusBarVisible ? (statusBar.statusBarOverlaysWebView ? 0 : statusBarHight) : 0;
#endif
            webviewFrame.origin.y = offsexStatusBar;
            webviewFrame.size.height = SCREEN_SIZE_HEIGHT - offsexStatusBar;
        }
        webviewFrame.origin.x = 0;
        webviewFrame.size.width = SCREEN_SIZE_WIDTH;
    }
    self.webView.frame = webviewFrame;
}

- (void)webViewSetting
{
    if (@available(iOS 11.0, *)) {
        [self.webView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self._wkWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self._wkWebView.scrollView.bounces = NO;
    self._wkWebView.allowsBackForwardNavigationGestures = YES;
    self._wkWebView.scrollView.showsVerticalScrollIndicator = NO;
    self._wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
    self._wkWebView.scrollView.scrollEnabled = YES;
    [self._wkWebView addObserver:self
                      forKeyPath:@"estimatedProgress"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self._wkWebView addObserver:self
                      forKeyPath:@"title"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self._wkWebView addObserver:self
                      forKeyPath:@"loading"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    MCDVContainerScriptMessageDelegate *weakScriptMessageDelegate = [[MCDVContainerScriptMessageDelegate alloc] initWithDelegate:(id<MCDVContainerScriptMessageHandler>)self];
    [self._wkWebView.configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:kWebViewCloseFuncitonName];
    //方法调用链太长，保持和安卓统一
    NSString *function = [NSString stringWithFormat:@"var webview = { \
                          %@: function(p) { \
                          window.webkit.messageHandlers.%@.postMessage(p)\
                          }\
                          }"\
                          ,kWebViewCloseFuncitonName,kWebViewCloseFuncitonName];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:function injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [self._wkWebView.configuration.userContentController addUserScript:script];
}

- (void)initProgress
{
    NSDictionary *progressBar = _DictionaryValue(self.pageConfig[@"progressBar"]);
    if (!progressBar.allKeys.count) {
        return;
    }
    NSString *style = _StringValue(progressBar[@"style"]);
    if (style.length && ![style isEqualToString:@"bar"]) {
        return;
    }
    UIColor *progressColor;
    if ([progressBar.allKeys containsObject:@"color"]) {
        progressColor = [UIColor ce_colorWithHexValue:_StringValue(progressBar[@"color"])];
    }else{
        progressColor = [UIColor ce_colorWithHexValue:@"#008000"];
    }
    _progressView = [[UIProgressView alloc] init];
    _progressView.progressTintColor = progressColor;
    _progressView.trackTintColor = [UIColor clearColor];
    [self.view addSubview:_progressView];
}

- (void)initNavigationView
{
    if (_navigationSettings == nil) {

        return;
    }
    _naviBgImgView = [[UIImageView alloc] init];
    _naviBgImgView.userInteractionEnabled = YES;
    [self.view addSubview:_naviBgImgView];
    NSString *color = _StringValue(_navigationSettings[@"background"]);
    color = [color stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if ([color hasPrefix:@"http"]) {

        NSURL *url = [NSURL URLWithString:color];
        [_naviBgImgView  sd_setImageWithURL:url placeholderImage:[UIImage new]];

    }else if([[NSFileManager defaultManager] fileExistsAtPath:color]){

        UIImage *image = [UIImage imageWithContentsOfFile:color];
        [_naviBgImgView setBackgroundColor:[UIColor clearColor]];
        [_naviBgImgView setImage:image];
    }else{

        UIColor *barColor = [UIColor whiteColor];
        if (color.length) {
            barColor = [UIColor ce_colorWithHexValue:color];
        }
        [_naviBgImgView setBackgroundColor:barColor];
    }

    //获取导航栏上所有按钮颜色值，没传则取默认黑色
    UIColor *blackColor = [UIColor ce_colorWithHexValue:@"#000000"];
    UIColor *buttonColor = blackColor;
    if ([_navigationSettings.allKeys containsObject:@"buttonColor"]) {
        buttonColor = [UIColor ce_colorWithHexValue:_StringValue(_navigationSettings[@"buttonColor"])];
    }
    //设置返回按钮
    UIImage *image = [self webBundleImageWithName:@"webview_back"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:image forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickedBackItem:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBgImgView addSubview:_backButton];
    _backButton.tintColor = buttonColor;

    image = [self webBundleImageWithName:@"webview_close"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:image forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(clickedCloseItem:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBgImgView addSubview:_closeButton];
    _closeButton.tintColor = buttonColor;
    _closeButton.hidden = YES;

    //设置导航栏标题
    NSString *title = _StringValue(_navigationSettings[@"title"]);
    UIColor *titleColor = blackColor;
    int titleSize = 18;
    if ([_navigationSettings.allKeys containsObject:@"titleColor"]) {
        titleColor = [UIColor ce_colorWithHexValue:_StringValue(_navigationSettings[@"titleColor"])];
    }
    if ([_navigationSettings.allKeys containsObject:@"titleSize"]) {
        titleSize = [_NumberValue(_navigationSettings[@"titleSize"]) intValue];
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:titleSize];
    _titleLabel.textColor = titleColor;
    _titleLabel.text = title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setContentCompressionResistancePriority:600 forAxis:UILayoutConstraintAxisHorizontal];
    [_naviBgImgView addSubview:_titleLabel];
    _barTitle = title;

    if ([self enbaleMenu] && [_urlString hasPrefix:@"http"]) {

        image = [self webBundleImageWithName:@"menu"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuButton setImage:image forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(clickedMenuItem:) forControlEvents:UIControlEventTouchUpInside];
        [_naviBgImgView addSubview:_menuButton];
        _menuButton.tintColor = buttonColor;
    }
}

- (BOOL)enbaleMenu
{
    BOOL enbaleMenu = YES;
    if ([_navigationSettings.allKeys containsObject:@"enbaleMenu"]) {
        enbaleMenu = [_NumberValue(_navigationSettings[@"enbaleMenu"]) boolValue];
    }
    return enbaleMenu;
}

- (BOOL)isLandscape
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    return width > height;
}

- (void)updateConstraint
{
    CGFloat safeLeft = [self safeAreaInsetsLeft];
    CGFloat safeRight = [self safeAreaInsetsRight];
    CGFloat statusBarHeight = statusBarHight;
    if (_naviBgImgView) {

        CGFloat navigationHeight = 44;
        CGFloat backBtnWidth = 35;
        [_naviBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.top.mas_offset(0);
            if (self.adjustSafeArea) {
                make.left.mas_offset(safeLeft);
                make.right.mas_offset(-safeRight);
            }else{
                make.left.right.mas_offset(0);
            }
            make.height.mas_equalTo(statusBarHeight+navigationHeight);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make){

            make.bottom.mas_offset(0);
            make.height.mas_equalTo(navigationHeight);
            if (_closeButton.isHidden) {

                make.left.mas_offset(backBtnWidth);
                make.right.mas_offset(-backBtnWidth);
            }else{
                make.left.mas_offset(backBtnWidth*2);
                make.right.mas_offset(-backBtnWidth*2);
            }
        }];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.mas_offset(0);
            make.centerY.equalTo(_titleLabel.mas_centerY);
            make.width.height.mas_offset(backBtnWidth);
        }];
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(_backButton.mas_right);
            make.centerY.equalTo(_titleLabel.mas_centerY);
            make.width.height.mas_offset(backBtnWidth);
        }];
        [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {

            make.right.mas_offset(0);
            make.centerY.equalTo(_titleLabel.mas_centerY);
            make.width.height.mas_offset(backBtnWidth);
        }];
    }
    if (_progressView) {

        [_progressView mas_remakeConstraints:^(MASConstraintMaker *make){

            if (_naviBgImgView) {
                make.top.equalTo(_naviBgImgView.mas_bottom);
            }else if(self.isLandscape){
                make.top.mas_offset(0);
            }else{
                make.top.mas_offset(statusBarHeight);
            }
            if (self.adjustSafeArea) {
                make.left.mas_offset(safeLeft);
                make.right.mas_offset(-safeRight);
            }else{
                make.left.right.mas_offset(0);
            }
            make.height.mas_offset(2);
        }];
    }
    [self.view layoutIfNeeded];
}

- (void)clickedBackItem:(UIButton *)sender
{
    if (self._wkWebView.canGoBack && !self.closeButton.isHidden){

        [self._wkWebView goBack];
    }else{
        [self popViewController];
    }
}

- (void)clickedCloseItem:(UIButton *)sender
{
    [self popViewController];
}

- (void)clickedMenuItem:(UIButton *)sender
{
    MCDVContainerMenuView *menu = [[MCDVContainerMenuView alloc] initWithSuperView:self.view];
    __weak __typeof(self) weakSelf = self;
    menu.refreshBlock = ^{
        [weakSelf refreshWebView];
    };
    [menu present];
    [self setMenuShareInfo:menu];
}

- (void)setMenuShareInfo:(MCDVContainerMenuView *)menu
{
    __weak __typeof(self) weakSelf = self;
    [self._wkWebView evaluateJavaScript:@"document.location.href;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        menu.url = result;
        //刷新title,避免title获取过慢值为空
        menu.title = weakSelf.titleLabel.text;
    }];
    [self._wkWebView evaluateJavaScript:@"document.getElementsByName(\"description\")[0].content" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        menu.descrip = result;
        //刷新title,避免title获取过慢值为空
        menu.title = weakSelf.titleLabel.text;
    }];
    [self._wkWebView evaluateJavaScript:@"document.getElementsByName(\"thumbnail\")[0].content" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        menu.thumbnail = result;
        //刷新title,避免title获取过慢值为空
        menu.title = weakSelf.titleLabel.text;
    }];
}


- (void)setUserAgent
{
    NSString *appendUA = _StringValue(self.pageConfig[@"appendUserAgent"]);
    appendUA = [@" ContainerWebView" stringByAppendingFormat:@"%@%@",appendUA.length?@" ":@"",appendUA];
    __weak __typeof(self) weakSelf = self;
    [self._wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * _Nullable userAgent, NSError * _Nullable error) {
        if (!error) {
            weakSelf._wkWebView.customUserAgent = [userAgent stringByAppendingString:appendUA];
        }
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]){
        hud.progress = self._wkWebView.estimatedProgress;
        _progressView.progress = self._wkWebView.estimatedProgress;
//        NSLog(@"progress: %f", _progressView.progress);
//        if (self._wkWebView.estimatedProgress >= 1.0) {
//
//            [self hideProgressAnimation];
//        }
    }else if ([keyPath isEqualToString:@"title"]){
        _titleLabel.text = _barTitle.length?_barTitle:self._wkWebView.title;
        if (self._wkWebView.canGoBack) {

            _closeButton.hidden = NO;
        }else{

            _closeButton.hidden = YES;
        }
        [self updateConstraint];

    }else if ([keyPath isEqualToString:@"loading"]){

        if (self._wkWebView.isLoading) {
            [self addProgressAnimation];
            _progressView.alpha = 1.0;
        }else if (!self._wkWebView.loading)
        {
            // 加载完成
            [self hideProgressAnimation];
        }
        if (self._wkWebView.canGoBack) {

            _closeButton.hidden = NO;
        }else{

            _closeButton.hidden = YES;
        }
        [self updateConstraint];
    }
}

#pragma mark MCDVContainerScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:kWebViewCloseFuncitonName]) {

        NSString *data = _StringValue(message.body);
        NSLog(@"接收到参数:%@",data);
        self.closeParams = data;
        [self popViewController];
    }
}

#pragma mark 插件注入相关
- (void)checkNeedInjectPlugins
{
    //是否使用插件
    BOOL usePlugin = [_NumberValue(self.pageConfig[@"enablePlugin"]) boolValue];
    if (!usePlugin) {

        return;
    }
    NSArray *injectPlugins = _ArrayValue(self.pageConfig[@"injectPlugins"]);
    _injectAllPlugin = YES;
    if (injectPlugins.count) {

        _injectPluginIds = _ArrayValue(injectPlugins);
        _injectAllPlugin = NO;
    }
    _injectPluginIds = [self addPluginWhiteList:_injectPluginIds];
    __weak __typeof(self) weakSelf = self;
    [self getCordovaPluginsJSContentAndInjectPluginIds:_injectPluginIds injectAll:_injectAllPlugin finish:^(NSArray * pluginIds, NSString *jsContent) {
        weakSelf.cordovaPluginsJSContent = jsContent;
        weakSelf.injectPluginFeatures = pluginIds;
    }];
}
#pragma mark 添加插件白名单
- (NSMutableArray *)addPluginWhiteList:(NSArray *)list
{
    NSMutableArray *whiteList = [NSMutableArray arrayWithArray:list];
//    if ( ![whiteList containsObject:@"cordova-plugin-file"]) {
//
//        [whiteList addObject:@"cordova-plugin-file"];
//    }
    if (![whiteList containsObject:@"com.mysoft.wkwebview"]) {
        [whiteList addObject:@"com.mysoft.wkwebview"];
    }
    return whiteList;
}

/**
 * 获取cordova_plugins.js文本内容
 * 如果不是加载全部插件，则需要根据传入的插件id比对cordova_plugins.js里面的内容
 * 找到需要的插件信息，重组cordova_plugins.js文本内容
 */
- (void)getCordovaPluginsJSContentAndInjectPluginIds:(NSArray *)needAddPluginIds injectAll:(BOOL)injectAll finish:(void (^)(NSArray *,NSString*))finish
{
    NSString *wwwPath = [NSString stringWithFormat:@"%@/www",kCDVContainerDir];
    NSString *jsPath = [wwwPath stringByAppendingPathComponent:@"cordova_plugins.js"];
    NSString *contents =  [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *allElement = [contents componentsSeparatedByString:@"module.exports ="];
    NSString *prefix = allElement.firstObject;
    NSString * module = allElement.lastObject;
    NSArray *moduleComponent = [module componentsSeparatedByString:@";"];
    NSString *module_exports = moduleComponent.firstObject;
    NSString *module_metadata = [moduleComponent[1] componentsSeparatedByString:@"module.exports.metadata ="].lastObject;
    NSDictionary *metadataToDic = [module_metadata dictionaryValue];
    NSArray *exportsToArray = [module_exports arrayValue];
    
    if (injectAll) {
        NSString *cordova_plugins = contents;
        
        return finish(nil,cordova_plugins);
    }
    
    NSMutableArray *availableClobbers = [NSMutableArray array];
    NSMutableArray *exports = [NSMutableArray array];
    //获取App所有插件clobbers
    for (NSDictionary *dic in exportsToArray) {

        NSString *_pluginId =  _StringValue(dic[@"pluginId"]);
        if (![needAddPluginIds containsObject:_pluginId]) {

            continue;
        }
        //特殊处理:network插件clobbers对应config.xml里feature的为NetworkStatus,不是普遍规则
        if ([_pluginId isEqualToString:@"cordova-plugin-network-information"]) {

            if (![availableClobbers containsObject:@"NetworkStatus".lowercaseString]) {

                [availableClobbers addObject:@"NetworkStatus".lowercaseString];
            }
            [exports addObject:dic];
            continue;
        }
        NSString *_id =  _StringValue(dic[@"id"]);
        NSArray *_clobbers = _ArrayValue(dic[@"clobbers"]);
        if (_clobbers.count == 0) {

            NSString *clob = [_id componentsSeparatedByString:[NSString stringWithFormat:@"%@.",_pluginId]].lastObject;
            _clobbers = [NSArray arrayWithObject:clob];
        }
        //有些插件clobbers有多个元素
        for (NSString *obj in _clobbers) {

            NSString *removeWindow = [obj stringByReplacingOccurrencesOfString:@"window." withString:@""].lowercaseString;
            NSString *removeACPrefix = [obj stringByReplacingOccurrencesOfString:@"ac." withString:@""].lowercaseString;
            if (![availableClobbers containsObject:removeWindow]) {

                [availableClobbers addObject:removeWindow];
            }
            if (![availableClobbers containsObject:removeACPrefix]) {

                [availableClobbers addObject:removeACPrefix];
            }
        }
        [exports addObject:dic];
    }
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    for (NSString *key in metadataToDic.allKeys) {

        if (![needAddPluginIds containsObject:key]) {

            continue;
        }
        NSString *value = metadataToDic[key];
        [metadata setObject:value forKey:key];
    }
    //按需重新组装cordova_plugins.js内容
    NSString *cordova_plugins = [NSString stringWithFormat:@"%@module.exports =%@;\nmodule.exports.metadata =%@\n%@",prefix,[exports ce_jsonPrettyPrintedString],[metadata ce_jsonPrettyPrintedString],@"});"];
    /**
     * 添加系统配置
     * 其中IntentAndNavigationFilter必须添加，否则所有插件都会注册失败
     */
    [availableClobbers addObject:@"IntentAndNavigationFilter".lowercaseString];
    [availableClobbers addObject:@"LocalStorage".lowercaseString];
    [availableClobbers addObject:@"Console".lowercaseString];
    [availableClobbers addObject:@"HandleOpenUrl".lowercaseString];
    [availableClobbers addObject:@"GestureHandler".lowercaseString];
    finish(availableClobbers,cordova_plugins);
}

- (void)autoInjectCordovaToRemoteJS:(WKWebView *)wkweb
{
    if (self.cordovaPluginsJSContent.length || self.injectPluginIds.count) {

        NSString *getVersion = @"function getCordovaVersion(){ \
                                                        if(window.cordova){ \
                                                                return cordova.version; \
                                                        } \
                                                        return undefined;\
                                }\
                                getCordovaVersion(); \
                                ";
        __weak __typeof(self) weakSelf = self;
        [self._wkWebView evaluateJavaScript:getVersion completionHandler:^(id _Nullable result, NSError * _Nullable error) {

            //先判断是否已经注入，没有注入自动注入，防止多页面时无法调起Cordova
            if (result == nil) {

                [wkweb evaluateJavaScript:[weakSelf buildInjectionJS] completionHandler:^(id id, NSError *error){
                    if (error) {
                        // Nothing to do here other than log the error.
                        NSLog(@"Error when injecting javascript into WKWebView: '%@'.", error);
                    }
                }];
            }else{
                NSLog(@"***已经注入cordova,无需多次注入！***");
            }
        }];
    }else{
        NSLog(@"**************不需要注入插件**************");
    }
}

- (NSString *) buildInjectionJS;
{
    NSArray *jsPaths = [self jsPathsToInject];

    NSString *path;
    NSMutableString *concatenatedJS = [[NSMutableString alloc] init];
    for (path in jsPaths) {

        NSURL *jsURL = [NSURL fileURLWithPath:path];
        NSString *js = [NSString stringWithContentsOfFile:jsURL.path encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Concatenating JS found in path: '%@'", jsURL.path);
        if (js) {
            [concatenatedJS appendString:js];
        }
    }
    // Initialize cordova plugin registry.
    [concatenatedJS appendString:self.cordovaPluginsJSContent];
    return concatenatedJS;
}

/*
 Returns an array of bundled javascript files to inject into the current page.
 */
- (NSArray *) jsPathsToInject
{
    // Array of paths that represent JS files to inject into the WebView.  Order is important.
    NSMutableArray *jsPaths = [NSMutableArray new];
    NSString *dir = kCDVContainerDir;
    [jsPaths addObject:[NSString stringWithFormat:@"%@/www/cordova.js",dir]];
    // We load the plugin code manually rather than allow cordova to load them (via
    // cordova_plugins.js).  The reason for this is the WebView will attempt to load the
    // file in the origin of the page (e.g. https://example.com/plugins/plugin/plugin.js).
    // By loading them first cordova will skip the loading process altogether.
    NSString *pluginsPath = [dir stringByAppendingPathComponent:@"www/plugins"];
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:pluginsPath];
    NSString *path;
    while (path = [directoryEnumerator nextObject])
    {
        NSString *_id = path.pathComponents.firstObject;
        
        if ([path hasSuffix: @".js"] && (self.injectAllPlugin || [self.injectPluginIds containsObject:_id])) {

            [jsPaths addObject: [NSString stringWithFormat:@"%@/%@/%@", dir,@"www/plugins", path]];
        }
    }
    return jsPaths;
}

- (id)getCommandInstance:(NSString *)pluginName
{
    if (self.injectAllPlugin || [[pluginName lowercaseString] isEqualToString:@"intentandnavigationfilter"]) {
        // CDVIntentAndNavigationFilter 不能屏蔽，因为这里需要对allow-intent进行判断，否则就没法加载http了
        NSLog(@"***********%@被初始化！！",pluginName);
        return [super getCommandInstance:pluginName];
    }
    //前端没有传入的插件，不初始化
    if ([pluginName isKindOfClass:[NSString class]] && ![self.injectPluginFeatures containsObject:pluginName.lowercaseString]) {
        return nil;
    }
    NSLog(@"***********%@被初始化！！",pluginName);
    return [super getCommandInstance:pluginName];
}


- (void)createFailLoadView
{
    _failLoadView = [[UIView alloc] init];
    _failLoadView.hidden = YES;
    [_failLoadView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_failLoadView];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[self webBundleImageWithName:@"webview_close"] forState:UIControlStateNormal];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    closeBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 0, 0);
    [closeBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [_failLoadView addSubview:closeBtn];
    closeBtn.hidden = _naviBgImgView;

    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setImage:[self webBundleImageWithName:@"数据加载失败"]];
    imageView.tag = 100;
    [_failLoadView addSubview:imageView];

    UILabel *lab = [[UILabel alloc] init];
    lab.textColor = [UIColor ce_colorWithHexValue:@"#9c9c9c"];
    lab.font = [UIFont systemFontOfSize:14.0];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"数据加载失败，请检查你的手机是否联网";
    lab.tag = 101;
    [_failLoadView addSubview:lab];

    UIImage *ima = [self webBundleImageWithName:@"查看网络"];
    UIButton *checkNetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkNetBtn setImage:ima forState:UIControlStateNormal];
    checkNetBtn.tag = 102;
    checkNetBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    UIColor *titleColor = [UIColor ce_colorWithHexValue:@"#5F5F5F"];
    [checkNetBtn setTitleColor:titleColor forState:UIControlStateNormal];
    [checkNetBtn setTitle:@"检查网络" forState:UIControlStateNormal];
    [checkNetBtn addTarget:self action:@selector(gotoURLSetting) forControlEvents:UIControlEventTouchUpInside];
    [_failLoadView addSubview:checkNetBtn];

    ima = [self webBundleImageWithName:@"刷新页面"];
    UIButton *refreshInterfaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshInterfaceBtn setImage:ima forState:UIControlStateNormal];
    refreshInterfaceBtn.tag = 103;
    refreshInterfaceBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [refreshInterfaceBtn setTitleColor:titleColor forState:UIControlStateNormal];
    [refreshInterfaceBtn setTitle:@"刷新页面" forState:UIControlStateNormal];
    [refreshInterfaceBtn addTarget:self action:@selector(refreshWebView) forControlEvents:UIControlEventTouchUpInside];
    [_failLoadView addSubview:refreshInterfaceBtn];

    CGFloat safeTop = safeAreaInsetsTop;
    [_failLoadView mas_makeConstraints:^(MASConstraintMaker *make){

        if (_naviBgImgView) {
            make.top.equalTo(_naviBgImgView.mas_bottom);
        }else{
            make.top.mas_offset(0);
        }
        make.left.right.bottom.mas_offset(0);
    }];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        if ([self forceLandSpace] && isiPhoneX) {

            make.top.mas_offset(15);
            make.left.mas_offset(safeTop);
        }else{

            make.top.mas_offset(safeTop);
            make.left.mas_offset(0);
        }
        make.width.height.mas_equalTo(40);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerX.mas_offset(0);
        make.centerY.mas_offset(-84);
    }];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.right.mas_offset(0);
        make.top.equalTo(imageView.mas_bottom).mas_offset(20);
    }];

    [checkNetBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerX.mas_offset(-(30+ima.size.width/2));
        make.top.equalTo(lab.mas_bottom).mas_offset(50);
    }];

    [refreshInterfaceBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerX.mas_offset(30+ima.size.width/2);
        make.top.equalTo(checkNetBtn.mas_top);
    }];
    [checkNetBtn layoutIfNeeded];
    [refreshInterfaceBtn layoutIfNeeded];

    checkNetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [checkNetBtn setTitleEdgeInsets:UIEdgeInsetsMake(checkNetBtn.imageView.frame.size.height ,-checkNetBtn.imageView.frame.size.width, 0.0,0.0)];
    //文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [checkNetBtn setImageEdgeInsets:UIEdgeInsetsMake(-checkNetBtn.imageView.frame.size.height, 0.0,0.0, -checkNetBtn.titleLabel.bounds.size.width)];
    refreshInterfaceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [refreshInterfaceBtn setTitleEdgeInsets:UIEdgeInsetsMake(refreshInterfaceBtn.imageView.frame.size.height ,-refreshInterfaceBtn.imageView.frame.size.width, 0.0,0.0)];
    //文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [refreshInterfaceBtn setImageEdgeInsets:UIEdgeInsetsMake(-refreshInterfaceBtn.imageView.frame.size.height, 0.0,0.0, -refreshInterfaceBtn.titleLabel.bounds.size.width)];
}

- (UIImage *)webBundleImageWithName:(NSString *)name
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"NewWebViewPlus.bundle/%@",name]];
}

- (void)gotoURLSetting
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {

        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)refreshWebView
{
#pragma clang diagnostic push
    if ([self respondsToSelector:NSSelectorFromString(@"checkAndReinitViewUrl")]) {

        [self addProgressAnimation];
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        BOOL res = [self performSelector:NSSelectorFromString(@"checkAndReinitViewUrl")];
#pragma clang diagnostic pop
        if (!res){
            [self._wkWebView reload];
        }
    }
}

- (void)removeWKWebViewLongPress
{
    //注入前端代码无法移除自带长按选图效果
    for (UIView *subView in self._wkWebView.scrollView.subviews) {
        for (UIGestureRecognizer *recogniser in subView.gestureRecognizers) {
            if ([recogniser isKindOfClass:UILongPressGestureRecognizer.class]) {
                [subView removeGestureRecognizer:recogniser];
            }
        }
    }
//    [self._wkWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
//
//     [self._wkWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none'" completionHandler:nil];

}

- (void)addWKWebViewLongPress
{
    if (self.enableSaveImage) {

        [self removeWKWebViewLongPress];
        //暂无好的方法可以获取iframe中的img标签
        UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressed.delegate = (id<UIGestureRecognizerDelegate>)self;
        longPressed.minimumPressDuration = 0.3;
        [self._wkWebView addGestureRecognizer:longPressed];
    }
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addProgressAnimation
{
    
    NSDictionary *progressBar = _DictionaryValue(self.pageConfig[@"progressBar"]);
    if (!progressBar.allKeys.count) {
        return;
    }
    NSString *style = _StringValue(progressBar[@"style"]);
    if (!style.length || ![style isEqualToString:@"rotate"]) {
        return;
    }
    UIColor *progressColor;
    if ([progressBar.allKeys containsObject:@"color"]) {
        progressColor = [UIColor ce_colorWithHexValue:_StringValue(progressBar[@"color"])];
    }else{
        progressColor = [UIColor ce_colorWithHexValue:@"#008000"];
    }
    if (hud) {
        return;
    }
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.contentColor = progressColor;
}

- (void)loadlaunchView
{
    //CDVViewController中的launchView修改背景色不成功,隐藏之
    @try {
        UIView *launchView = (UIView *)[self valueForKey:@"_launchView"];
        if (launchView) {
            [launchView setAlpha:0];
        }
    } @catch (NSException *exception) {}
}

- (void)hideProgressAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.progressView.alpha = 0;
        [self->hud hideAnimated:YES];
        self->hud = nil;
    });
}

- (WKWebView *)_wkWebView
{
    return (WKWebView *)self.webView;
}
- (BOOL)forceLandSpace
{
    return [_NumberValue(self.pageConfig[@"forceLandSpace"]) boolValue];
}
- (BOOL)enableSaveImage
{
    return [_NumberValue(self.pageConfig[@"enableSaveImage"]) boolValue];

}

- (void)keyBoardShow
{
    self.backToOriginPosition = NO;
}

- (void)keyBoardHidden {

    self.backToOriginPosition = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.backToOriginPosition) {
            [self.webView.scrollView setContentOffset:CGPointZero animated:YES];
        }
    });
}

/**
 适配浏海屏安全区域；
 true:webview内容区域占满全屏;
 false:webview内容区域不包含安全区域；
 默认true
 */
- (BOOL)adjustSafeArea
{
    BOOL adjust = true;
    if ([self.pageConfig.allKeys containsObject:@"fillSafeArea"]) {
        adjust = ![_NumberValue(self.pageConfig[@"fillSafeArea"]) boolValue];
    }
    return adjust;
}

- (MCDVContainerAlertView *)longPressAlertView
{
    if (!_longPressAlertView) {

        _longPressAlertView = [[MCDVContainerAlertView alloc]
                               initWithFrame:[UIScreen mainScreen].bounds
                               WithItems:@"保存图片", nil];
        _longPressAlertView.delegate = (id<MCDVContainerAlertViewDelegate>)self;
        [self.view addSubview:_longPressAlertView];
    }
    return _longPressAlertView;
}
#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer{

    //暂无好的方法可以获取iframe中的img标签,不做处理
    //https://baijiahao.baidu.com/s?id=1696717185268468229&wfr=spider&for=pc
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    __weak __typeof(self) weakSelf = self;
    [self._wkWebView evaluateJavaScript:imgURL completionHandler:^(id _Nullable result, NSError * _Nullable error) {

        NSString *urlToSave = result;
        if (!error && urlToSave.length) {

            __block  UIImage *decodedImage = nil;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_async(group, queue, ^{

                NSString *longpressImageContent = [urlToSave componentsSeparatedByString:@"base64,"].lastObject;
                NSData *_decodedImageData = [[NSData alloc] initWithBase64EncodedString:longpressImageContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
                if ([longpressImageContent hasPrefix:@"http"]) {

                    _decodedImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:longpressImageContent]];
                }
                decodedImage = [UIImage imageWithData:_decodedImageData];
            });
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{

                if (decodedImage) {
                    weakSelf.longpressImage = decodedImage;
                    [weakSelf.longPressAlertView show];
                    NSLog(@"****获取到图片地址:%@",result);
                }
            });
        }
    }];
}

- (void)browserMenuView:(MCDVContainerAlertView *)menuView clickedMenuAtIndex:(NSInteger)itemIndex
{
     [self savePhotoToAlbm];
}

- (void)savePhotoToAlbm
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        UIImageWriteToSavedPhotosAlbum(self->_longpressImage,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    });
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if(error) {
        [MBProgressHUD showMessage:@"保存图片失败" withDuration:1];
        NSLog(@"保存到相册失败:%@",[error localizedDescription]);
    }else{

        [MBProgressHUD showMessage:@"已保存到系统相册" withDuration:1];
    }
}

#ifdef CORDOVA_PLUGIN_SDK_SUPPORT
-(NSString*)configFilePath{

    NSString* path = [kStagingDir stringByAppendingPathComponent:@"config.xml"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSAssert(NO, @"路径文件不存在:%@", path);
        return nil;
    }
    return path;
}
#endif



@end



@implementation MCDVContainerCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    NSString *www = [kCDVContainerDir stringByAppendingPathComponent:@"www"];
    NSString *fullPath = [www stringByAppendingPathComponent:resourcepath];
    return fullPath;
}

@end

@implementation MCDVContainerCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end

