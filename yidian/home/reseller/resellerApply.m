//
//  resellerApply.m
//  yidian
//
//  Created by ajsong on 16/1/13.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "resellerApply.h"
#import "scaner.h"

@interface resellerApply ()<GlobalDelegate,AJPickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	SpecialTextField *_invite_code;
	SpecialTextField *_mobile;
	NSString *_reseller_type;
	SpecialTextView *_reason;
	NSString *_id_pic;
	
	AJPickerView *_pickerView;
	NSArray *_types;
	UILabel *_label;
	UIImageView *_image;
}
@end

@implementation resellerApply

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"渠道商申请";
	self.view.backgroundColor = BACKCOLOR;
	
	_types = @[@"个人", @"企业"];
	_pickerView = [[AJPickerView alloc]init];
	_pickerView.delegate = self;
	_pickerView.data = _types;
	
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:scroll];
	
	UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-82)/2, 22, 82, 82)];
	avatar.image = IMG(@"avatar");
	avatar.url = _data[@"shop_avatar"];
	avatar.layer.masksToBounds = YES;
	avatar.layer.cornerRadius = 41;
	[scroll addSubview:avatar];
	
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, avatar.bottom, SCREEN_WIDTH, 30)];
	name.text = _data[@"shop_name"];
	name.textColor = [UIColor blackColor];
	name.textAlignment = NSTextAlignmentCenter;
	name.font = [UIFont systemFontOfSize:16];
	name.backgroundColor = [UIColor clearColor];
	[scroll addSubview:name];
	
	UIFont *font = [UIFont systemFontOfSize:14];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, name.bottom+10, SCREEN_WIDTH-15*2, 44)];
	label.text = STRINGFORMAT(@"申请成为%@的渠道商", _data[@"shop_name"]);
	label.textColor = COLOR777;
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[scroll addSubview:label];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"邀请码";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	img.image = IMG(@"d-qrcode");
	[view addSubview:img];
	[img click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		scaner *e = [[scaner alloc]init];
		e.globalDelegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	_invite_code = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-44, view.height)];
	_invite_code.placeholder = @"请输入或扫描邀请码";
	_invite_code.textColor = [UIColor blackColor];
	_invite_code.font = font;
	_invite_code.backgroundColor = [UIColor clearColor];
	[view addSubview:_invite_code];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"联系电话";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_mobile = [[SpecialTextField alloc]initWithFrame:_invite_code.frame];
	_mobile.text = PERSON[@"mobile"];
	_mobile.placeholder = @"请输入联系电话";
	_mobile.textColor = [UIColor blackColor];
	_mobile.font = font;
	_mobile.backgroundColor = [UIColor clearColor];
	_mobile.keyboardType = UIKeyboardTypePhonePad;
	[view addSubview:_mobile];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"类型";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_label = [[UILabel alloc]initWithFrame:_invite_code.frame];
	_label.text = @"请选择类型";
	_label.textColor = COLOR_PLACEHOLDER;
	_label.font = font;
	_label.backgroundColor = [UIColor clearColor];
	[view addSubview:_label];
	[_label click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		[_pickerView show];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 0)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"申请理由";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_reason = [[SpecialTextView alloc]initWithFrame:CGRectMake(label.right, 13, view.width-label.right-10, 70)];
	_reason.placeholder = @"请输入理由";
	_reason.textColor = [UIColor blackColor];
	_reason.font = font;
	_reason.backgroundColor = [UIColor clearColor];
	[view addSubview:_reason];
	view.height = _reason.bottom + 14;
	[view addGeWithType:GeLineTypeBottom];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"上传证件";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	img = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	img.image = IMG(@"push");
	[view addSubview:img];
	_image = [[UIImageView alloc]initWithFrame:CGRectMake(label.right, (view.height-28)/2, 28, 28)];
	_image.clipsToBounds = YES;
	_image.contentMode = UIViewContentModeScaleAspectFill;
	_image.hidden = YES;
	[view addSubview:_image];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectImage];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, view.width, 60)];
	[scroll addSubview:view];
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, view.width-10*2, 40)];
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = COLORRGB(@"ff9f2c");
	[btn setTitle:@"提交申请" forState:UIControlStateNormal];
	[btn setTitleColor:WHITE forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[view addSubview:btn];
	
	scroll.contentSize = CGSizeMake(scroll.width, view.bottom);
}

- (void)GlobalExecuteWithCaller:(UIViewController*)caller data:(NSDictionary*)data{
	_invite_code.text = data[@"code"];
}

- (void)AJPickerView:(AJPickerView *)pickerView didSubmitRow:(NSInteger)row inComponent:(NSInteger)component{
	_label.text = _types[row];
	_label.textColor = BLACK;
	_reseller_type = _types[row];
}

#pragma mark - 选择图片
- (void)selectImage{
	UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self
											 cancelButtonTitle:@"取消"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"从相册选择", @"拍照", nil];
	/*
	 //动态添加按钮,先把init里面所有按钮设为nil
	 [sheet addButtonWithTitle:@"选项一"];
	 //同时添加一个取消按钮
	 [sheet addButtonWithTitle:@"取消"];
	 //将取消按钮的index设置成刚添加的那个按钮,这样在delegate中就可以知道是那个按钮
	 sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
	 */
	[sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if (buttonIndex==0) {
		[self pickImageFromAlbum];
	} else if (buttonIndex==1) {
		[self pickImageFromCamera];
	} else {
		return;
	}
}

#pragma mark - 从用户相册获取活动图片
- (void)pickImageFromAlbum{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imagePicker.allowsEditing = YES;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 从摄像头获取活动图片
- (void)pickImageFromCamera{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imagePicker.allowsEditing = YES;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 获取图片交互
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //UIImagePickerControllerEditedImage
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
		//UIImage *OriginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		//UIImageWriteToSavedPhotosAlbum(OriginalImage, nil, nil, nil); //保存到相册
	}
	image = [image fitToSize:CGSizeMake(800, 800)];
	//[Global saveImageToTmp:image withName:@"image.png"];
	[self dismissViewControllerAnimated:YES completion:nil];
	[self uploadImage:image];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage*)image{
	[ProgressHUD show:nil];
	[image.imageQualityMiddle UploadToUpyun:@"uploadfiles/apply" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
		[ProgressHUD dismiss];
		NSString *url = STRINGFORMAT(@"%@%@", UPYUN_IMGURL, json[@"url"]);
		_id_pic = url;
		_image.image = IMG(@"nopic");
		_image.url = url;
		_image.hidden = NO;
	}];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	[self backgroundTap];
	if (!_mobile.text.length || !_reseller_type.length || !_reason.text.length || !_id_pic.length) {
		[ProgressHUD showError:@"除邀请码外其他项都必须填写"];
		return;
	}
	[ProgressHUD show:@"资料正在提交，请耐心等待"];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_data[@"id"] forKey:@"shop_id"];
	[postData setValue:_invite_code.text forKey:@"invite_code"];
	[postData setValue:_mobile.text forKey:@"mobile"];
	[postData setValue:_reseller_type forKey:@"reseller_type"];
	[postData setValue:_reason.text forKey:@"reason"];
	[postData setValue:_id_pic forKey:@"id_pic"];
	[Common postApiWithParams:@{@"app":@"eshop", @"act":@"reseller_apply"} data:postData feedback:@"提交成功，请耐心等待厂家审核" success:^(NSMutableDictionary *json) {
		[self.navigationController popViewControllerAnimated:YES];
	} fail:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
