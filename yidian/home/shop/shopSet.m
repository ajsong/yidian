//
//  shopSet.m
//  yidian
//
//  Created by ajsong on 16/1/4.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "shopSet.h"
#import "shopEdit.h"
#import "GlobalDelegate.h"
#import "shopCommission.h"
#import "shopCode.h"
#import "shopFreeShipping.h"

@interface shopSet ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GlobalDelegate>{
	NSArray *_ms;
	NSArray *_mv;
	UITableView *_table;
	NSInteger _offset;
	//NSMutableArray *_cellHeight;
	UITableViewCell *_cell;
	NSString *_free_shipping_price;
}
@end

@implementation shopSet

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"我的店铺设置";
	self.view.backgroundColor = BACKCOLOR;
	
	_ms = [[NSArray alloc]init];
	_mv = [[NSArray alloc]init];
	
	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	//_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	//_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	//_table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	_table.backgroundColor = [UIColor clearColor];
	_table.dataSource = self;
	_table.delegate = self;
	[self.view addSubview:_table];
	
	[self loadData:_data];
}

#pragma mark - loadData
- (void)loadData:(NSDictionary*)data{
	//NSLog(@"%@", data.descriptionASCII);
	_ms = @[
			@[@"店铺名称", @"店铺简介"],
			@[@"分利模板", @"店铺二维码", @"免邮设置"],
			@[@"退货地址", @"联系地址"],
			@[@"店铺头像", @"店铺封面图片"],
			];
	_free_shipping_price = data[@"free_shipping_price"];
	_mv = @[
			@[data[@"name"], data[@"description"]],
			@[@"", @"", @""],
			@[
				@{@"name":data[@"return_name"], @"mobile":data[@"return_mobile"], @"province":data[@"return_province"], @"city":data[@"return_city"], @"district":data[@"return_district"], @"address":data[@"return_address"]},
				@{@"province":data[@"province"], @"city":data[@"city"], @"district":data[@"district"], @"address":data[@"address"]}
				],
			@[data[@"avatar"], data[@"poster_pic"]],
			];
	
	[_table reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return _ms.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_ms[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 44;
	//NSInteger row = indexPath.row;
	//if (IOS8) return [_cellHeight[row]floatValue];
	//if ([_cellHeight[row]floatValue]==0) [self tableView:tableView cellForRowAtIndexPath:indexPath];
	//return [_cellHeight[row]floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section==0) return 0.00001;
	return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.00001;
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
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.imageView.image = nil;
	cell.textLabel.text = nil;
	cell.textLabel.font = [UIFont systemFontOfSize:14.f];
	cell.detailTextLabel.text = nil;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:13.f];
	cell.detailTextLabel.textColor = COLOR999;
	cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	cell.detailTextLabel.minimumScaleFactor = 0.8;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
	//cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
	
	if (_ms==nil) return cell;
	if (!_ms.count) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height)];
		label.text = @"当前没有任何记录";
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:label];
		return cell;
	}
	if (_ms.count<=row) return cell;
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	cell.backgroundColor = [UIColor whiteColor];
	if (!(section==0 && row==0)) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.imageView.image = IMGFORMAT(@"s-ico%ld%ld", (long)section, (long)row);
	cell.textLabel.text = _ms[section][row];
	switch (section) {
		case 2:{
			cell.detailTextLabel.text = STRINGFORMAT(@"%@%@", [AreaPickerView comboWithProvince:_mv[section][row][@"province"] city:_mv[section][row][@"city"] district:_mv[section][row][@"district"]], _mv[section][row][@"address"]);
			break;
		}
		case 3:{
			UIImageView *img = [[UIImageView alloc]initWithFrame:!row ? CGRectMake(0, 0, 32, 32) : CGRectMake(0, 0, 44, 32)];
			img.url = _mv[section][row];
			if (!row) {
				img.layer.masksToBounds = YES;
				img.layer.cornerRadius = img.height/2;
			}
			cell.accessoryView = img;
			break;
		}
		default:{
			cell.detailTextLabel.text = _mv[section][row];
			break;
		}
	}
	
	//[_cellHeight replaceObjectAtIndex:row withObject:@(view.bottom)];
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	_cell = [tableView cellForRowAtIndexPath:indexPath];
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	switch (section) {
		case 0:{
			switch (row) {
				case 0:{
//					shopEdit *e = [[shopEdit alloc]init];
//					e.title = _ms[section][row];
//					e.delegate = self;
//					e.type = ShopEditTypeTextField;
//					e.data = @{
//							   @"field":@"name",
//							   @"value":_mv[section][row],
//							   @"placeholder":_ms[section][row]
//							   };
//					[self.navigationController pushViewController:e animated:YES];
					break;
				}
				case 1:{
					shopEdit *e = [[shopEdit alloc]init];
					e.title = _ms[section][row];
					e.delegate = self;
					e.type = ShopEditTypeTextView;
					e.data = @{
							   @"field":@"description",
							   @"value":_mv[section][row],
							   @"placeholder":_ms[section][row]
							   };
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
			}
			break;
		}
		case 1:{
			switch (row) {
				case 0:{
					shopCommission *e = [[shopCommission alloc]init];
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
				case 1:{
					shopCode *e = [[shopCode alloc]init];
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
				case 2:{
					shopFreeShipping *e = [[shopFreeShipping alloc]init];
					e.delegate = self;
					e.price = _free_shipping_price;
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
			}
			break;
		}
		case 2:{
			switch (row) {
				case 0:{
					shopEdit *e = [[shopEdit alloc]init];
					e.title = _ms[section][row];
					e.delegate = self;
					e.type = ShopEditTypeRefundAddress;
					e.data = @{
							   @"name":@"return_name",
							   @"nameValue":_mv[section][row][@"name"],
							   @"mobile":@"return_mobile",
							   @"mobileValue":_mv[section][row][@"mobile"],
							   @"province":@"return_province",
							   @"provinceValue":_mv[section][row][@"province"],
							   @"city":@"return_city",
							   @"cityValue":_mv[section][row][@"city"],
							   @"district":@"return_district",
							   @"districtValue":_mv[section][row][@"district"],
							   @"field":@"return_address",
							   @"value":_mv[section][row][@"address"],
							   @"placeholder":_ms[section][row]
							   };
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
				case 1:{
					shopEdit *e = [[shopEdit alloc]init];
					e.title = _ms[section][row];
					e.delegate = self;
					e.type = ShopEditTypeAddress;
					e.data = @{
							   @"field":@"address",
							   @"value":_mv[section][row][@"address"],
							   @"province":@"province",
							   @"provinceValue":_mv[section][row][@"province"],
							   @"city":@"city",
							   @"cityValue":_mv[section][row][@"city"],
							   @"district":@"district",
							   @"districtValue":_mv[section][row][@"district"],
							   @"placeholder":_ms[section][row]
							   };
					[self.navigationController pushViewController:e animated:YES];
					break;
				}
			}
			break;
		}
		case 3:{
			switch (row) {
				case 0:{
					[self selectImage];
					break;
				}
				case 1:{
					[self selectImage];
					break;
				}
			}
			break;
		}
	}
}
#pragma mark -

- (void)GlobalExecuteWithCaller:(UIViewController*)caller data:(NSDictionary*)data{
	NSIndexPath *indexPath = [_table indexPathForCell:_cell];
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section==1 && row==2) {
		_free_shipping_price = data[@"value"];
		return;
	}
	switch (section) {
		case 2:{
			_cell.detailTextLabel.text = STRINGFORMAT(@"%@%@", [AreaPickerView comboWithProvince:data[@"province"] city:data[@"city"] district:data[@"district"]], data[@"value"]);
			NSMutableArray *mv = [NSMutableArray arrayWithArray:_mv];
			NSMutableArray *m = [NSMutableArray arrayWithArray:mv[section]];
			if (row==0) {
				[m replaceObjectAtIndex:row withObject:@{@"name":data[@"name"], @"mobile":data[@"mobile"], @"province":data[@"province"], @"city":data[@"city"], @"district":data[@"district"], @"address":data[@"value"]}];
			} else {
				[m replaceObjectAtIndex:row withObject:@{@"province":data[@"province"], @"city":data[@"city"], @"district":data[@"district"], @"address":data[@"value"]}];
			}
			[mv replaceObjectAtIndex:section withObject:m];
			_mv = [NSArray arrayWithArray:mv];
			break;
		}
		default:{
			_cell.detailTextLabel.text = data[@"value"];
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
	
	[image.imageQualityMiddle UploadToUpyun:@"uploadfiles/shop/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
		NSIndexPath *indexPath = [_table indexPathForCell:_cell];
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		NSString *url = STRINGFORMAT(@"%@%@", UPYUN_IMGURL, json[@"url"]);
		NSMutableDictionary *postData = [NSMutableDictionary dictionary];
		if (!row) {
			[postData setObject:url forKey:@"avatar"];
		} else {
			[postData setObject:url forKey:@"poster_pic"];
		}
		[Common postApiWithParams:@{@"app":@"eshop", @"act":@"edit_info"} data:postData success:^(NSMutableDictionary *json) {
			if (url.length) {
				UIImageView *img = [[UIImageView alloc]initWithFrame:!row ? CGRectMake(0, 0, 32, 32) : CGRectMake(0, 0, 44, 32)];
				img.url = url;
				if (!row) {
					img.layer.masksToBounds = YES;
					img.layer.cornerRadius = img.height/2;
				}
				_cell.accessoryView = img;
			}
		} fail:nil];
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
