//
//  scaner.m
//  yidian
//
//  Created by ajsong on 16/1/6.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "scaner.h"
#import "shopOutlet.h"

@interface scaner ()

@end

@implementation scaner

- (id)init{
	self = [super init];
	if (self) {
		_from = ScanerFromGoods;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	switch (_from) {
		case ScanerFromGoods:{
			
			break;
		}
		case ScanerFromOrder:{
			[self setTip:STRINGFORMAT(@"正在扫描“%@”的二维码，请将二维码放置于方框内进行扫描", _data[@"title"]) font:nil];
			break;
		}
		case ScanerFromShipping:{
			[self setTip:@"请将快递单号的条形码放置于方框内进行扫描" font:nil];
			break;
		}
		default:
			break;
	}
}

- (void)QRCodeReader:(QRCodeReaderController *)reader scanResult:(NSString *)result{
	//resellerApply
	if (_globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteWithCaller:data:)]) {
		if ([result indexOf:@"wap.php?app=eshop&act=other_shop_index"] != NSNotFound) {
			//wap.php?app=eshop&act=other_shop_index&shop_id=10009
			NSDictionary *params = [result params];
			[_globalDelegate GlobalExecuteWithCaller:self data:@{@"code":params[@"shop_id"]}];
			[self pushReturn];
		} else if (result.isInt) {
			[_globalDelegate GlobalExecuteWithCaller:self data:@{@"code":result}];
			[self pushReturn];
		} else {
			[ProgressHUD showError:@"二维码不正确"];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self start];
				});
			});
		}
		return;
	}
	
	//orderShipping
	if (_from==ScanerFromShipping && _globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteShippingNumberWithData:)]) {
		[_globalDelegate GlobalExecuteShippingNumberWithData:@{@"code":result}];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	if (_from==ScanerFromOrder && _globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteGroupWithData:)]) {
		if ([result indexOf:@"/s/"]==NSNotFound) {
			//www.youbesun.com/s/123456789000000834
			[ProgressHUD showError:@"二维码不正确"];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self start];
				});
			});
			return;
		}
		NSString *code = [result preg_replace:@"^.+/s/" with:@""];
		if (code.length==18) {
			NSString *mark = [code substr:8 length:1];
			if ([mark isEqualToString:@"0"]) {
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if (![json[@"data"][@"clientId"]isset] || ![json[@"data"][@"productId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[ProgressHUD showError:@"标签不合法"];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
						return;
					}
//					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
//						[ProgressHUD showError:@"该标签已经绑定到其他商品了"];
//						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
//							dispatch_async(dispatch_get_main_queue(), ^{
//								[self start];
//							});
//						});
//						return;
//					}
					if ([json[@"data"][@"orderId"]isset] && [json[@"data"][@"orderId"]intValue]>0) {
						[ProgressHUD showError:@"该标签的商品已经发货了"];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
						return;
					}
					NSString *str = [_globalDelegate GlobalExecuteGroupWithData:@{@"code":code}];
					if (str.length) {
						if ([str isEqualToString:@"unsametype"]) {
							[ProgressHUD showError:@"该标签与当前商品类型不一致"];
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
								dispatch_async(dispatch_get_main_queue(), ^{
									[self start];
								});
							});
							return;
						}
						if ([str isEqualToString:@"repeat"]) {
							[ProgressHUD showError:@"该标签已扫描过了"];
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
								dispatch_async(dispatch_get_main_queue(), ^{
									[self start];
								});
							});
							return;
						}
						[self.label opacityFn:0.3 afterHidden:^{
							[self setTip:STRINGFORMAT(@"正在扫描“%@”的二维码，请将二维码放置于方框内进行扫描", str) font:nil];
						} completion:nil];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
					} else {
						[self pushReturn];
					}
				} fail:nil];
				return;
			} else {
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if (![json[@"data"][@"clientId"]isset] || ![json[@"data"][@"productId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[ProgressHUD showError:@"标签不合法"];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
						return;
					}
//					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
//						[ProgressHUD showError:@"该标签已经绑定到其他商品了"];
//						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
//							dispatch_async(dispatch_get_main_queue(), ^{
//								[self start];
//							});
//						});
//						return;
//					}
					if ([json[@"data"][@"orderId"]isset] && [json[@"data"][@"orderId"]intValue]>0) {
						[ProgressHUD showError:@"该标签的商品已经发货了"];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
						return;
					}
					[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_codes", @"code":code} success:^(NSMutableDictionary *json) {
						//NSLog(@"%@", json.descriptionASCII);
						if ([json[@"data"] isArray]) {
							NSArray *list = json[@"data"];
							if (!list.isArray) {
								[ProgressHUD showError:@"该标签没有进行入库包装绑定"];
								dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
									dispatch_async(dispatch_get_main_queue(), ^{
										[self start];
									});
								});
								return;
							}
							NSString *str = [_globalDelegate GlobalExecuteGroupWithData:@{@"code":code, @"packages":list}];
							if (str.length) {
								if ([str isEqualToString:@"unsametype"]) {
									[ProgressHUD showError:@"该标签与当前商品类型不一致"];
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
										dispatch_async(dispatch_get_main_queue(), ^{
											[self start];
										});
									});
									return;
								}
								if ([str isEqualToString:@"unsamepackages"]) {
									[ProgressHUD showError:@"该包装包含的标签数跟购买的货品数不一致"];
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
										dispatch_async(dispatch_get_main_queue(), ^{
											[self start];
										});
									});
									return;
								}
								if ([str isEqualToString:@"repeat"]) {
									[ProgressHUD showError:@"该标签已扫描过了"];
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
										dispatch_async(dispatch_get_main_queue(), ^{
											[self start];
										});
									});
									return;
								}
								[self.label opacityFn:0.3 afterHidden:^{
									[self setTip:STRINGFORMAT(@"正在扫描“%@”的二维码，请将二维码放置于方框内进行扫描", str) font:nil];
								} completion:nil];
								dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
									dispatch_async(dispatch_get_main_queue(), ^{
										[self start];
									});
								});
							} else {
								[self pushReturn];
							}
							return;
						}
						[ProgressHUD showError:@"二维码不正确"];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
							dispatch_async(dispatch_get_main_queue(), ^{
								[self start];
							});
						});
					} fail:nil];
				} fail:nil];
				return;
			}
		}
		[ProgressHUD showError:@"二维码不正确"];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self start];
			});
		});
		return;
	}
	
	//goods
	if ([result indexOf:@"wap.php?app=eshop&act=other_shop_index"] != NSNotFound) {
		//wap.php?app=eshop&act=other_shop_index&shop_id=10009
		shopOutlet *e = [[shopOutlet alloc]init];
		e.url = result;
		[self.navigationController pushViewController:e animated:YES];
		
	} else if ([result indexOf:@"wap.php?app=goods&act=detail"] != NSNotFound) {
		//wap.php?app=goods&act=detail&goods_id=205
		shopOutlet *e = [[shopOutlet alloc]init];
		e.url = result;
		[self.navigationController pushViewController:e animated:YES];
		
	} else if ([result indexOf:@"/s/"]!=NSNotFound) {
		//www.youbesun.com/s/123456789000000834
		NSString *code = [result preg_replace:@"^.+/s/" with:@""];
		if (code.length==18) {
			shopOutlet *e = [[shopOutlet alloc]init];
			e.url = result;
			[self.navigationController pushViewController:e animated:YES];
			return;
		}
		[ProgressHUD showError:@"二维码不正确"];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self start];
			});
		});
		
	} else {
		[ProgressHUD showError:@"二维码不正确"];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self start];
			});
		});
		//[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
