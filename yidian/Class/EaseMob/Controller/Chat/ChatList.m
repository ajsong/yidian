//
//  ChatList.m
//
//  Created by ajsong on 15/6/3.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseConversationModel.h"
#import "EaseEmotionManager.h"
#import "NSDate+Category.h"
#import "ChatList.h"
#import "ChatView.h"

@interface ChatList ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource>

@end

@implementation ChatList

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view.
	self.showRefreshHeader = YES;
	self.delegate = self;
	self.dataSource = self;
	
	[self tableViewDidTriggerHeaderRefresh];
	
	self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.height);
	
	[self removeEmptyConversationsFromDB];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refresh];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)removeEmptyConversationsFromDB
{
	NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
	NSMutableArray *needRemoveConversations;
	for (EMConversation *conversation in conversations) {
		if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom)) {
			if (!needRemoveConversations) {
				needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
			}
			
			[needRemoveConversations addObject:conversation];
		}
	}
	
	if (needRemoveConversations && needRemoveConversations.count > 0) {
		[[EMClient sharedClient].chatManager deleteConversations:needRemoveConversations deleteMessages:YES];
	}
}

#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
			didSelectConversationModel:(id<IConversationModel>)conversationModel
{
	if (conversationModel) {
		EMConversation *conversation = conversationModel.conversation;
		if (conversation) {
			id chatController;
			Class chatViewClass = [EaseSDKHelper shareHelper].chatViewClass;
			if (!chatViewClass) {
				chatController = [[ChatView alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
			} else {
				chatController = [(EaseMessageViewController*)[chatViewClass alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
			}
			[chatController setTitle:conversationModel.title];
			[(EaseMessageViewController*)chatController setConversationModel:conversationModel];
			[self.navigationController pushViewController:chatController animated:YES];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
		[self.tableView reloadData];
	}
}

#pragma mark - EaseConversationListViewControllerDataSource

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
									modelForConversation:(EMConversation *)conversation
{
	EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
	if (model.conversation.type == EMConversationTypeChat) {
		model = [self getNameAndAvatarWithModel:model];
	}
	return model;
}

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
	  latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
	NSString *latestMessageTitle = @"";
	EMMessage *lastMessage = [conversationModel.conversation latestMessage];
	if (lastMessage) {
		EMMessageBody *messageBody = lastMessage.body;
		switch (messageBody.type) {
			case EMMessageBodyTypeText:{
				//表情映射
				NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
				latestMessageTitle = didReceiveText;
				if ([lastMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
					latestMessageTitle = @"[动画表情]";
				}
			}
				break;
			case EMMessageBodyTypeImage:{
				latestMessageTitle = @"[图片]";
			}
				break;
			case EMMessageBodyTypeLocation: {
				latestMessageTitle = @"[位置]";
			}
				break;
			case EMMessageBodyTypeVoice:{
				latestMessageTitle = @"[语音]";
			}
				break;
			case EMMessageBodyTypeVideo: {
				latestMessageTitle = @"[视频]";
			}
				break;
			case EMMessageBodyTypeFile: {
				latestMessageTitle = @"[文件]";
			}
				break;
			default:
				break;
		}
	}
	
	return latestMessageTitle;
}

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
	   latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
	NSString *latestMessageTime = @"";
	EMMessage *lastMessage = [conversationModel.conversation latestMessage];
	if (lastMessage) {
		latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
	}
	
	
	return latestMessageTime;
}

#pragma mark - public

- (void)refresh
{
	//[self refreshAndSortView];
	[self tableViewDidTriggerHeaderRefresh];
}

- (void)refreshDataSource
{
	[self tableViewDidTriggerHeaderRefresh];
}

@end
