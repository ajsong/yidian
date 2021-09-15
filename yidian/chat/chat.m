//
//  chat.m
//
//  Created by ajsong on 15/6/3.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "chat.h"
#import "talk.h"

@interface chat ()<KKNavigationControllerDelegate>

@end

@implementation chat

- (void)navigationPushViewController:(KKNavigationController *)navigationController{
	[self.tabBarControllerKK setTabBarHidden:YES animated:YES];
}

- (void)navigationDidAppearFromPopAction:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[self.tabBarControllerKK setTabBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	NSInteger count = 0;
	for (EaseConversationModel *model in self.dataArray) {
		count += [model.conversation unreadMessagesCount];
	}
	[self setBadgeValue:count];
}

- (void)viewDidLoad {
	self.tableViewContentInset = UIEdgeInsetsMake(0, 0, self.tabBarControllerKK.tabBarHeight, 0);
	[super viewDidLoad];
	self.title = @"聊天";
	self.view.backgroundColor = BACKCOLOR;
	[self.navigationController setBackgroundColor:NAVBGCOLOR textColor:NAVTEXTCOLOR];
}

- (void)setBadgeValue:(NSInteger)count{
	KKTabBarItem *tabBarItem = self.tabBarItemKK;
	if (count) {
		tabBarItem.badgeValue = STRINGFORMAT(@"%ld", (long)count);
	} else {
		tabBarItem.badgeValue = @"";
	}
}

- (EaseConversationModel*)getNameAndAvatarWithModel:(EaseConversationModel *)model{
	if (model.conversation.latestMessageFromOthers) {
		NSDictionary *dict = model.conversation.latestMessageFromOthers.ext.compatible;
		if (dict.isDictionary) {
			if ([dict[@"weichat"] isDictionary] && [dict[@"weichat"][@"agent"] isDictionary]) {
				model.title = dict[@"weichat"][@"agent"][@"userNickname"];
				model.avatarURLPath = dict[@"weichat"][@"agent"][@"avatar"];
			} else if ([dict[@"name"] isset]) {
				model.title = dict[@"name"];
				model.avatarURLPath = dict[@"avatar"];
			}
		}
	} else {
		NSDictionary *dict = model.conversation.latestMessage.ext.compatible;
		if (dict.isDictionary) {
			if ([dict[@"weichat"] isDictionary] && [dict[@"weichat"][@"agent"] isDictionary]) {
				model.title = dict[@"weichat"][@"agent"][@"userNickname"];
				model.avatarURLPath = dict[@"weichat"][@"agent"][@"avatar"];
			} else if ([dict[@"chatter_name"] isset]) {
				model.title = dict[@"chatter_name"];
				model.avatarURLPath = dict[@"chatter_avatar"];
			}
		}
	}
	if (model.avatarURLPath.length && [[model.avatarURLPath left:2] isEqualToString:@"//"]) {
		model.avatarURLPath = STRINGFORMAT(@"http:%@", model.avatarURLPath);
	}
	return model;
}

- (UIView*)conversationListViewControllerNoRecordWithTableView:(UITableView *)tableView{
	UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
	pic.image = IMG(@"c-norecord");
	return pic;
}

@end
