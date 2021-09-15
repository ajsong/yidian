//
//  factoryScaner.m
//  yidian
//
//  Created by ajsong on 16/7/4.
//  Copyright © 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "factoryScaner.h"
#import "factory.h"

@interface factoryScaner (){
	int _goodsIndex;
	
	UILabel *_numLabel;
	UILabel *_tipLabel;
	UIButton *_btn;
	
	NSMutableArray *_codes;
	NSString *_code;
	NSInteger _capacity;
	NSInteger _capacity2;
	NSInteger _count;
	
	NSMutableArray *_codeDatas;
	NSMutableArray *_codes1;
	NSMutableArray *_codes2;
	NSMutableArray *_codes3;
}
@end

@implementation factoryScaner

- (void)viewDidLoad {
	self.autoStart = NO;
	self.isFullscreen = NO;
	[super viewDidLoad];
	self.title = @"扫描标签";
	
	_codes = [[NSMutableArray alloc]init];
	_codeDatas = [self getDatas];
	_codes1 = [[NSMutableArray alloc]init];
	_codes2 = [[NSMutableArray alloc]init];
	_codes3 = [[NSMutableArray alloc]init];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"切换扫描枪" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		//NSLog(@"切换扫描枪");
		[ProgressHUD showSuccess:@"暂未开发，敬请期待"];
	}];
	
	self.cancelBtn.hidden = YES;
	[self setTip:@"" font:nil];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 62)];
	view.backgroundColor = WHITE;
	[self.view addSubview:view];
	
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 42, 42)];
	pic.image = IMG(@"nopic");
	pic.url = _data[@"default_pic"];
	[view addSubview:pic];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(pic.right+10, pic.top, view.width-(pic.right+10)-10, pic.height-15)];
	label.text = STRINGFORMAT(@"%@ (编号:%@)", _data[@"name"], _data[@"id"]);
	label.textColor = [UIColor blackColor];
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.8;
	label.adjustsFontSizeToFitWidth = YES;
	[view addSubview:label];
	
	_numLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.left, pic.bottom-10, label.width, 10)];
	_numLabel.text = STRINGFORMAT(@"已扫描：%ld", (long)_codes.count);
	_numLabel.textColor = COLOR999;
	_numLabel.font = FONT(10);
	_numLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_numLabel];
	
	_tipLabel = [[UILabel alloc]initWithFrame:_numLabel.frame];
	_tipLabel.textColor = COLOR999;
	_tipLabel.textAlignment = NSTextAlignmentRight;
	_tipLabel.font = FONT(10);
	_tipLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_tipLabel];
	
	_btn = [UIButton buttonWithType:UIButtonTypeCustom];
	_btn.frame = CGRectMake((SCREEN_WIDTH-76)/2, self.scanFrame.origin.y+self.scanFrame.size.height+25, 76, 76);
	_btn.titleLabel.font = FONT(15);
	_btn.backgroundColor = COLORRGB(@"ff788a");
	[_btn setTitle:@"完成" forState:UIControlStateNormal];
	[_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	_btn.layer.masksToBounds = YES;
	_btn.layer.cornerRadius = _btn.height/2;
	[self.view addSubview:_btn];
	
	BOOL hasHistory = NO;
	if (!_codeDatas.isArray) {
		for (int i=0; i<=_type; i++) {
			[_codeDatas addObject:[[NSMutableArray alloc]init]];
		}
	} else {
		hasHistory = YES;
	}
	
	switch (_type) {
		case PackageType1:{
			[self changeTipLabel:@"扫描小标签"];
			[_btn addTarget:self action:@selector(postPackage1) forControlEvents:UIControlEventTouchUpInside];
			NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
			for (int i=0; i<codes1.count; i++) {
				[_codes addObject:codes1[i]];
				[_codes1 addObject:codes1[i]];
			}
			[self start];
			break;
		}
		case PackageType2:{
			[_btn addTarget:self action:@selector(postPackage2) forControlEvents:UIControlEventTouchUpInside];
			if (hasHistory) {
				_capacity = [@"capacity" getUserDefaultsInteger];
				if (_capacity) {
					NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
					for (int i=0; i<codes1.count; i++) {
						[_codes addObject:codes1[i]];
						if (_codes1.count>=_capacity) _codes1 = [[NSMutableArray alloc]init];
						[_codes1 addObject:codes1[i]];
					}
					NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
					for (int i=0; i<codes2.count; i++) {
						[_codes addObject:codes2[i]];
						[_codes2 addObject:codes2[i]];
					}
					if (_subType==PackageSubType1) {
						[self changeTipLabel:(codes1.count*_capacity==codes1.count) ? @"扫描小标签" :  @"扫描中标签"];
					} else {
						[self changeTipLabel:(codes2.count*_capacity==codes1.count) ? @"扫描中标签" :  @"扫描大标签"];
					}
					
					if (fmod(codes1.count, _capacity)==0 && fmod(codes1.count+codes2.count, _capacity+1)!=0) {
						[self changeTipLabel:STRINGFORMAT(@"扫描%@标签", _subType==PackageSubType1 ? @"中" : @"大")];
					} else {
						[self changeTipLabel:STRINGFORMAT(@"扫描%@标签", _subType==PackageSubType1 ? @"小" : @"中")];
					}
					if (fmod(codes1.count+codes2.count, _capacity+1)==0) {
						[_codes1 removeAllObjects];
					}
					[self start];
				} else {
					[self performSelector:@selector(showSecond) withObject:nil afterDelay:0.8];
				}
			} else {
				[self showSecond];
			}
			break;
		}
		case PackageType3:{
			[_btn addTarget:self action:@selector(postPackage3) forControlEvents:UIControlEventTouchUpInside];
			if (hasHistory) {
				_capacity = [@"capacity" getUserDefaultsInteger];
				_capacity2 = [@"capacity2" getUserDefaultsInteger];
				if (_capacity) {
					NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
					for (int i=0; i<codes1.count; i++) {
						[_codes addObject:codes1[i]];
						if (_codes1.count>=_capacity) _codes1 = [[NSMutableArray alloc]init];
						[_codes1 addObject:codes1[i]];
					}
					NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
					for (int i=0; i<codes2.count; i++) {
						[_codes addObject:codes2[i]];
						if (_codes2.count>=_capacity2) _codes2 = [[NSMutableArray alloc]init];
						[_codes2 addObject:codes2[i]];
					}
					NSMutableArray *codes3 = [NSMutableArray arrayWithArray:_codeDatas[2]];
					for (int i=0; i<codes3.count; i++) {
						[_codes addObject:codes3[i]];
						[_codes3 addObject:codes3[i]];
					}
					if (fmod(codes1.count, _capacity)==0 && fmod(codes1.count+codes2.count, _capacity+1)!=0) {
						[self changeTipLabel:@"扫描中标签"];
					} else if (codes2.count && fmod(codes2.count, _capacity2)==0 && codes3.count*_capacity2!=codes2.count) {
						[self changeTipLabel:@"扫描大标签"];
					} else {
						[self changeTipLabel:@"扫描小标签"];
						if (fmod(codes1.count+codes2.count, _capacity+1)==0 || (codes2.count && fmod(codes2.count+codes3.count, _capacity2+1)==0)) {
							[_codes1 removeAllObjects];
						}
					}
					[self start];
				} else {
					[self performSelector:@selector(showThird) withObject:nil afterDelay:0.8];
				}
			} else {
				[self showThird];
			}
			break;
		}
	}
	[self changeNumLabel];
}

- (void)QRCodeReader:(QRCodeReaderController *)reader scanResult:(NSString *)result{
	//www.youbesun.com/s/123456780000000643
	//根据第9位数字, 0:小(商品)(一根烟), 6:中(小包装)(一盒烟), 8:大(大包装)(一条烟)
	if ([result indexOf:@"/s/"]==NSNotFound) {
		[self continueStart:@"标签码错误"];
		return;
	}
	
	NSString *code = [result preg_replace:@"^.+/s/" with:@""];
	if (code.length!=18) {
		[self continueStart:@"标签码错误"];
		return;
	}
	
	if ([code inArray:_codes]!=NSNotFound) {
		[self continueStart:@"该标签已扫描过了"];
		return;
	}
	
	NSArray *markArr = @[@"0", @"6", @"8"];
	NSString *mark = [code substr:8 length:1];
	NSInteger index = [markArr indexOfObject:mark];
	switch (_type) {
		case PackageType1:{
			if (index!=0) {
				[self continueStart:@"标签码错误"];
				return;
			}
			NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
			[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
				if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
					[self continueStart:@"标签不合法"];
					return;
				}
				if ([json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
					[self continueStart:@"该标签已经绑定过了"];
					return;
				}
				if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
					[self continueStart:@"该标签已经绑定到其他商品了"];
					return;
				}
				[codes1 addObject:code];
				[_codeDatas replaceObjectAtIndex:0 withObject:codes1];
				[self setDatas];
				[_codes1 addObject:code];
				[self addCodes:code];
				[self continueStart:nil];
			} fail:nil];
			break;
		}
		case PackageType2:{
			NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
			NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
			if (index==(_subType==PackageSubType1?0:1)) {
				if (_codes1.count>=_capacity) {
					[self continueStart:_subType==PackageSubType1?@"容量已满，请扫描中标签":@"容量已满，请扫描大标签"];
					return;
				}
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[self continueStart:@"该标签不合法"];
						return;
					}
					if (_subType==PackageSubType1 && [json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
						[self continueStart:@"该标签已经绑定过了"];
						return;
					}
					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
						[self continueStart:@"该标签已经绑定到其他商品了"];
						return;
					}
					[codes1 addObject:code];
					[_codeDatas replaceObjectAtIndex:0 withObject:codes1];
					[self setDatas];
					[_codes1 addObject:code];
					if (_codes1.count==_capacity) [self changeTipLabel:_subType==PackageSubType1?@"扫描中标签":@"扫描大标签"];
					[self addCodes:code];
					[self continueStart:nil];
				} fail:nil];
			} else if (index==(_subType==PackageSubType1?1:2)) {
				if (!_codes1.count || fmod(_codes1.count, _capacity)>0) {
					[self continueStart:STRINGFORMAT(@"当前容量为%ld，请先把%@标签数量扫描完整", (long)_capacity, _subType==PackageSubType1?@"小":@"中")];
					return;
				}
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[self continueStart:@"该标签不合法"];
						return;
					}
					if ([json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
						[self continueStart:@"该标签已经绑定过了"];
						return;
					}
					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
						[self continueStart:@"该标签已经绑定到其他商品了"];
						return;
					}
					[codes2 addObject:code];
					[_codeDatas replaceObjectAtIndex:1 withObject:codes2];
					[self setDatas];
					[_codes2 addObject:code];
					[self addCodes:code];
					if (fmod(_codes1.count, _capacity)==0) {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"包装完毕，是否继续扫描入库？" delegate:nil cancelButtonTitle:@"完毕" otherButtonTitles:@"继续",nil];
						[alert showWithBlock:^(NSInteger buttonIndex) {
							if (buttonIndex==1) {
								[self changeTipLabel:_subType==PackageSubType1?@"扫描小标签":@"扫描中标签"];
								[_codes1 removeAllObjects];
								[_codes2 removeAllObjects];
								[_codes3 removeAllObjects];
								[self continueStart:nil];
							}
						}];
						return;
					}
					[self continueStart:nil];
				} fail:nil];
			} else {
				[self continueStart:@"标签码错误"];
				return;
			}
			break;
		}
		case PackageType3:{
			NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
			NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
			NSMutableArray *codes3 = [NSMutableArray arrayWithArray:_codeDatas[2]];
			if (index==0) {
				if (_codes1.count>=_capacity) {
					[self continueStart:@"容量已满，请扫描中标签"];
					return;
				}
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[self continueStart:@"该标签不合法"];
						return;
					}
					if ([json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
						[self continueStart:@"该标签已经绑定过了"];
						return;
					}
					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
						[self continueStart:@"该标签已经绑定到其他商品了"];
						return;
					}
					[codes1 addObject:code];
					[_codeDatas replaceObjectAtIndex:0 withObject:codes1];
					[self setDatas];
					[_codes1 addObject:code];
					if (_codes1.count==_capacity) [self changeTipLabel:@"扫描中标签"];
					[self addCodes:code];
					[self continueStart:nil];
				} fail:nil];
			} else if (index==1) {
				if (!_codes1.count || fmod(_codes1.count, _capacity)>0) {
					[self continueStart:STRINGFORMAT(@"当前容量为%ld，请先把小标签数量扫描完整", (long)_capacity)];
					return;
				}
				if (_codes2.count>=_capacity2) {
					[self continueStart:@"容量已满，请扫描大标签"];
					return;
				}
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[self continueStart:@"该标签不合法"];
						return;
					}
					if ([json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
						[self continueStart:@"该标签已经绑定过了"];
						return;
					}
					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
						[self continueStart:@"该标签已经绑定到其他商品了"];
						return;
					}
					[codes2 addObject:code];
					[_codeDatas replaceObjectAtIndex:1 withObject:codes2];
					[self setDatas];
					[_codes2 addObject:code];
					if (_codes2.count==_capacity2) {
						[self changeTipLabel:@"扫描大标签"];
					} else {
						[_codes1 removeAllObjects];
						[self changeTipLabel:@"扫描小标签"];
					}
					[self addCodes:code];
					[self continueStart:nil];
				} fail:nil];
			} else if (index==2) {
				if (!_codes2.count || fmod(_codes2.count, _capacity2)>0) {
					[self continueStart:STRINGFORMAT(@"当前容量为%ld，请先把中标签数量扫描完整", (long)_capacity2)];
					return;
				}
				[Common getApiWithParams:@{@"app":@"member", @"act":@"factory_code", @"code":code} success:^(NSMutableDictionary *json) {
					if (![json[@"data"][@"clientId"]isset] || [json[@"data"][@"clientId"]intValue]!=[PERSON[@"shop"][@"id"]intValue]) {
						[self continueStart:@"标签不合法"];
						return;
					}
					if ([json[@"data"][@"count"]isset] && [json[@"data"][@"count"]intValue]>0) {
						[self continueStart:@"该标签已经绑定过了"];
						return;
					}
					if ([json[@"data"][@"productId"]isset] && [json[@"data"][@"productId"]intValue]!=[_data[@"id"]intValue]) {
						[self continueStart:@"该标签已经绑定到其他商品了"];
						return;
					}
					[codes3 addObject:code];
					[_codeDatas replaceObjectAtIndex:2 withObject:codes3];
					[self setDatas];
					[_codes3 addObject:code];
					[self addCodes:code];
					if (fmod(_codes2.count, _capacity2)==0) {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"包装完毕，是否继续扫描入库？" delegate:nil cancelButtonTitle:@"完毕" otherButtonTitles:@"继续",nil];
						[alert showWithBlock:^(NSInteger buttonIndex) {
							if (buttonIndex==1) {
								[self changeTipLabel:@"扫描小标签"];
								[_codes1 removeAllObjects];
								[_codes2 removeAllObjects];
								[_codes3 removeAllObjects];
								[self continueStart:nil];
							}
						}];
						return;
					}
					[self continueStart:nil];
				} fail:nil];
			} else {
				[self continueStart:@"标签码错误"];
				return;
			}
			break;
		}
	}
}

- (void)continueStart:(NSString*)msg{
	if (msg.length) [ProgressHUD showError:msg];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self start];
		});
	});
}

#pragma mark - 显示扫描结果
- (void)addCodes:(NSString*)code{
	[_codes addObject:code];
	[self changeNumLabel];
}
- (void)changeNumLabel{
	_numLabel.text = STRINGFORMAT(@"已扫描：%ld", (long)_codes.count);
}

- (void)changeTipLabel:(NSString*)tip{
	_tipLabel.text = STRINGFORMAT(@"当前需要：%@", tip);
	[UIView transitionWithView:_tipLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		_tipLabel.textColor = RED;
	} completion:^(BOOL finished) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[UIView transitionWithView:_tipLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
					_tipLabel.textColor = COLOR999;
				} completion:^(BOOL finished) {
					
				}];
			});
		});
	}];
}

#pragma mark - 即时数据操作
- (NSMutableArray*)getDatas{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	NSArray *goods = [@"scanDatas" getUserDefaultsArray];
	for (int i=0; i<goods.count; i++) {
		NSDictionary *data = goods[i];
		if ([data[@"id"]intValue] == [_data[@"id"]intValue]) {
			_goodsIndex = i;
			datas = [NSMutableArray arrayWithArray:data[@"scanDatas"]];
			break;
		}
	}
	return datas;
}

- (void)setDatas{
	NSMutableArray *goods = [@"scanDatas" getUserDefaultsArray];
	NSMutableDictionary *data = goods.isArray ? [NSMutableDictionary dictionaryWithDictionary:goods[_goodsIndex]] : [[NSMutableDictionary alloc]init];
	[data setObject:_codeDatas forKey:@"scanDatas"];
	goods.isArray ? [goods replaceObjectAtIndex:_goodsIndex withObject:data] : [goods addObject:data];
	[@"scanDatas" setUserDefaultsWithData:goods];
}

#pragma mark - 中标签容量设置
- (void)showSecond{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, 0)];
	view.backgroundColor = WHITE;
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 5;
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, 44)];
	label.text = _subType==PackageSubType1?@"设置中标签的容量":@"设置大标签的容量";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(17);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label addGeWithType:GeLineTypeBottom];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom+10, label.width, 30)];
	label.text = _subType==PackageSubType1?@"设置每个中标签":@"设置每个大标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.text = _subType==PackageSubType1?@"包含　　　个小标签":@"包含　　　个中标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.userInteractionEnabled = YES;
	[view addSubview:label];
	
	SpecialTextField *textField = [[SpecialTextField alloc]initWithFrame:CGRectMake(75, (label.height-22)/2, 35, 22)];
	textField.textColor = [UIColor blackColor];
	textField.textAlignment = NSTextAlignmentCenter;
	textField.font = FONT(13);
	textField.backgroundColor = COLORRGB(@"ededed");
	textField.layer.borderColor = COLORCCC.CGColor;
	textField.layer.borderWidth = 0.5;
	textField.keyboardType = UIKeyboardTypeNumberPad;
	[label addSubview:textField];
	textField.maxLength = 3;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(label.left, label.bottom+10, (label.width-10)/2, 40)];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = COLORRGB(@"da0025");
	[btn setTitle:@"确认" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		if (textField.text.integerValue<=0) {
			[ProgressHUD showError:@"数量无效"];
			return;
		}
		[self changeTipLabel:_subType==PackageSubType1?@"扫描小标签":@"扫描中标签"];
		[ProgressHUD showSuccess:_subType==PackageSubType1?@"现在开始扫描小标签":@"现在开始扫描中标签"];
		_capacity = textField.text.integerValue;
		[@"capacity" setUserDefaultsWithData:@(_capacity)];
		
		NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
		for (int i=0; i<codes1.count; i++) {
			[_codes addObject:codes1[i]];
			if (_codes1.count>=_capacity) _codes1 = [[NSMutableArray alloc]init];
			[_codes1 addObject:codes1[i]];
		}
		NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
		for (int i=0; i<codes2.count; i++) {
			[_codes addObject:codes2[i]];
			[_codes2 addObject:codes2[i]];
		}
		
		[self dismissAlertView:DYAlertViewScale completion:^{
			[self continueStart:nil];
		}];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:[btn frameRight:10]];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = COLOR999;
	[btn setTitle:@"返回" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self dismissAlertView:DYAlertViewScale];
		[self.navigationController popViewControllerAnimated:YES];
	}];
	[view addSubview:btn];
	
	view.height = btn.bottom+15;
	view.element[@"close"] = @NO;
	
	[textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
	[self presentAlertView:view animation:DYAlertViewScale];
}

#pragma mark - 大标签容量设置
- (void)showThird{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, 0)];
	view.backgroundColor = WHITE;
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 5;
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15*2, 44)];
	label.text = @"设置大标签的容量";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(17);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label addGeWithType:GeLineTypeBottom];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom+10, label.width, 30)];
	label.text = @"设置每个大标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.text = @"包含　　　个中标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.userInteractionEnabled = YES;
	[view addSubview:label];
	
	SpecialTextField *textField = [[SpecialTextField alloc]initWithFrame:CGRectMake(75, (label.height-22)/2, 35, 22)];
	textField.textColor = [UIColor blackColor];
	textField.textAlignment = NSTextAlignmentCenter;
	textField.font = FONT(13);
	textField.backgroundColor = COLORRGB(@"ededed");
	textField.layer.borderColor = COLORCCC.CGColor;
	textField.layer.borderWidth = 0.5;
	textField.keyboardType = UIKeyboardTypeNumberPad;
	[label addSubview:textField];
	textField.maxLength = 3;
	
	UIView *ge = [[UIView alloc]initWithFrame:CGRectMake(15, label.bottom+10, view.width-15*2, 0.5)];
	ge.backgroundColor = COLOR_GE;
	[view addSubview:ge];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(label.left, ge.bottom+10, label.width, 30)];
	label.text = @"设置每个中标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.text = @"包含　　　个小标签";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(13);
	label.backgroundColor = [UIColor clearColor];
	label.userInteractionEnabled = YES;
	[view addSubview:label];
	
	SpecialTextField *textField2 = [[SpecialTextField alloc]initWithFrame:CGRectMake(75, (label.height-22)/2, 35, 22)];
	textField2.textColor = [UIColor blackColor];
	textField2.textAlignment = NSTextAlignmentCenter;
	textField2.font = FONT(13);
	textField2.backgroundColor = COLORRGB(@"ededed");
	textField2.layer.borderColor = COLORCCC.CGColor;
	textField2.layer.borderWidth = 0.5;
	textField2.keyboardType = UIKeyboardTypeNumberPad;
	[label addSubview:textField2];
	textField2.maxLength = 3;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(label.left, label.bottom+10, (label.width-10)/2, 40)];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = COLORRGB(@"da0025");
	[btn setTitle:@"确认" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		if (textField.text.integerValue<=0 || textField2.text.integerValue<=0) {
			[ProgressHUD showError:@"数量无效"];
			return;
		}
		[self changeTipLabel:@"扫描小标签"];
		[ProgressHUD showSuccess:@"现在开始扫描小标签"];
		_capacity2 = textField.text.integerValue;
		_capacity = textField2.text.integerValue;
		[@"capacity" setUserDefaultsWithData:@(_capacity)];
		[@"capacity2" setUserDefaultsWithData:@(_capacity2)];
		
		NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
		for (int i=0; i<codes1.count; i++) {
			[_codes addObject:codes1[i]];
			if (_codes1.count>=_capacity) _codes1 = [[NSMutableArray alloc]init];
			[_codes1 addObject:codes1[i]];
		}
		NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
		for (int i=0; i<codes2.count; i++) {
			[_codes addObject:codes2[i]];
			if (_codes2.count>=_capacity2) _codes2 = [[NSMutableArray alloc]init];
			[_codes2 addObject:codes2[i]];
		}
		NSMutableArray *codes3 = [NSMutableArray arrayWithArray:_codeDatas[2]];
		for (int i=0; i<codes3.count; i++) {
			[_codes addObject:codes3[i]];
			[_codes3 addObject:codes3[i]];
		}
		
		[self dismissAlertView:DYAlertViewScale completion:^{
			[self continueStart:nil];
		}];
	}];
	[view addSubview:btn];
	
	btn = [[UIButton alloc]initWithFrame:[btn frameRight:10]];
	btn.titleLabel.font = FONT(15);
	btn.backgroundColor = COLOR999;
	[btn setTitle:@"返回" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self dismissAlertView:DYAlertViewScale];
		[self.navigationController popViewControllerAnimated:YES];
	}];
	[view addSubview:btn];
	
	view.height = btn.bottom+15;
	view.element[@"close"] = @NO;
	
	[textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
	[self presentAlertView:view animation:DYAlertViewScale];
}

#pragma mark - 绑定一级包装
- (void)postPackage1{
	if (!_codes.count) {
		[ProgressHUD showError:@"请先扫描标签"];
		return;
	}
	[self stop];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:PERSON[@"shop"][@"id"] forKey:@"clientId"];
	[postData setValue:_data[@"id"] forKey:@"productId"];
	[postData setValue:@"true" forKey:@"bind"];
	[postData setValue:_codes.jsonString forKey:@"body"];
	[ProgressHUD show:nil];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_product"} data:postData timeout:-1 feedback:nil success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD showSuccess:@"绑定成功"];
			if (_globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteWithData:)]) {
				[_globalDelegate GlobalExecuteWithData:@{@"codes":_codes, @"codeDatas":_codeDatas}];
			}
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self continueStart:json[@"msg"]];
		}
	} fail:nil];
}

#pragma mark - 绑定二级包装
- (void)postPackage2{
	if (!_codes.count) {
		[ProgressHUD showError:@"请先扫描标签"];
		return;
	}
	
	NSMutableArray *codeDatas = [[NSMutableArray alloc]init];
	NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
	NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
	if (codes1.count>=_capacity) {
		for (int j=0; j<codes2.count; j++) {
			NSMutableDictionary *data2 = [[NSMutableDictionary alloc]init];
			NSMutableArray *datas = [[NSMutableArray alloc]init];
			for (int i=0; i<codes1.count; i++) {
				[datas addObject:codes1[i]];
				if (fmod(i+1, _capacity)==0) {
					[data2 setObject:datas forKey:codes2[j]];
					datas = [[NSMutableArray alloc]init];
					[codes1 removeObjectsInRange:NSMakeRange(0, _capacity)];
					break;
				}
			}
			[codeDatas addObject:data2];
		}
	}
	
	if (!codeDatas.isArray) {
		[ProgressHUD showError:@"请先把标签扫描完整"];
		return;
	}
	[self stop];
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:PERSON[@"shop"][@"id"] forKey:@"clientId"];
	[postData setValue:_data[@"id"] forKey:@"productId"];
	//[postData setValue:@"true" forKey:@"bind"];
	[postData setValue:codeDatas.jsonString forKey:@"body"];
	[ProgressHUD show:nil];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_package2"} data:postData timeout:-1 feedback:nil success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD showSuccess:@"绑定成功"];
			if (_globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteWithData:)]) {
				[_globalDelegate GlobalExecuteWithData:@{@"codes":_codes, @"codeDatas":codeDatas}];
			}
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self continueStart:json[@"msg"]];
		}
	} fail:nil];
}

#pragma mark - 绑定三级包装
- (void)postPackage3{
	if (!_codes.count) {
		[ProgressHUD showError:@"请先扫描标签"];
		return;
	}
	
	NSMutableArray *codeDatas = [[NSMutableArray alloc]init];
	NSMutableArray *codes1 = [NSMutableArray arrayWithArray:_codeDatas[0]];
	NSMutableArray *codes2 = [NSMutableArray arrayWithArray:_codeDatas[1]];
	NSMutableArray *codes3 = [NSMutableArray arrayWithArray:_codeDatas[2]];
	if (codes1.count>=_capacity && codes2.count>=_capacity2) {
		for (int k=0; k<codes3.count; k++) {
			NSMutableDictionary *data3 = [[NSMutableDictionary alloc]init];
			NSMutableArray *datas2 = [[NSMutableArray alloc]init];
			for (int j=0; j<codes2.count; j++) {
				NSMutableDictionary *data2 = [[NSMutableDictionary alloc]init];
				NSMutableArray *datas = [[NSMutableArray alloc]init];
				for (int i=0; i<codes1.count; i++) {
					[datas addObject:codes1[i]];
					if (fmod(i+1, _capacity)==0) {
						[data2 setObject:datas forKey:codes2[j]];
						datas = [[NSMutableArray alloc]init];
						[codes1 removeObjectsInRange:NSMakeRange(0, _capacity)];
						break;
					}
				}
				[datas2 addObject:data2];
				if (fmod(j+1, _capacity2)==0) {
					[data3 setObject:datas2 forKey:codes3[k]];
					datas2 = [[NSMutableArray alloc]init];
					[codes2 removeObjectsInRange:NSMakeRange(0, _capacity2)];
					break;
				}
			}
			[codeDatas addObject:data3];
		}
	}
	
	if (!codeDatas.isArray) {
		[ProgressHUD showError:@"请先把标签扫描完整"];
		return;
	}
	[self stop];
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:PERSON[@"shop"][@"id"] forKey:@"clientId"];
	[postData setValue:_data[@"id"] forKey:@"productId"];
	//[postData setValue:@"true" forKey:@"bind"];
	[postData setValue:codeDatas.jsonString forKey:@"body"];
	[ProgressHUD show:nil];
	[Common postApiWithParams:@{@"app":@"member", @"act":@"factory_package2"} data:postData timeout:-1 feedback:nil success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			[ProgressHUD showSuccess:@"绑定成功"];
			if (_globalDelegate && [_globalDelegate respondsToSelector:@selector(GlobalExecuteWithData:)]) {
				[_globalDelegate GlobalExecuteWithData:@{@"codes":_codes, @"codeDatas":codeDatas}];
			}
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self continueStart:json[@"msg"]];
		}
	} fail:nil];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
