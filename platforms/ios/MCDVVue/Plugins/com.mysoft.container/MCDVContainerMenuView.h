//
//  MCDVContainerMenuView.h
//  mdev
//
//  Created by 龙章辉 on 2021/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCDVContainerMenuView : UIView

@property(nonatomic,strong)NSString *title;     //分享标题
@property(nonatomic,strong)NSString *url;       //分享网页url
@property(nonatomic,strong)NSString *descrip;   //分享描述语
@property(nonatomic,strong)NSString *thumbnail; //分享缩略图

@property(nonatomic,strong)void(^refreshBlock)(void);

@property(nonatomic,assign,getter=isShow)BOOL show;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)present;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
