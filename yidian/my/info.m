//
//  set.m
//  xytao
//
//  Created by ajsong on 15/5/27.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "info.h"
#import "edit.h"
#import "password.h"

@interface info ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	NSMutableDictionary *_person;
	UIImageView *_avatar;
}
@end

@implementation info

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"修改信息";
	self.view.backgroundColor = BACKCOLOR;
	
	_person = PERSON;
	
	UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, -1, SCREEN_WIDTH, self.height+1) style:UITableViewStyleGrouped];
	table.estimatedSectionHeaderHeight = 0;
	table.estimatedSectionFooterHeight = 0;
	table.scrollEnabled = NO;
	table.backgroundColor = [UIColor clearColor];
	table.dataSource = self;
	table.delegate = self;
	[self.view addSubview:table];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!indexPath.row) return 20+80+10+30+20;
	return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	cell.textLabel.font = FONT(14);
	switch (row) {
		case 0:{
			for (UIView *subview in cell.contentView.subviews) {
				[subview removeFromSuperview];
			}
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20+80+10+30+20)];
			[cell.contentView addSubview:view];
			
			_avatar = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2, 20, 80, 80)];
			_avatar.image = IMG(@"avatar");
			_avatar.url = _person[@"avatar"];
			/*
			if ([_person[@"shop"] isset]) {
				_avatar.url = _person[@"shop"][@"avatar"];
			} else {
				_avatar.url = _person[@"avatar"];
			}
			 */
			_avatar.layer.masksToBounds = YES;
			_avatar.layer.cornerRadius = _avatar.height/2;
			[view addSubview:_avatar];
			[_avatar click:^(UIView *view, UIGestureRecognizer *sender) {
				[self selectImage];
			}];
			
			NSString *string = _person[@"name"];
			/*
			if ([_person[@"shop"] isset]) {
				string = _person[@"shop"][@"name"];
			} else {
				string = _person[@"name"];
			}
			 */
			string = STRINGFORMAT(@"用户名 <p>%@</p>", string);
			NSDictionary *style = @{@"body":@[FONT(13), BLACK], @"p":FONTBOLD(16)};
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, _avatar.bottom+10, SCREEN_WIDTH, 30)];
			label.attributedText = [string attributedStyle:style];
			label.textAlignment = NSTextAlignmentCenter;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			break;
		}
		case 1:{
			cell.backgroundColor = WHITE;
			cell.textLabel.text = @"个人资料";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case 2:{
			cell.backgroundColor = WHITE;
			cell.textLabel.text = @"修改密码";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
	}
	
	return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	switch (row) {
		case 1:{
			edit *g = [[edit alloc]init];
			[self.navigationController pushViewController:g animated:YES];
			break;
		}
		case 2:{
			password *g = [[password alloc]init];
			[self.navigationController pushViewController:g animated:YES];
			break;
		}
	}
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
	NSString *uploadPath = @"uploadfiles/avatar";
	NSString *app = @"member";
	NSString *act = @"avatar";
	/*
	if ([_person[@"shop"] isset]) {
		uploadPath = @"uploadfiles/shop/avatar";
		app = @"eshop";
		act = @"edit_info";
	}
	 */
	[image.imageQualityMiddle UploadToUpyun:uploadPath completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
		NSString *url = STRINGFORMAT(@"%@%@", UPYUN_IMGURL, json[@"url"]);
		NSMutableDictionary *postData = [NSMutableDictionary dictionary];
		[postData setObject:url forKey:@"avatar"];
		[Common postApiWithParams:@{@"app":app, @"act":act} data:postData success:^(NSMutableDictionary *json) {
			/*
			if ([_person[@"shop"] isset]) {
				NSMutableDictionary *shop = [NSMutableDictionary dictionaryWithDictionary:_person[@"shop"]];
				[shop setObject:url forKey:@"avatar"];
				[_person setObject:shop forKey:@"shop"];
			} else {
				[_person setObject:url forKey:@"avatar"];
			}
			 */
			[_person setObject:url forKey:@"avatar"];
			[@"person" setUserDefaultsWithData:_person];
			if (url.length) {
				_avatar.url = url;
			}
		} fail:nil];
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
