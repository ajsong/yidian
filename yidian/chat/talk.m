//
//  talk.m
//
//  Created by ajsong on 15/6/12.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "talk.h"
#import "shopOutlet.h"
#import "EaseGoodsMessageCell.h"

@interface talk ()<EaseGoodsMessageCellDelegate>{
	NSString *_chatter_name;
	NSString *_chatter_avatar;
}
@end

@implementation talk

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationControllerKK.enableDragBack = NO;
	[[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationControllerKK.enableDragBack = YES;
	[[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)pushReturn{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
	//self.showClearButton = YES;
	[super viewDidLoad];
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	//self.showMoreViewLocationBtn = YES;
	if (_goods.isDictionary) {
		self.moreViewOtherBtnImage = IMGEASE(@"chatBar_colorMore_goods");
		/*
		if (_isKefu) {
			NSString *title = _goods[@"goods_name"];
			NSString *desc = _goods[@"goods_description"];
			NSString *price = _goods[@"goods_price"];
			NSString *image = _goods[@"goods_image"];
			NSString *url = _goods[@"goods_id"];
			NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
			if (title) [dic setObject:title forKey:@"title"];
			if (desc) [dic setObject:desc forKey:@"desc"];
			if (price) [dic setObject:STRINGFORMAT(@"￥%.2f", price.floatValue) forKey:@"price"];
			if (image) [dic setObject:image forKey:@"img_url"];
			if (url) [dic setObject:STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@", API_URL, url) forKey:@"item_url"];
			[self sendTextMessage:@"客服图文混排消息" toKefu:@"162" withExt:@{@"msgtype":@{@"track":dic}}];
		}
		 */
	}
	
	_chatter_name = @"";
	_chatter_avatar = @"";
	
	if (_isPresent) {
		KKNavigationBarItem *item = [self.navigationItem setItemWithImage:IMG(@"return") size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
		[item addTarget:self action:@selector(pushReturn) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[Common getApiWithParams:@{@"app":@"member", @"act":@"get_contact", @"member_id":self.chatter} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isDictionary]) {
			if (json[@"data"][@"name"]) _chatter_name = json[@"data"][@"name"];
			if (json[@"data"][@"avatar"]) _chatter_avatar = json[@"data"][@"avatar"];
		}
	} fail:nil];
}

- (UITableViewCell*)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)messageModel{
	if (messageModel.message.ext.isDictionary && [messageModel.message.ext[@"goods"]isset] && [messageModel.message.ext[@"is_goods"]isset]) {
		NSString *CellIdentifier = @"UITableViewCell";
		EaseGoodsMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[EaseGoodsMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:messageModel delegate:self];
		}
		
		return cell;
	}
	return nil;
}
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController heightForMessageModel:(id<IMessageModel>)messageModel withCellWidth:(CGFloat)cellWidth{
	if (messageModel.message.ext.isDictionary && [messageModel.message.ext[@"goods"]isset] && messageModel.message.ext[@"goods"][@"goods_id"]) {
		return [EaseGoodsMessageCell messageCellHeight];
	}
	return 0;
}
- (void)EaseGoodsMessageCellSelected:(id<IMessageModel>)model{
	shopOutlet *e = [[shopOutlet alloc]init];
	e.url = STRINGFORMAT(@"%@/wap.php?app=goods&act=detail&goods_id=%@", API_URL, model.message.ext[@"goods"][@"goods_id"]);
	[self.navigationController pushViewController:e animated:YES];
}

- (void)moreViewOtherAction{
	if (!_goods.isDictionary) return;
	[self sendTextMessage:_goods[@"goods_name"] withExt:[self sendMessageOfExt:YES]];
}

- (EaseMessageModel*)getNameAndAvatarWithModel:(EaseMessageModel *)model{
	NSDictionary *dict = model.message.ext.compatible;
	//NSLog(@"%@", dict.descriptionASCII);
	if (dict.isDictionary) {
		if ([dict[@"weichat"] isDictionary] && [dict[@"weichat"][@"agent"] isDictionary]) {
			model.nickname = dict[@"weichat"][@"agent"][@"userNickname"];
			model.avatarURLPath = dict[@"weichat"][@"agent"][@"avatar"];
		} else if ([dict[@"name"] isset]) {
			model.nickname = dict[@"name"];
			model.avatarURLPath = dict[@"avatar"];
		}
	}
	if (model.avatarURLPath.length && [[model.avatarURLPath left:2] isEqualToString:@"//"]) {
		model.avatarURLPath = STRINGFORMAT(@"http:%@", model.avatarURLPath);
	}
	return model;
}

- (NSDictionary*)sendMessageOfExt{
	return [self sendMessageOfExt:NO];
}

- (NSDictionary*)sendMessageOfExt:(BOOL)isGoods{
	NSDictionary *person = PERSON;
	NSString *name = ([person[@"shop"] isset] && [person[@"shop"][@"name"] length]) ? person[@"shop"][@"name"] : person[@"name"];
	NSString *avatar = ([person[@"shop"] isset] && [person[@"shop"][@"avatar"] length]) ? person[@"shop"][@"avatar"] : person[@"avatar"];
	if (!name.length) name = @"";
	if (!avatar.length) avatar = @"";
	NSMutableDictionary *ext = [[NSMutableDictionary alloc]init];
	[ext setObject:person[@"id"] forKey:@"member_id"];
	[ext setObject:name forKey:@"name"];
	[ext setObject:avatar forKey:@"avatar"];
	[ext setObject:_chatter_name forKey:@"chatter_name"]; //对方
	[ext setObject:_chatter_avatar forKey:@"chatter_avatar"];
	[ext setObject:(_goods.isDictionary ? _goods : @"") forKey:@"goods"];
	if (isGoods) [ext setObject:@YES forKey:@"is_goods"];
	//以下供客服使用
	if (_isKefu) {
		NSMutableDictionary *weichat = [[NSMutableDictionary alloc]init];
		[weichat setObject:@{@"trueName":name, @"userNickname":name, @"qq":@"", @"email":@""} forKey:@"visitor"];
		//[weichat setObject:@"客服登录的邮箱" forKey:@"agentUsername"]; //在普通聊天时转接给指定的客服
		[ext setObject:weichat forKey:@"weichat"];
	}
	//NSLog(@"%@", ext.descriptionASCII);
	return ext;
}

@end
