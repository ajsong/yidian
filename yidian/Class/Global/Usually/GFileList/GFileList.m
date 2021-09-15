//
//  GFileList.m
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "GFileList.h"
#import "GFileContent.h"

@interface GFileList ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	NSString *_path;
	NSMutableArray *_images;
}
@end

@implementation GFileList

- (id)initWithFolderPath:(NSString*)folderPath{
	self = [super init];
	if (self) {
		_folderPath = folderPath;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"列表";
	self.view.backgroundColor = BACKCOLOR;
	
	_ms = [[NSMutableArray alloc]init];
	_images = [[NSMutableArray alloc]init];
	if (!_folderPath) _folderPath = @"tmp";
	
	NSMutableArray *ms = [[NSMutableArray alloc]init];
	NSArray *pathArr = @[@"document", @"tmp", @"caches"];
	NSInteger index = [pathArr indexOfObject:_folderPath];
	switch (index) {
		case 0:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromDocument]];
			_path = [Global getDocument];
			break;
		}
		case 1:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromTmp]];
			_path = [Global getTmp];
			break;
		}
		case 2:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromCaches]];
			_path = [Global getCaches];
			break;
		}
		default:{
			ms = [NSMutableArray arrayWithArray:[Global getFileList:_folderPath]];
			_path = _folderPath;
			break;
		}
	}
	NSMutableArray *folder = [[NSMutableArray alloc]init];
	NSMutableArray *file = [[NSMutableArray alloc]init];
	for (int row=0; row<ms.count; row++) {
		NSString *path = [_path stringByAppendingPathComponent:ms[row]];
		if ([Global folderExist:path]) {
			[folder addObject:ms[row]];
		} else {
			[file addObject:ms[row]];
		}
	}
	for (int i=0; i<folder.count; i++) {
		[_ms addObject:folder[i]];
	}
	for (int i=0; i<file.count; i++) {
		[_ms addObject:file[i]];
	}
	//NSLog(@"%@", _ms);
	
	UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height) style:UITableViewStyleGrouped];
	tableView.estimatedSectionHeaderHeight = 0;
	tableView.estimatedSectionFooterHeight = 0;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.dataSource = self;
	tableView.delegate = self;
	[self.view addSubview:tableView];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return !_ms.isArray ? 1 : _ms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.00001;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	cell.imageView.image = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = [UIFont systemFontOfSize:14.f];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
	cell.detailTextLabel.textColor = COLOR999;
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (!_ms) return cell;
	if (_ms.count<=0) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height)];
		label.text = @"没有任何文件(夹)";
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
	cell.textLabel.text = _ms[row];
	NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
	if ([Global folderExist:path]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[_images addObject:[NSNull null]];
		
	} else {
		NSData *data = [Global getFileData:path];
		if ([data isImage]) {
			UIImage *image = [UIImage imageWithData:data];
			image = [image fitToSize:CGSizeMake(80, 80)];
			cell.imageView.image = image;
			if ([data isGIF]) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						GIFImageView *imageView = [[GIFImageView alloc]initWithFrame:cell.imageView.bounds];
						imageView.image = [GIFImage imageWithData:data];
						[cell.imageView addSubview:imageView];
						cell.imageView.image = nil;
					});
				});
			}
			cell.detailTextLabel.text = [data imageSuffix];
			[_images addObject:cell.imageView];
			
		} else {
			cell.detailTextLabel.text = [path getSuffix];
			[_images addObject:[NSNull null]];
		}
	}
	
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger row = indexPath.row;
	NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
	if ([Global folderExist:path]) {
		GFileList *g = [[GFileList alloc]init];
		g.folderPath = path;
		[self.navigationController pushViewController:g animated:YES];
		
	} else {
		NSData *data = [Global getFileData:path];
		if ([data isImage]) {
			MJPhoto *photo = [[MJPhoto alloc] init];
			photo.srcImageView = _images[row];
			photo.image = [GIFImage imageWithData:data];
			photo.title = _ms[row];
			
			MJPhotoBrowser *browser = [[MJPhotoBrowser alloc]init];
			browser.photos = @[photo];
			browser.showInfo = YES;
			[browser show];
			
		} else {
			GFileContent *e = [[GFileContent alloc]init];
			e.filePath = path;
			[self.navigationController pushViewController:e animated:YES];
		}
	}
}

#pragma mark - TableView Cell Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return NO;
	return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView setEditing:NO animated:YES];
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
		if ([Global folderExist:path]) {
			[Global deleteDir:path killme:YES];
		} else {
			[Global deleteFile:path];
		}
		[_ms removeObjectAtIndex:row];
		if (_ms.count>0) {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView reloadData];
		}
	}];
	//deleteAction.backgroundColor = COLORRGB(@"f5475e");
	
	return @[deleteAction];
}
#pragma mark -

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
