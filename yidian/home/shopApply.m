//
//  shopApply.m
//  yidian
//
//  Created by ajsong on 15/12/24.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopApply.h"
#import "shopApplyComplete.h"

@interface shopApply ()<AreaPickerViewDelegate,AJPickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	NSMutableArray *_ms;
	UIScrollView *_scroll;
	AreaPickerView *_areaPickerView;
	AJPickerView *_pickerView;
	UIImageView *_selectImage;
	
	UIImage *_business_license_pic;
	UIImage *_idcard_pic1;
	UIImage *_idcard_pic2;
	UIImage *_other_pic;
	UITextField *_name;
	UITextField *_legal_person_mobile;
	UITextField *_contacter;
	SpecialTextField *_mobile;
	NSString *_province;
	NSString *_city;
	NSString *_district;
	UITextField *_address;
	NSString *_type_id;
	
	UILabel *_shiqu;
	UILabel *_zhuying;
}
@end

@implementation shopApply

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"申请开铺";
	self.view.backgroundColor = BACKCOLOR;
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	_areaPickerView = [[AreaPickerView alloc]init];
	_areaPickerView.delegate = self;
	
	_pickerView = [[AJPickerView alloc]init];
	_pickerView.delegate = self;
	
	[ProgressHUD show:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	NSMutableArray *data = [[NSMutableArray alloc]init];
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"types"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json);
		if ([json[@"data"] isArray]) {
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				NSDictionary *element = [NSDictionary dictionaryWithDictionary:list[i]];
				[_ms addObject:element];
				[data addObject:element[@"name"]];
			}
			_pickerView.data = data;
			[self loadViews];
		}
		//NSLog(@"%@", _ms);
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	[_scroll removeAllSubviews];
	if (!_ms.isArray) return;
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	NSArray *arr = @[@"营业执照", @"身份证正面", @"身份证背面", @"其他"];
	CGFloat x = 5;
	CGFloat w = (SCREEN_WIDTH-x*(arr.count+1)) / arr.count;
	for (int i=0; i<arr.count; i++) {
		UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(x, 0, w, w+35)];
		UIImageView *btn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, w, w)];
		btn.image = [UIImage imageNamed:@"h-apply-add"];
		btn.clipsToBounds = YES;
		btn.contentMode = UIViewContentModeScaleAspectFill;
		[btn click:^(UIView *view, UIGestureRecognizer *sender) {
			_selectImage = (UIImageView*)view;
			[self selectImage];
		}];
		btn.tag = 100 + i;
		[subview addSubview:btn];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, btn.bottom, btn.width, 35)];
		label.text = arr[i];
		label.textColor = COLOR666;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(13);
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		[subviews addObject:subview];
	}
	[view autoLayoutSubviews:subviews marginPT:(130-(w+35))/2 marginPL:x marginPR:0];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, view.lastSubview.bottom+10, view.width-10*2, 0)];
	label.text = @"若商城中含其它需要提供的资质时，则需要按要求提供相应的资质证明文件。例如，商城中含食品类，则需要补充《食品流通许可证》或《食品卫生许可证》。";
	label.textColor = COLOR999;
	label.font = FONT(10);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label autoHeight];
	
	view.height = label.bottom + 10;
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+10, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeTop];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 90, view.height)];
	label.text = @"店铺名称";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_name = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
	_name.placeholder = @"请输入店铺名称";
	_name.textColor = [UIColor blackColor];
	_name.font = FONT(14);
	_name.backgroundColor = [UIColor clearColor];
	[view addSubview:_name];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"法人电话";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_legal_person_mobile = [[UITextField alloc]initWithFrame:_name.frame];
	_legal_person_mobile.placeholder = @"请输入法人电话";
	_legal_person_mobile.textColor = [UIColor blackColor];
	_legal_person_mobile.font = FONT(14);
	_legal_person_mobile.backgroundColor = [UIColor clearColor];
	_legal_person_mobile.keyboardType = UIKeyboardTypePhonePad;
	[view addSubview:_legal_person_mobile];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"联系人姓名";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_contacter = [[UITextField alloc]initWithFrame:_name.frame];
	_contacter.placeholder = @"请输入姓名";
	_contacter.textColor = [UIColor blackColor];
	_contacter.font = FONT(14);
	_contacter.backgroundColor = [UIColor clearColor];
	[view addSubview:_contacter];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"联系人电话";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_mobile = [[SpecialTextField alloc]initWithFrame:_name.frame];
	_mobile.placeholder = @"请输入联系电话";
	_mobile.textColor = [UIColor blackColor];
	_mobile.font = FONT(14);
	_mobile.backgroundColor = [UIColor clearColor];
	_mobile.keyboardType = UIKeyboardTypePhonePad;
	[view addSubview:_mobile];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"市区";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_shiqu = [[UILabel alloc]initWithFrame:_name.frame];
	_shiqu.text = @"请选择市区";
	_shiqu.textColor = COLORRGB(@"c7c7c7");
	_shiqu.font = FONT(14);
	_shiqu.backgroundColor = [UIColor clearColor];
	[_shiqu click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		[_areaPickerView show];
	}];
	[view addSubview:_shiqu];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"地址";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_address = [[UITextField alloc]initWithFrame:_name.frame];
	_address.placeholder = @"请输入地址";
	_address.textColor = [UIColor blackColor];
	_address.font = FONT(14);
	_address.backgroundColor = [UIColor clearColor];
	[view addSubview:_address];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = WHITE;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"主营类目";
	label.textColor = [UIColor blackColor];
	label.font = FONT(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_zhuying = [[UILabel alloc]initWithFrame:_name.frame];
	_zhuying.text = @"请选择主营类目";
	_zhuying.textColor = COLORRGB(@"c7c7c7");
	_zhuying.font = FONT(14);
	_zhuying.backgroundColor = [UIColor clearColor];
	[_zhuying click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		[_pickerView show];
	}];
	[view addSubview:_zhuying];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(10, view.bottom+10, _scroll.width-10*2, 40);
	btn.titleLabel.font = [UIFont systemFontOfSize:15];
	btn.backgroundColor = MAINSUBCOLOR;
	[btn setTitle:@"提交申请" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
		[self pass];
	}];
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 4;
	[_scroll addSubview:btn];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+10);
}

- (void)areaPickerView:(UIPickerView *)picker didSubmitWithProvince:(NSString *)province city:(NSString *)city district:(NSString *)district combo:(NSString *)combo{
	_shiqu.text = combo;
	_shiqu.textColor = BLACK;
	_province = province;
	_city = city;
	_district = district;
}

- (void)AJPickerView:(AJPickerView *)pickerView didSubmitRow:(NSInteger)row inComponent:(NSInteger)component{
	_zhuying.text = _ms[row][@"name"];
	_zhuying.textColor = BLACK;
	_type_id = STRING(_ms[row][@"id"]);
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

#pragma mark - 选择图片
- (void)selectImage{
	[self backgroundTap];
	UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"选择证件" delegate:self
											 cancelButtonTitle:@"取消"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"从相册选择", @"拍照", nil];
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
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
		//UIImage *OriginalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		//UIImageWriteToSavedPhotosAlbum(OriginalImage, nil, nil, nil); //保存到相册
	}
	image = [image fitToSize:CGSizeMake(800, 800)];
	//[Global saveImageToTmp:image withName:@"image.png"];
	[self uploadImage:image];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage*)image{
	if (!_selectImage) return;
	_selectImage.image = image;
	NSInteger index = _selectImage.tag - 100;
	switch (index) {
		case 0:{
			_business_license_pic = image;
			break;
		}
		case 1:{
			_idcard_pic1 = image;
			break;
		}
		case 2:{
			_idcard_pic2 = image;
			break;
		}
		case 3:{
			_other_pic = image;
			break;
		}
	}
	_selectImage = nil;
}

- (void)pass{
	[self backgroundTap];
	if (!_business_license_pic || !_idcard_pic1 || !_idcard_pic2) {
		[ProgressHUD showError:@"除其他外所有证件必须上传"];
		return;
	}
	if (!_name.text.length || !_legal_person_mobile.text.length || !_contacter.text.length || !_mobile.text.length || !_province.length || !_city.length || !_district.length || !_address.text.length || !_type_id.length) {
		[ProgressHUD showError:@"所有项必须填写"];
		return;
	}
	if (![_legal_person_mobile.text isMobile]) {
		[ProgressHUD showError:@"请正确填写法人电话"];
		return;
	}
	if (![_mobile.text isMobile]) {
		[ProgressHUD showError:@"请正确填写联系人电话"];
		return;
	}
	
	[ProgressHUD show:nil];
	NSMutableArray *images = [[NSMutableArray alloc]initWithObjects:
							  _business_license_pic.imageQualityMiddle,
							  _idcard_pic1.imageQualityMiddle,
							  _idcard_pic2.imageQualityMiddle,
							  nil];
	if (_other_pic) [images addObject:_other_pic.imageQualityMiddle];
	[images UploadToUpyun:@"uploadfiles/shop" each:nil completion:^(NSArray *images, NSArray *imageUrls, NSArray *imageNames) {
		NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
		[postData setValue:imageUrls[0] forKey:@"business_license_pic"];
		[postData setValue:imageUrls[1] forKey:@"idcard_pic1"];
		[postData setValue:imageUrls[2] forKey:@"idcard_pic2"];
		if (imageUrls.count>3) [postData setValue:imageUrls[3] forKey:@"other_pic"];
		[postData setValue:_name.text forKey:@"name"];
		[postData setValue:_legal_person_mobile.text forKey:@"legal_person_mobile"];
		[postData setValue:_contacter.text forKey:@"contacter"];
		[postData setValue:_mobile.text forKey:@"mobile"];
		[postData setValue:_province forKey:@"province"];
		[postData setValue:_city forKey:@"city"];
		[postData setValue:_district forKey:@"district"];
		[postData setValue:_address.text forKey:@"address"];
		[postData setValue:_type_id forKey:@"type_id"];
		[Common postApiWithParams:@{@"app":@"eshop", @"act":@"apply"} data:postData feedback:nil success:^(NSMutableDictionary *json) {
			//NSLog(@"%@", json.descriptionASCII);
			NSMutableDictionary *person = PERSON;
			[person setObject:@"3" forKey:@"member_type"];
			[person setObject:json[@"data"] forKey:@"shop"];
			[@"person" setUserDefaultsWithData:person];
			shopApplyComplete *e = [[shopApplyComplete alloc]init];
			[self.navigationController pushViewController:e animated:YES];
		} fail:nil];
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
