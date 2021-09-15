//
//  factoryScaner.m
//  yidian
//
//  Created by ajsong on 16/4/8.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "factoryUnbind.h"

@interface factoryUnbind ()

@end

@implementation factoryUnbind

- (void)viewDidLoad {
	self.isFullscreen = NO;
	[super viewDidLoad];
	self.title = @"解绑标签";
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"切换扫描枪" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		NSLog(@"切换扫描枪");
	}];
	
	self.cancelBtn.hidden = YES;
	[self setTip:@"解绑操作：可以对大、中标签与小标签（层级关系）的解绑，如果需要解绑小标签与产品的关系，请联系优必上商城的客服人员。" font:nil];
}

- (void)QRCodeReader:(QRCodeReaderController *)reader scanResult:(NSString *)result{
	//www.youbesun.com/s/123456780000000643
	//根据第9位数字, 0:一级(商品)(一根烟), 6:二级(小包装)(一盒烟), 8:三级(大包装)(一条烟)
	if ([result hasPrefix:@"http://www.youbesun.com/s/"] || [result hasPrefix:STRINGFORMAT(@"%@/s/", API_URL)]) {
		NSString *code = [result replace:@"http://www.youbesun.com/s/" to:@""];
		code = [code replace:STRINGFORMAT(@"%@/s/", API_URL) to:@""];
		if (code.length==18) {
			[self postUnbind:code];
			return;
		}
	}
	[ProgressHUD showError:@"标签码错误"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self start];
		});
	});
}

#pragma mark - 解绑标签
- (void)postUnbind:(NSString*)code{
	if (!code.length) {
		[ProgressHUD showError:@"请先扫描标签"];
		return;
	}
	if (![PERSON[@"shop"] isset]) {
		[ProgressHUD showError:@"身份错误"];
		return;
	}
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:PERSON[@"shop"][@"id"] forKey:@"clientId"];
	[postData setValue:code forKey:@"code"];
	[ProgressHUD show:nil];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_unpacking"} data:postData feedback:@"nomsg" success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD showSuccess:@"解绑成功"];
		} else {
			[ProgressHUD showError:json[@"msg"]];
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self start];
			});
		});
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
