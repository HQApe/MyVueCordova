//
//  MCDVContainerAlertView.h
//  MCDVContainer
//
//  Created by 龙章辉 on 2020/8/26.
//

#import <UIKit/UIKit.h>


@class MCDVContainerAlertView;
@protocol MCDVContainerAlertViewDelegate <NSObject>

- (void)browserMenuView:(MCDVContainerAlertView *)menuView clickedMenuAtIndex:(NSInteger)itemIndex;
- (void)browserHide:(MCDVContainerAlertView *)menuView;

@end

@interface MCDVContainerAlertView : UIView


@property(nonatomic,strong)UIView *alphView;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,getter=isShow)BOOL show;
@property(nonatomic,weak)id <MCDVContainerAlertViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame WithItems:(NSString *)itemTitle, ... NS_REQUIRES_NIL_TERMINATION;
- (void)show;
- (void)dismiss;

@end

