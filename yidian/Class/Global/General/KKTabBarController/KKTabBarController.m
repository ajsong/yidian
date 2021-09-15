// KKTabBarController.m
// KKTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KKTabBarController.h"
#import "KKTabBarItem.h"
#import <objc/runtime.h>

@interface UIViewController (KKTabBarControllerItemInternal)

- (void)setTabBarControllerKK:(KKTabBarController *)tabBarControllerKK;

@end

@interface KKTabBarController () {
    UIView *_contentView;
}

@property (nonatomic, readwrite) KKTabBar *tabBar;

@end

@implementation KKTabBarController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self contentView]];
    [self.view addSubview:[self tabBar]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSelectedIndex:[self selectedIndex]];
    [self setTabBarHidden:self.isTabBarHidden animated:NO];
}

/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
- (NSUInteger)supportedInterfaceOrientations {
#endif
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    for (UIViewController *viewController in self.viewControllers) {
        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            return UIInterfaceOrientationMaskPortrait;
        }
        
        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];
        
        if (orientationMask > supportedOrientations) {
            orientationMask = supportedOrientations;
        }
    }
    
    return orientationMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    for (UIViewController *viewCotroller in self.viewControllers) {
        if (![viewCotroller respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ||
            ![viewCotroller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    return YES;
}
*/

#pragma mark - Methods

- (UIViewController *)selectedViewController {
    return [self.viewControllers objectAtIndex:[self selectedIndex]];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
	}
	
	UIViewController *controller = self.viewControllers[selectedIndex];
	if ([controller isKindOfClass:[KKTabBarItem class]]) {
		return;
	}
	
	UIViewController *selectedController = [self selectedViewController];
	if ([selectedController isKindOfClass:[KKTabBarItem class]]) {
		return;
	}
    if (selectedController) {
        [selectedController willMoveToParentViewController:nil];
        [selectedController.view removeFromSuperview];
        [selectedController removeFromParentViewController];
	}
	
    _selectedIndex = selectedIndex;
    [self.tabBar setSelectedItem:self.tabBar.items[selectedIndex]];
    [self setSelectedViewController:controller];
    [self addChildViewController:controller];
    controller.view.frame = [self contentView].bounds;
	[[self contentView] addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        _viewControllers = [viewControllers copy];
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        for (UIViewController *viewController in viewControllers) {
			if ([viewController isKindOfClass:[UIViewController class]]) {
				KKTabBarItem *tabBarItem = [[KKTabBarItem alloc] init];
				[tabBarItem setTitle:viewController.title];
				[tabBarItem setHasController:YES];
				[tabBarItems addObject:tabBarItem];
				[viewController setTabBarControllerKK:self];
			} else if ([viewController isKindOfClass:[KKTabBarItem class]]) {
				[tabBarItems addObject:viewController];
			}
        }
        [self.tabBar setItems:tabBarItems];
    } else {
        for (UIViewController *viewController in _viewControllers) {
			if ([viewController isKindOfClass:[UIViewController class]]) {
				[viewController setTabBarControllerKK:nil];
			}
        }
        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    if ([searchedController navigationController]) {
        searchedController = [searchedController navigationController];
    }
    return [self.viewControllers indexOfObject:searchedController];
}

- (KKTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[KKTabBar alloc] init];
        [_tabBar setBackgroundColor:[UIColor clearColor]];
        [_tabBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleTopMargin|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin|
                                      UIViewAutoresizingFlexibleBottomMargin)];
        [_tabBar setDelegate:self];
    }
    return _tabBar;
}

- (CGFloat)tabBarHeight{
	if (_tabBar) {
		if (!self.isTabBarHidden) return _tabBar.frame.size.height;
	}
	return 0;
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
	if (_tabBar) {
		CGRect frame = _tabBar.frame;
		frame.size.height = tabBarHeight;
		_tabBar.frame = frame;
	}
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    _tabBarHidden = hidden;
    
	__weak KKTabBarController *weakSelf = self;
	
    void (^block)() = ^{
        CGSize viewSize = weakSelf.view.bounds.size;
        CGFloat tabBarStartingY = viewSize.height;
        CGFloat contentViewHeight = viewSize.height;
        CGFloat tabBarHeight = CGRectGetHeight([[weakSelf tabBar] frame]);
        
        if (!tabBarHeight) tabBarHeight = 49;
        
        if (!hidden) {
            tabBarStartingY = viewSize.height - tabBarHeight;
            if (![[weakSelf tabBar] isTranslucent]) {
                contentViewHeight -= ([[weakSelf tabBar] minimumContentHeight] ?: tabBarHeight);
            }
            [[weakSelf tabBar] setHidden:NO];
        }
		
		[[weakSelf tabBar] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
		[[weakSelf contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished){
        if (hidden) {
            [[weakSelf tabBar] setHidden:YES];
		}
    };
	
    if (animated) {
        [UIView animateWithDuration:0.24 animations:block completion:completion];
    } else {
        block();
		completion(YES);
    }
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

#pragma mark - KKTabBarDelegate

- (BOOL)tabBar:(KKTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index {
    if ([[self delegate] respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![[self delegate] tabBarController:self shouldSelectViewController:self.viewControllers[index]]) {
            return NO;
        }
    }
    
    if ([self selectedViewController] == self.viewControllers[index]) {
        if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedController = (UINavigationController *)[self selectedViewController];
            
            if ([selectedController topViewController] != [selectedController viewControllers][0]) {
                [selectedController popToRootViewControllerAnimated:YES];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)tabBar:(KKTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.viewControllers.count) {
        return;
    }
    
    [self setSelectedIndex:index];
    
    if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [[self delegate] tabBarController:self didSelectViewController:self.viewControllers[index]];
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle{
	return self.selectedViewController;
}

@end

#pragma mark - UIViewController+KKTabBarControllerItem

@implementation UIViewController (KKTabBarControllerItemInternal)

- (void)setTabBarControllerKK:(KKTabBarController *)tabBarControllerKK {
	objc_setAssociatedObject(self, @selector(tabBarControllerKK), tabBarControllerKK, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIViewController (KKTabBarControllerItem)

- (KKTabBarItem *)tabBarItemKK {
    KKTabBarController *tabBarController = self.tabBarControllerKK;
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBar] items] objectAtIndex:index];
}

- (void)setTabBarItemKK:(KKTabBarItem *)tabBarItemKK {
    KKTabBarController *tabBarController = self.tabBarControllerKK;
    if (!tabBarController) return;
    
    KKTabBar *tabBar = [tabBarController tabBar];
    NSInteger index = [tabBarController indexForViewController:self];
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItemKK];
    [tabBar setItems:tabBarItems];
}

- (KKTabBarController *)tabBarControllerKK {
	KKTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(tabBarControllerKK));
	
	if (!tabBarController && self.parentViewController) {
		tabBarController = self.parentViewController.tabBarControllerKK;
	}
	
	return tabBarController;
}

@end
