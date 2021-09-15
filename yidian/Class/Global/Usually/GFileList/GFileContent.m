//
//  GFileContent.m
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "GFileContent.h"

@interface GFileContent ()

@end

@implementation GFileContent

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = WHITE;
	
	NSData *data = [Global getFileData:_filePath];
	if ([data isImage]) {
		self.title = @"图片";
		UIImage *image = [UIImage imageWithData:data];
		image = [image fitToSize:CGSizeMake(SCREEN_WIDTH, self.height)];
		if ([data isGIF]) {
			GIFImageView *imageView = [[GIFImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-image.size.width)/2, (self.height-image.size.height)/2, image.size.width, image.size.height)];
			imageView.image = [GIFImage imageWithData:data];
			[self.view addSubview:imageView];
		} else {
			UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-image.size.width)/2, (self.height-image.size.height)/2, image.size.width, image.size.height)];
			imageView.image = image;
			[self.view addSubview:imageView];
		}
	} else {
		self.title = @"内容";
		UITextView *name = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
		name.text = [Global getFileText:_filePath];
		name.textColor = [UIColor blackColor];
		name.font = [UIFont systemFontOfSize:13.f];
		name.backgroundColor = [UIColor clearColor];
		name.editable = NO;
		[self.view addSubview:name];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
