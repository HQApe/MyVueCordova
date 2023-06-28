//
//  MCDVContainerMenuView.m
//  mdev
//
//  Created by 龙章辉 on 2021/7/28.
//

#import "MCDVContainerMenuView.h"
#import <CoreEngine/CoreEngine.h>
#import <Masonry/Masonry.h>
#import <Cordova/CDV.h>

#define kScrollViewItemWidth 48
#define kScrollViewItemImageWidth 48
#define kScrollViewItemLableMaxWidth 60
#define kScrollViewItemOriginX 24
#define kScrollViewItemSpace 32

#if __has_include("MWeixin.h")

#import "MWeixin.h"
#if __has_include(<WechatOpenSDK/WXApi.h>)
#import  <WechatOpenSDK/WXApi.h>
#else
#import "WXApi.h"
#endif

#endif

#if __has_include("MQQ.h")
#import "MQQ.h"
#endif

#if __has_include("MWeiBo.h")
#import "MWeiBo.h"
#endif



typedef NS_ENUM(NSInteger,WebViewMenuType){

    WebViewShareWXSceneSession = 1, //微信好友
    WebViewShareWXSceneTimeline ,   //微信朋友圈
    WebViewShareQQFriend,           //QQ好友
    WebViewShareWeiBo,              //微博
    WebViewShareSMS,                //短信
    WebViewShareSafari,             //浏览器中打开

    WebViewMenuTypeCopyLink = 101,//复制链接
    WebViewMenuTypeRefresh //刷新
};

@interface MCDVContainerMenuView ()
{
    CGFloat _scrollViewHeight;
}
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIButton *cancelButton;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UIScrollView *upScrollView;
@property(nonatomic,strong)UIScrollView *downScrollView;

@end


@implementation MCDVContainerMenuView

- (instancetype)initWithSuperView:(UIView *)superView
{
    CGRect frame = superView.bounds;
    if (self = [super initWithFrame:frame]) {

        self.userInteractionEnabled = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        [superView addSubview:self];
        [self createInterface];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)createInterface
{
    _bgView = [[UIView alloc] initWithFrame:self.frame];
    [_bgView setBackgroundColor:[UIColor colorWithRed:50/255.0 green:50/255.0 blue:51/255.0 alpha:1.0]];
    _bgView.alpha = 0.1;
    [self addSubview:_bgView];
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_bgView addGestureRecognizer:tap];

    _contentView = [[UIView alloc] init];
    [_contentView setBackgroundColor:[UIColor colorWithRed:247/255.0 green:248/255.0 blue:250/255.0 alpha:1.0]];
    [self addSubview:_contentView];

    UIColor *cancelTitleColor = [UIColor colorWithRed:100/255.0 green:101/255.0 blue:102/255.0 alpha:1.0];
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, safeAreaInsetsBottom, 0)];
    [_cancelButton setBackgroundColor:[UIColor whiteColor]];
    [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setTitleColor:cancelTitleColor forState:UIControlStateNormal];
    [_contentView addSubview:_cancelButton];

    [self initUpScrollView];
    [self initDownScrollView];
    [self setInterfaceConstraint];
}

- (void)initUpScrollView
{
    NSMutableArray *data = [NSMutableArray array];
#if __has_include("MWeixin.h")
    if([WXApi isWXAppInstalled]){
        [data addObject:@{@"title":@"微信",@"image":@"share_weixin",@"tag":@(WebViewShareWXSceneSession)}];
        [data addObject:@{@"title":@"朋友圈",@"image":@"share_pyquan",@"tag":@(WebViewShareWXSceneTimeline)}];
    }
#endif
#if __has_include("MWeiBo.h")
    if ([WeiboSDK isWeiboAppInstalled]) {
        [data addObject:@{@"title":@"微博",@"image":@"share_weibo",@"tag":@(WebViewShareWeiBo)}];
    }
#endif
//    [data addObject:@{@"title":@"短信",@"image":@"share_duanxin",@"tag":@(WebViewShareSMS)}];

#if __has_include("MQQ.h")
    if ([TencentOAuth iphoneQQInstalled]) {
        [data addObject:@{@"title":@"QQ",@"image":@"share_qq",@"tag":@(WebViewShareQQFriend)}];
    }
#endif
    [data addObject:@{@"title":@"浏览器打开",@"image":@"share_browser",@"tag":@(WebViewShareSafari)}];

    CGFloat contentSize = kScrollViewItemOriginX*2+ (data.count-1)*kScrollViewItemSpace+data.count*kScrollViewItemWidth;
    _upScrollView = [[UIScrollView alloc] init];
    _upScrollView.contentSize = CGSizeMake(contentSize, 0);
    _upScrollView.showsHorizontalScrollIndicator = NO;
    [_contentView addSubview:_upScrollView];
    [_upScrollView setBackgroundColor:[UIColor clearColor]];
    CGFloat originX = kScrollViewItemOriginX;
    for (int i=0; i<data.count; i++) {

        NSDictionary *item = data[i];
        NSInteger tag = [item[@"tag"] integerValue];
        NSString *title = item[@"title"];
        NSString *imageName = item[@"image"];
        UIImage *image = [self webBundleImageWithName:imageName];
        UIButton *btn =[self createCentreButtonWithTitle:title image:image originX:originX superView:_upScrollView];
        btn.tag = tag;
        originX += (kScrollViewItemSpace+kScrollViewItemWidth);
    }
}
- (void)initDownScrollView
{
    NSArray *data = @[
        @{@"title":@"复制链接",@"image":@"menu_copylink",@"tag":@(WebViewMenuTypeCopyLink)},
        @{@"title":@"刷新",@"image":@"menu_refresh",@"tag":@(WebViewMenuTypeRefresh)}
    ];
    CGFloat contentSize = kScrollViewItemOriginX*2+ (data.count-1)*kScrollViewItemSpace+data.count*kScrollViewItemWidth;
    _downScrollView = [[UIScrollView alloc] init];
    _downScrollView.contentSize = CGSizeMake(contentSize, 0);
    _downScrollView.showsHorizontalScrollIndicator = NO;
    [_downScrollView setBackgroundColor:[UIColor clearColor]];
    [_contentView addSubview:_downScrollView];
    CGFloat originX = kScrollViewItemOriginX;
    for (int i=0; i<data.count; i++) {

        NSDictionary *item = data[i];
        NSInteger tag = [item[@"tag"] integerValue];
        NSString *title = item[@"title"];
        NSString *imageName = item[@"image"];
        UIImage *image = [self webBundleImageWithName:imageName];
        UIButton *btn = [self createCentreButtonWithTitle:title image:image originX:originX superView:_downScrollView];
        btn.tag = tag;
        originX += (kScrollViewItemSpace+kScrollViewItemWidth);
    }
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

- (void)setInterfaceConstraint
{
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    CGFloat safeBootom = safeAreaInsetsBottom;
    CGFloat cancelBtnHeight = 48+safeBootom;
    CGFloat height =_scrollViewHeight;
    CGFloat safeLeft = [self safeAreaInsetsLeft];
    CGFloat safeRight = [self safeAreaInsetsRight];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.bottom.equalTo(_contentView.mas_bottom);
        make.height.mas_equalTo(cancelBtnHeight);
    }];
    [_downScrollView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_offset(safeLeft);
        make.right.mas_offset(-safeRight);
        make.bottom.equalTo(_cancelButton.mas_top);
        make.top.equalTo(_upScrollView.mas_bottom);
        make.height.mas_equalTo(height);
    }];
    [_upScrollView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_offset(safeLeft);
        make.right.mas_offset(-safeRight);
        make.top.equalTo(_contentView.mas_top).mas_offset(16);
        make.height.mas_equalTo(height);
    }];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.right.bottom.mas_offset(0);
    }];
    [self layoutIfNeeded];
    [_contentView addRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(self.bounds));
    _contentView.layer.affineTransform = transform;
}

- (void)present
{
    if (!self.isShow) {

        self.show = YES;
        [UIView animateWithDuration:0.3 animations:^{

            self->_contentView.transform = CGAffineTransformIdentity;
            self->_bgView.alpha = 0.9;
        } completion:^(BOOL finish){

        }];
    }
}

- (void)dismiss
{
    [self dismissWithDuration:0.3];
}

- (void)dismissWithDuration:(NSInteger)duration
{
    if (self.isShow) {

        [MBProgressHUD hideHUDWithAnimated:YES];
        self.show = NO;
        [UIView animateWithDuration:duration animations:^{

            self->_bgView.hidden = YES;
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight([UIScreen mainScreen].bounds));
            self->_contentView.layer.affineTransform = transform;
        } completion:^(BOOL finished){

            [self removeFromSuperview];
        }];
    }
}

- (UIButton *)createCentreButtonWithTitle:(NSString *)title image:(UIImage *)image originX:(CGFloat)originX superView:(UIView *)superView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.clipsToBounds = YES;
    [superView addSubview:btn];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [btn addSubview:imageView];

    UIColor *titleColor = [UIColor colorWithRed:150/255.0 green:151/255.0 blue:153/255.0 alpha:1.0];
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.font = [UIFont systemFontOfSize:11.0];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.numberOfLines = 0;
    titleLable.text = title;
    titleLable.textColor = titleColor;
    [btn addSubview:titleLable];
    CGFloat offsetTop = 8;
    CGFloat offsetBottom = 16;
    CGFloat lineHeight = ceilf(titleLable.font.lineHeight);
    _scrollViewHeight = lineHeight+kScrollViewItemWidth+offsetTop+offsetBottom;
    CGFloat btnWidth = title.length>4?kScrollViewItemLableMaxWidth:kScrollViewItemWidth;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_offset(originX);
        make.width.mas_equalTo(btnWidth);
        make.top.mas_offset(0);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.centerX.mas_offset(0);
        make.width.height.mas_equalTo(kScrollViewItemImageWidth);
    }];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.right.mas_offset(0);
        make.top.equalTo(imageView.mas_bottom).mas_offset(offsetTop);
        make.bottom.mas_offset(-offsetBottom);
    }];
    return btn;
}


- (void)clickedButton:(UIButton *)btn
{
    NSDictionary *shareInfo = @{@"webpageUrl":_StringValue(self.url),
                                @"title":_StringValue(self.title),
                                @"description":_StringValue(self.descrip),
                                @"thumbData":_StringValue(self.thumbnail),
                                @"uuid":[NSString genetateMillisecondTimestamp]
    };
    NSInteger tag = btn.tag;
    switch (tag) {
        case WebViewShareWXSceneSession:
            [self shareToWXSceneSession:shareInfo];
            break;
        case WebViewShareWXSceneTimeline:
            [self shareToWXSceneTimeline:shareInfo];
            break;
        case WebViewShareQQFriend:
            [self shareToQQFriend:shareInfo];
            break;
        case WebViewShareWeiBo:
            [self shareToWeiBo:shareInfo];
            break;
        case  WebViewShareSMS:
//            [self shareToSMS:shareInfo];
            break;
        case WebViewShareSafari:
            [self shareToSafari];
            break;
        case WebViewMenuTypeCopyLink:
            [self copyLink];
            break;
        case WebViewMenuTypeRefresh:
            [self refreshWebPage];
            break;
        default:
            break;
    }
    if (tag != WebViewShareSMS) {
        [self dismiss];
    }
}

///分享到微信好友
- (void)shareToWXSceneSession:(NSDictionary *)shareInfo
{
#if __has_include("MWeixin.h")
    [MBProgressHUD showActivityIndicatorWithDuration:1000];
    CDVInvokedUrlCommand *command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[shareInfo,@(0)] callbackId:@"" className:@"" methodName:@""];
    [[MWeixin shareInstace] setShowShareSuccessTips:YES];
    [[MWeixin shareInstace] shareWebPage:command];
#endif
}
///分享到微信朋友圈
- (void)shareToWXSceneTimeline:(NSDictionary *)shareInfo
{
#if __has_include("MWeixin.h")
    [MBProgressHUD showActivityIndicatorWithDuration:1000];
    CDVInvokedUrlCommand *command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[shareInfo,@(1)] callbackId:@"" className:@"" methodName:@""];
    [[MWeixin shareInstace] setShowShareSuccessTips:YES];
    [[MWeixin shareInstace] shareWebPage:command];
#endif
}
///分享到qq好友
- (void)shareToQQFriend:(NSDictionary *)shareInfo
{
#if __has_include("MQQ.h")
    [MBProgressHUD showActivityIndicatorWithDuration:1000];
    CDVInvokedUrlCommand *command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[shareInfo,@(0)] callbackId:@"" className:@""methodName:@""];
    [[MQQ shareInstace] setShowShareSuccessTips:YES];
    [[MQQ shareInstace] shareWebPage:command];
#endif
}
///分享到微博
- (void)shareToWeiBo:(NSDictionary *)shareInfo
{
#if __has_include("MWeiBo.h")
    [MBProgressHUD showActivityIndicatorWithDuration:1000];
    CDVInvokedUrlCommand *command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[shareInfo,@(0)] callbackId:@"" className:@""methodName:@""];
    [[MWeiBo shareInstace] setShowShareSuccessTips:YES];
    [[MWeiBo shareInstace] shareWebPage:command];
#endif
}
///在浏览器中打开
- (void)shareToSafari
{
    NSURL *openUrl = [NSURL URLWithString:self.url];
    if (!openUrl) {
        return;
    }
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:openUrl options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:openUrl];
    }
}

///拷贝链接
- (void)copyLink
{
    [UIPasteboard generalPasteboard].string = self.url;
    NSLog(@"已成功复制当前url:%@",self.url);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"已复制到剪贴板" withDuration:1];
    });
}
///刷新网页
- (void)refreshWebPage
{
    if (self.refreshBlock) {

        self.refreshBlock();
    }
}

- (UIImage *)webBundleImageWithName:(NSString *)name
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"NewWebViewPlus.bundle/%@",name]];
}



@end


