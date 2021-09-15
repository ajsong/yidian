//
//  invite.m
//  imei
//
//  Created by ajsong on 15/11/18.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
#import "invite.h"

@interface invite ()

@end

@implementation invite

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的邀请码";
	self.view.backgroundColor = WHITE;
	
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:scroll];
	
	UIFont *font = FONT(13);
	UIFont *fontbold = FONTBOLD(24);
	
	NSString *code = PERSON[@"shop"][@"id"];
	NSString *url = STRINGFORMAT(@"%@/invite.php?reseller=%@", API_URL, code);
	
	UIImageView *qrcode = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-210)/2, 44, 210, 210)];
	//qrcode.backgroundColor = WHITE;
	qrcode.image = [QRCodeGenerator createQRCode:code size:qrcode.width];
	[qrcode addLongPressGestureRecognizerWithTarget:self action:@selector(saveQrcode:)];
	[scroll addSubview:qrcode];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, qrcode.bottom, SCREEN_WIDTH, 40)];
	label.text = @"（长按二维码可下载到本地）";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[scroll addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom+17, SCREEN_WIDTH, 38)];
	label.text = STRINGFORMAT(@"邀请码：%@", code);
	label.textColor = BLACK;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[scroll addSubview:label];
	
	NSString *string = @"邀请别人在申请成为厂家渠道商时扫描或直接填写我的邀请码，这样我就可以轻松赚取佣金。";
	CGSize s = [string autoHeight:font width:SCREEN_WIDTH-50*2];
	label = [[UILabel alloc]initWithFrame:CGRectMake(50, label.bottom+50, SCREEN_WIDTH-50*2, s.height)];
	label.text = string;
	label.textColor = COLOR999;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[scroll addSubview:label];
	
	scroll.contentSize = CGSizeMake(scroll.width, label.bottom+15);
}

- (void)saveQrcode:(UIGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateBegan) {
		UIImageView *qrcode = (UIImageView*)sender.view;
		UIImageWriteToSavedPhotosAlbum(qrcode.image, nil, nil, nil);
		[ProgressHUD showSuccess:@"保存成功"];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
