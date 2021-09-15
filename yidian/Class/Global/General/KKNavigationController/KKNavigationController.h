//
//  KKNavigationController.h
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved. MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//

#import <UIKit/UIKit.h>

#define DISMISS_COMPLETION_DELAY 0.5

@protocol KKNavigationControllerDelegate;

@interface KKNavigationController : UINavigationController
@property (nonatomic,assign) BOOL enableSystemBack; //系统返回(任何位置拖曳)
@property (nonatomic,assign) BOOL enableDragBack; //拖曳返回
@property (nonatomic,assign) BOOL useShadow; //阴影
@property (nonatomic,assign) BOOL useOverlayer; //背景遮罩
@property (nonatomic,assign) BOOL hiddenUnderLine; //隐藏底部线条
@property (nonatomic,assign) BOOL hiddenBackText; //隐藏返回按钮文字
@property (nonatomic,strong) UIView *navigationBarView; //导航栏背景(导航栏透明用)
@property (nonatomic,retain) UIColor *navigationBarViewColor; //导航栏背景颜色
@property (nonatomic,retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic,retain) id<KKNavigationControllerDelegate> navigationKKDelegate;
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated;
- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)())completion;
@end

@interface UIViewController (KKNavigationController)
- (KKNavigationController*)navigationControllerKK;
@end

@protocol KKNavigationControllerDelegate <NSObject>
@optional
- (Class)navigationPopToViewControllerOfClass:(KKNavigationController *)navigationController; //拖曳或点击返回按钮到指定视图
- (void)navigationPushViewController:(KKNavigationController *)navigationController; //当前视图跳转到下个视图前执行
- (void)navigationPopViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag; //返回到当前视图前执行,isGesture是否拖曳返回
- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag; //返回到当前视图即将显示时执行,isGesture是否拖曳返回
- (void)navigationDidBeginGesture:(KKNavigationController *)navigationController; //当前视图拖曳前执行
- (void)navigationDidEndGesture:(KKNavigationController *)navigationController; //当前视图拖曳释放时执行
@end

//自定义UIBarButtonItem
typedef enum : NSInteger {
	KKNavigationItemTypeLeft = 0,
	KKNavigationItemTypeCenter,
	KKNavigationItemTypeRight,
} KKNavigationItemType;

@interface KKNavigationBarItem : NSObject
@property (nonatomic,strong) UIBarButtonItem *fixBarItem;
@property (nonatomic,strong) UIButton *contentBarItem;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,assign) KKNavigationItemType itemType;
@property (nonatomic,strong) UIView *customView;
@property (nonatomic,assign) BOOL isCustomView;
@property (nonatomic,assign) CGFloat offset; //偏移, leftBarButtonItem使用正数, rightBarButtonItem使用负数
+ (KKNavigationBarItem*)itemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type;
+ (KKNavigationBarItem*)itemWithImage:(UIImage *)image size:(CGSize)size type:(KKNavigationItemType)type;
+ (KKNavigationBarItem*)itemWithCustomeView:(UIView *)customView type:(KKNavigationItemType)type;
- (void)setItemWithNavigationItem:(UINavigationItem *)navigationItem itemType:(KKNavigationItemType)type;
- (void)setOffset:(CGFloat)offSet; //设置item偏移量,正值向左偏，负值向右偏
- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)event;
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block;
@end
@interface UINavigationItem (NavigationBarItem)
- (KKNavigationBarItem*)setItemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithImage:(UIImage *)image size:(CGSize)size itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithCustomView:(UIView *)customView itemType:(KKNavigationItemType)type;
@end
