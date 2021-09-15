//
//  more.m
//  xytao
//
//  Created by ajsong on 15/5/26.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "Global.h"
#import "more.h"
#import "feedback.h"

@interface more ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation more

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"更多";
	self.view.backgroundColor = BACKCOLOR;
	
	UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, -1, SCREEN_WIDTH, self.height) style:UITableViewStyleGrouped];
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
	return ([PERSON isDictionary] && [PERSON[@"name"] isEqualToString:@"ajsong"]) ? 5 : 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = WHITE;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	cell.imageView.image = IMGFORMAT(@"mo-ico%ld", (long)row+1);
	cell.textLabel.font = FONT(14);
	switch (row) {
		case 0:{
			cell.textLabel.text = @"意见反馈";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case 1:{
			cell.textLabel.text = @"帮助中心";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case 2:{
			cell.textLabel.text = @"关于我们";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case 3:{
			cell.textLabel.text = @"清除缓存";
			NSInteger byte = [[TMCache sharedCache] diskByteCount];
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, cell.frame.size.height)];
			label.text = [Global formatSize:byte unit:nil];
			label.textColor = COLORRGB(@"999");
			label.textAlignment = NSTextAlignmentRight;
			label.font = [UIFont systemFontOfSize:13];
			label.backgroundColor = [UIColor clearColor];
			label.tag = 1000;
			cell.accessoryView = label;
			break;
		}
		case 4:{
			cell.textLabel.text = @"查看TMP";
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
		case 0:{
			feedback *e = [[feedback alloc]init];
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 1:{
			outlet *e = [[outlet alloc]init];
			e.title = @"帮助中心";
			e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=2", API_URL);
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 2:{
			outlet *e = [[outlet alloc]init];
			e.title = @"关于我们";
			e.url = STRINGFORMAT(@"%@/wap.php?app=article&act=detail&id=1", API_URL);
			[self.navigationController pushViewController:e animated:YES];
			break;
		}
		case 3:{
			[[TMCache sharedCache] removeAllObjects];
			[ProgressHUD showSuccess:@"清除完毕"];
			UILabel *label = (UILabel*)[tableView viewWithTag:1000];
			NSInteger byte = [[TMCache sharedCache] diskByteCount];
			label.text = [Global formatSize:byte unit:nil];
			break;
		}
		case 4:{
			[Global touchIDWithReason:@"该操作需要指纹认证" passwordTitle:@"输入密码" success:^{
				GFileList *e = [[GFileList alloc]initWithFolderPath:@"tmp"];
				[self.navigationController pushViewController:e animated:YES];
			} fail:nil nosupport:^{
				GFileList *e = [[GFileList alloc]initWithFolderPath:@"tmp"];
				[self.navigationController pushViewController:e animated:YES];
			}];
			break;
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

@end
