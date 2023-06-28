//
//  MCDVContainerAlertView.m
//  MagicPluginApp
//
//  Created by 龙章辉 on 2020/8/26.
//

#import "MCDVContainerAlertView.h"
#import <Masonry/Masonry.h>
#import <CoreEngine/CoreEngine.h>
//
#define kAlertItemH 44
#define kSpaceY 6


@implementation MCDVContainerAlertView

- (instancetype)initWithFrame:(CGRect)frame WithItems:(NSString *)itemTitle, ...
{
    if (self = [super initWithFrame:frame]) {

        [self setBackgroundColor:[UIColor clearColor]];
        _show = NO;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];

        _alphView = [[UIView alloc] initWithFrame:self.frame];
        [_alphView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [self addSubview:_alphView];

        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:118/255.0 alpha:1.0]];
        [self addSubview:_contentView];

        va_list args;
        va_start(args, itemTitle);
        NSMutableArray *titles = [NSMutableArray array];
        for (NSString * _title = itemTitle; _title != nil; _title = va_arg(args,NSString *))
        {
            [titles addObject:_title];
        }
        CGFloat bottom = safeAreaInsetsBottom;
        NSInteger count = titles.count;
        float h = kAlertItemH*count+kSpaceY*(count-1)+bottom;
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make){

            make.left.right.bottom.mas_offset(0);
            make.height.mas_equalTo(h);
        }];
        UIButton *beforeItem = nil;
        for (NSInteger i= titles.count-1; i>=0; i--) {

            NSString *_title = titles[i];
            UIButton *tmpItem = [self createMenuItemWithTag:i WithTitle:_title];
            [_contentView addSubview:tmpItem];

            [tmpItem mas_makeConstraints:^(MASConstraintMaker *make){


                make.left.right.mas_offset(0);
                if (i == titles.count-1) {

                    CGFloat tmpH = kAlertItemH+bottom;
                    make.bottom.mas_offset(0);
                    make.height.mas_equalTo(tmpH);
                    [tmpItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];

                }else{
                    make.height.mas_equalTo(kAlertItemH);
                    make.bottom.equalTo(beforeItem.mas_top).mas_offset(-kSpaceY);
                }
            }];
            beforeItem = tmpItem;

        }
    }
    return self;
}

- (UIButton *)createMenuItemWithTag:(NSInteger)tag WithTitle:(NSString *)title
{
    UIButton *item = nil;
    item = [UIButton buttonWithType:UIButtonTypeCustom];
    item.tag = tag;
    [item setTitle:title forState:UIControlStateNormal];
    [item addTarget:self action:@selector(clickedMenuItem:) forControlEvents:UIControlEventTouchUpInside];
    [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [item setBackgroundColor:[UIColor colorWithRed:217/255.0 green:216/255.0 blue:212/255.0 alpha:1.0]];

    return item;
}
- (void)clickedMenuItem:(UIButton *)sender
{
    [self dismiss];
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserMenuView:clickedMenuAtIndex:)]) {

        [self.delegate browserMenuView:self clickedMenuAtIndex:sender.tag];
    }
}

- (void)show
{
    if (!_show) {

        self.hidden = NO;
        self.show = YES;
        [UIView animateWithDuration:0.3 animations:^{

            self->_contentView.transform = CGAffineTransformIdentity;
            self->_alphView.hidden = NO;

        } completion:^(BOOL finish){

        }];}
}


- (void)dismiss
{
    [self dismissWithTime:0.3];
}

- (void)dismissWithTime:(NSTimeInterval)time
{
    if (_show) {

        self.show = NO;
        __weak __typeof(self)weakself = self;
        [UIView animateWithDuration:time animations:^{

            self->_alphView.hidden = YES;
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight([UIScreen mainScreen].bounds));
            self->_contentView.layer.affineTransform = transform;
        } completion:^(BOOL finished){

            weakself.hidden = YES;
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(browserHide:)]) {

                [weakself.delegate browserHide:weakself];
            }
        }];

    }
}


@end
