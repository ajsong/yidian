//
//  shopOutlet.m
//  yidianb
//
//  Created by ajsong on 16/2/25.
//  Copyright (c) 2016年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "shopOutlet.h"
#import "talk.h"
#import "resellerApply.h"

@interface shopOutlet (){
	NSMutableDictionary *_person;
	NSDictionary *_data;
	
	ShareHelper *_shareView;
	UIButton *_shareBtn;
	UIButton *_applyBtn;
	UIView *_resellerView;
}
@end

@implementation shopOutlet

- (void)viewDidLoad {
	self.userAgentMark = @"youbesun";
	self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
	
	_person = PERSON;
	_data = [[NSDictionary alloc]init];
	_shareView = [[ShareHelper alloc]init];
	
	_shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
	_shareBtn.titleLabel.font = FONT(14);
	_shareBtn.backgroundColor = [UIColor clearColor];
	[_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
	[_shareBtn setTitleColor:NAVTEXTCOLOR forState:UIControlStateNormal];
	_shareBtn.hidden = YES;
	[self.navigationItem setItemWithCustomView:_shareBtn itemType:KKNavigationItemTypeRight];
	
	_applyBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.height-42, SCREEN_WIDTH, 42)];
	_applyBtn.titleLabel.font = FONT(15);
	_applyBtn.backgroundColor = MAINSUBCOLOR;
	[_applyBtn setTitle:@"申请成为渠道商" forState:UIControlStateNormal];
	[_applyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_applyBtn addTarget:self action:@selector(pushApply) forControlEvents:UIControlEventTouchUpInside];
	_applyBtn.hidden = YES;
	[self.view addSubview:_applyBtn];
	
	_resellerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-42, SCREEN_WIDTH, 42)];
	_resellerView.hidden = YES;
	[self.view addSubview:_resellerView];
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 106.5, _resellerView.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn1") forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(openChat) forControlEvents:UIControlEventTouchUpInside];
	[_resellerView addSubview:btn];
	btn = [[UIButton alloc]initWithFrame:CGRectMake(btn.right, 0, 106.5, _resellerView.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn2") forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(openSms) forControlEvents:UIControlEventTouchUpInside];
	[_resellerView addSubview:btn];
	btn = [[UIButton alloc]initWithFrame:CGRectMake(btn.right, 0, 107, _resellerView.height)];
	btn.backgroundColor = [UIColor clearColor];
	btn.adjustsImageWhenHighlighted = NO;
	[btn setBackgroundImage:IMG(@"s-reseller-btn3") forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(openCall) forControlEvents:UIControlEventTouchUpInside];
	[_resellerView addSubview:btn];
}

- (void)OutletDidFinishLoad:(NSString *)url html:(NSString *)html{
	_shareBtn.hidden = YES;
	_applyBtn.hidden = YES;
	_resellerView.hidden = YES;
	self.webView.height = self.view.height;
	NSLog(@"%@", url);
	if ([url indexOf:@"wap.php?app=goods&act=detail&goods_id="]!=NSNotFound) { //wap.php?app=goods&act=detail&goods_id=260
		_shareBtn.hidden = NO;
		if ([html indexOf:@"<textarea id=\"json\""] != NSNotFound) {
			[self.webView evaluateJavaScript:@"document.getElementById('json').value" completionHandler:^(id obj, NSError *error) {
				_data = [obj formatJson];
				//NSLog(@"%@", _data.descriptionASCII);
				[_shareBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
				[_shareBtn addTarget:self action:@selector(goodsShare) forControlEvents:UIControlEventTouchUpInside];
			}];
		}
		self.title = @"商品详情";
	} else {
		self.title = @"店铺详情";
	}
	if ([url indexOf:@"wap.php?app=eshop&act=other_shop_index&shop_id="]!=NSNotFound || [url indexOf:@"wap.php?app=eshop&act=other_shop_index_types&shop_id="]!=NSNotFound) { //wap.php?app=eshop&act=other_shop_index&shop_id=10054
		_shareBtn.hidden = NO;
		if ([html indexOf:@"<textarea id=\"json\""] != NSNotFound) {
			[self.webView evaluateJavaScript:@"document.getElementById('json').value" completionHandler:^(id obj, NSError *error) {
				_data = [obj formatJson];
				[_shareBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
				[_shareBtn addTarget:self action:@selector(shopShare) forControlEvents:UIControlEventTouchUpInside];
				if ([_person[@"member_type"]intValue]==2) {
					self.webView.height = self.view.height - 42;
					if ([_data[@"is_reseller"]integerValue]==0) {
						_applyBtn.hidden = NO;
					} else {
						_resellerView.hidden = NO;
					}
				}
			}];
		}
	}
}

- (void)shopShare{
	if (!_data.isDictionary) return;
	[_data[@"avatar"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
		NSString *reseller = @"";
		if (_person.isDictionary && [_person[@"shop"] isset]) reseller = _person[@"shop"][@"id"];
		[ShareHelper shareWithUrl:STRINGFORMAT(@"%@/wap.php?app=eshop&act=other_shop_index&shop_id=%@&reseller=%@", API_URL, _data[@"id"], reseller) title:_data[@"name"] content:_data[@"description"] image:image completion:nil];
	}];
}

- (void)goodsShare{
	if (!_data.isDictionary) return;
	NSString *reseller = @"";
	if (_person.isDictionary && [_person[@"shop"] isset]) reseller = _person[@"shop"][@"id"];
	NSString *url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@&reseller=%@", API_URL, _data[@"id"], reseller);
	if ([_data[@"default_pic"] length]) {
		[_data[@"default_pic"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
			_shareView.title = _data[@"name"];
			_shareView.image = image;
			_shareView.url = url;
			_shareView.content = _data[@"description"];
			[_shareView show];
		}];
	} else {
		_shareView.title = _data[@"name"];
		_shareView.image = IMG(@"AppIcon60x60");
		_shareView.url = url;
		_shareView.content = _data[@"description"];
		[_shareView show];
	}
}

- (void)pushApply{
	if (!_data.isDictionary) return;
	resellerApply *e = [[resellerApply alloc]init];
	e.data = _data;
	[self.navigationController pushViewController:e animated:YES];
}
- (void)openChat{
	if (!_data.isDictionary) return;
	if (![EaseSDKHelper isLogin]) {
		[self showLoginController];
		return;
	}
	NSString *chatter = STRING(_data[@"member_id"]);
	if ([chatter isEqualToString:STRING(_person[@"id"])]) {
		[ProgressHUD showError:@"不能与自己聊天"];
		return;
	}
	talk *e = [[talk alloc]initWithConversationChatter:chatter conversationType:EMConversationTypeChat];
	e.title = _data[@"shop_name"] ? _data[@"shop_name"] : _data[@"member_name"];
	//e.goods = @{@"goods_id":_data[@"id"], @"goods_name":_data[@"name"], @"goods_image":_data[@"default_pic"]};
	[self.navigationController pushViewController:e animated:YES];
}
- (void)openSms{
	if (!_data.isDictionary) return;
	[Global openSms:_data[@"mobile"]];
}
- (void)openCall{
	if (!_data.isDictionary) return;
	[Global openCall:_data[@"mobile"]];
}

- (BOOL)OutletStartLoadUrl:(NSString *)url html:(NSString *)html{
	if ([url hasPrefix:@"yidian-app://goods-qrcode"]) { // yidian-app://goods-qrcode?id=xxx
		NSDictionary *params = [url params];
		NSString *reseller = @"";
		if (_person.isDictionary && [_person[@"shop"] isset]) reseller = _person[@"shop"][@"id"];
		NSString *url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@&reseller=%@", API_URL, params[@"id"], reseller);
		[self showQrcode:url];
		return NO;
	}
	return YES;
}

- (void)showQrcode:(NSString*)url{
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 0)];
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 5;
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 45)];
	label.text = @"商品二维码";
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:14];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((view.width-170)/2, label.bottom, 170, 170)];
	img.image = [QRCodeGenerator createQRCode:url size:img.width];
	[img addLongPressGestureRecognizerWithTarget:self action:@selector(saveQrcode:)];
	[view addSubview:img];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, img.bottom, view.width, 48)];
	label.text = @"（长按二维码可下载到本地）";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:12];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake((view.width-150)/2, label.bottom, 150, 37);
	btn.titleLabel.font = [UIFont systemFontOfSize:14];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"关闭" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3;
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self dismissAlertView:DYAlertViewDown];
	}];
	[view addSubview:btn];
	
	view.height = btn.bottom + 20;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger tag = 785623753;
			[[view viewWithTag:tag] removeFromSuperview];
			UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:view.bounds];
			toolbar.barStyle = UIBarStyleDefault;
			toolbar.tag = tag;
			[view insertSubview:toolbar atIndex:0];
		});
	});
	
	[self presentAlertView:view animation:DYAlertViewDown];
}

- (void)saveQrcode:(UIGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateBegan) {
		UIImageView *qrcode = (UIImageView*)sender.view;
		UIImageWriteToSavedPhotosAlbum(qrcode.image, nil, nil, nil);
		[ProgressHUD showSuccess:@"成功保存"];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
