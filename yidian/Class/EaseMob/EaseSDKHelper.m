/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

//具体说明
//docs.easemob.com/im/300iosclientintegration/40emmsg

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate+EaseMob.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseEmotionManager.h"
#import "EaseConversationModel.h"
#if IS_USE_CALL == 1
#import "EMClient+Call.h"
#import "CallViewController.h"
#endif

@implementation EaseProfileModel
@end

@interface EaseSDKHelper(){
	NSDate *_lastPlaySoundDate;
#if IS_USE_CALL == 1
	CallViewController *_callController;
	NSTimer *_callTimer;
#endif
}
@end

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static EaseSDKHelper *helper = nil;

/**
 *  系统铃声播放完成后的回调
 */
void EMSystemSoundFinishedPlayingCallback2(SystemSoundID sound_id, void* user_data)
{
	AudioServicesDisposeSystemSoundID(sound_id);
}

@implementation EaseSDKHelper

@synthesize isShowingimagePicker = _isShowingimagePicker;

+ (instancetype)shareHelper
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		helper = [[EaseSDKHelper alloc] init];
	});
	
	return helper;
}

+ (NSString*)latestMessageTime:(EMMessage*)message{
	double timeInterval = message.timestamp;
	if (timeInterval>140000000000) timeInterval = timeInterval / 1000;
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"YYYY-MM-dd"];
	NSString *latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
	return latestMessageTime;
}

+ (NSString*)latestMessageDetail:(EMMessage*)message{
	EMMessageBody *messageBody = message.body;
	NSString *messageStr = nil;
	switch (messageBody.type) {
		case EMMessageBodyTypeText:
		{
			//表情映射
			messageStr = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
			if ([message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
				messageStr = @"[动画表情]";
			}
		}
			break;
		case EMMessageBodyTypeImage:
		{
			messageStr = @"[图片]";
			//EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
			//NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
			//NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
			//NSLog(@"大图的secret -- %@"    ,body.secretKey);
			//NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
			//NSLog(@"大图的下载状态 -- %lu",body.downloadStatus);
			// 缩略图sdk会自动下载
			//NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
			//NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
			//NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
			//NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
			//NSLog(@"小图的下载状态 -- %lu",body.thumbnailDownloadStatus);
		}
			break;
		case EMMessageBodyTypeLocation:
		{
			messageStr = @"[位置]";
			//EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
			//NSLog(@"纬度-- %f",body.latitude);
			//NSLog(@"经度-- %f",body.longitude);
			//NSLog(@"地址-- %@",body.address);
		}
			break;
		case EMMessageBodyTypeVoice:
		{
			messageStr = @"[语音]";
			// 音频sdk会自动下载
			//EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
			//NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
			//NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
			//NSLog(@"音频的secret -- %@"        ,body.secretKey);
			//NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
			//NSLog(@"音频文件的下载状态 -- %lu"   ,body.downloadStatus);
			//NSLog(@"音频的时间长度 -- %lu"      ,body.duration);
		}
			break;
		case EMMessageBodyTypeVideo:{
			messageStr = @"[视频]";
			//EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
			//NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
			//NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
			//NSLog(@"视频的secret -- %@"        ,body.secretKey);
			//NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
			//NSLog(@"视频文件的下载状态 -- %lu"   ,body.downloadStatus);
			//NSLog(@"视频的时间长度 -- %lu"      ,body.duration);
			//NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
			// 缩略图sdk会自动下载
			//NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
			//NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
			//NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
			//NSLog(@"缩略图的下载状态 -- %lu"      ,body.thumbnailDownloadStatus);
		}
			break;
		case EMMessageBodyTypeFile: {
			messageStr = @"[文件]";
			//EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
			//NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
			//NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
			//NSLog(@"文件的secret -- %@"        ,body.secretKey);
			//NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
			//NSLog(@"文件文件的下载状态 -- %lu"   ,body.downloadStatus);
		}
			break;
		default:
			break;
	}
	return messageStr;
}

+ (BOOL)isLogin{
	NSString *username = [[EMClient sharedClient] currentUsername];
	return username.length>0;
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success{
	EMError *error = [[EMClient sharedClient] loginWithUsername:username password:password];
	if (!error) {
		//NSLog(@"登录成功");
		//设置自动登录
		[[EMClient sharedClient].options setIsAutoLogin:YES];
		//发送自动登陆状态通知
		[[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
		if (success) success();
	} else {
		NSLog(@"login: %@", error.errorDescription);
		[EaseSDKHelper registerWithUsername:username password:password success:success];
	}
}

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success{
	EMError *error = [[EMClient sharedClient] registerWithUsername:username password:password];
	if (!error) {
		//NSLog(@"注册成功");
		[EaseSDKHelper loginWithUsername:username password:password success:success];
	} else {
		NSLog(@"register: %@", error.errorDescription);
	}
}

+ (void)updateNickname:(NSString *)nickname{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		EMError *error = [[EMClient sharedClient] setApnsNickname:nickname];
		if (!error) {
			//NSLog(@"更新昵称成功");
		} else {
			NSLog(@"update nickname: %@", error.errorDescription);
		}
	});
}

+ (void)logout{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		EMError *error = [[EMClient sharedClient] logout:YES];
		if (!error) {
			//NSLog(@"退出成功");
		} else {
			NSLog(@"logout: %@", error.errorDescription);
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
	});
}

- (void)dealloc{
	[[EMClient sharedClient] removeDelegate:self];
	[[EMClient sharedClient].chatManager removeDelegate:self];
#if IS_USE_CALL == 1
	[[EMClient sharedClient].callManager removeDelegate:self];
#endif
}

- (id)init{
	self = [super init];
	if (self) {
		[self initHelper];
	}
	return self;
}

- (void)initHelper{
	_chatListClass = NSClassFromString(@"ChatList");
	_chatViewClass = NSClassFromString(@"ChatView");
	_lastPlaySoundDate = [NSDate date];
	[[EMClient sharedClient] addDelegate:self delegateQueue:nil];
	[[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
#if IS_USE_CALL == 1
	[[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
#endif
}

#pragma mark - init easemob

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
					appkey:(NSString *)appkey
			  apnsCertName:(NSString *)apnsCertName
{
	//注册AppDelegate默认回调监听
	[self _setupAppDelegateNotifications];
	
	//注册apns
	[self _registerRemoteNotification];
	
	/*
	 EMOptions *options = [EMOptions optionsWithAppkey:appkey];
	 options.apnsCertName = apnsCertName;
	 options.isAutoAcceptGroupInvitation = NO;
	 if ([otherConfig objectForKey:kSDKConfigEnableConsoleLogger]) {
		options.enableConsoleLog = YES;
	 }
	 
	 BOOL sandBox = [otherConfig objectForKey:@"easeSandBox"] && [[otherConfig objectForKey:@"easeSandBox"] boolValue];
	 if (!sandBox) {
		[[EMClient sharedClient] initializeSDKWithOptions:options];
	 }
	 */
}

- (NSString*)currentUsername{
	return [[EMClient sharedClient] currentUsername];
}

- (void)asyncConversationFromDB{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSArray *array = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
		[array enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
			if(conversation.latestMessage == nil){
				[[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:NO];
			}
		}];
	});
}

- (void)asyncPushOptions{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		EMError *error = nil;
		[[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
	});
}

- (void)updatePushOptions{
	EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
	pushOptions.displayStyle = EMPushDisplayStyleMessageSummary;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		EMError *error = [[EMClient sharedClient] updatePushOptionsToServer];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				[[EaseSDKHelper shareHelper] asyncPushOptions];
			} else {
				NSLog(@"Update PushOptions error: %@", error.errorDescription);
			}
		});
	});
}

//当前登录账号在其它设备登录时会接收到该回调
- (void)didLoginFromOtherDevice{
	
}

//当前登录账号已经被从服务器端删除时会收到该回调
- (void)didRemovedFromServer{
	
}

// 播放接收到新消息时的声音
- (SystemSoundID)playNewMessageSound
{
	// 要播放的音频文件地址
	NSURL *bundlePath = [[NSBundle mainBundle] URLForResource:@"EaseUIResource" withExtension:@"bundle"];
	NSURL *audioPath = [[NSBundle bundleWithURL:bundlePath] URLForResource:@"in" withExtension:@"caf"];
	// 创建系统声音，同时返回一个ID
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &soundID);
	// Register the sound completion callback.
	AudioServicesAddSystemSoundCompletion(soundID,
										  NULL, // uses the main run loop
										  NULL, // uses kCFRunLoopDefaultMode
										  EMSystemSoundFinishedPlayingCallback2, // the name of our custom callback function
										  NULL // for user data, but we don't need to do that in this case, so we just pass NULL
										  );
	AudioServicesPlaySystemSound(soundID);
	
	return soundID;
}

// 震动
- (void)playVibration
{
	// Register the sound completion callback.
	AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
										  NULL, // uses the main run loop
										  NULL, // uses kCFRunLoopDefaultMode
										  EMSystemSoundFinishedPlayingCallback2, // the name of our custom callback function
										  NULL // for user data, but we don't need to do that in this case, so we just pass NULL
										  );
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - EMChatManagerDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)didUpdateConversationList:(NSArray *)aConversationList
{
	//更新聊天列表界面
	if (_chatListClass) {
		if ([APPCurrentController isKindOfClass:_chatListClass]) {
			[APPCurrentController performSelector:NSSelectorFromString(@"refresh")];
		}
	}
}

- (void)didReceiveMessages:(NSArray *)aMessages
{
	BOOL isRefreshCons = YES;
	for(EMMessage *message in aMessages){
		BOOL needShowNotification = (message.chatType != EMChatTypeChat) ? [self _needShowNotification:message.conversationId] : YES;
		if (needShowNotification) {
			UIApplicationState state = [[UIApplication sharedApplication] applicationState];
			switch (state) {
				case UIApplicationStateActive:
				case UIApplicationStateInactive:{
					[self playSoundAndVibration];
					AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
					SEL selector = NSSelectorFromString(@"didReceiveMessages:");
					if ([appDelegate respondsToSelector:selector]) {
						[appDelegate performSelector:selector withObject:message];
					}
					break;
				}
				case UIApplicationStateBackground:
					[self showNotificationWithMessage:message];
					break;
				default:
					break;
			}
		}
	}
	
	if (isRefreshCons) {
		//更新聊天列表界面
		if (_chatListClass) {
			if ([APPCurrentController isKindOfClass:_chatListClass]) {
				[APPCurrentController performSelector:NSSelectorFromString(@"refresh")];
			}
		}
	}
}
#pragma clang diagnostic pop

//接收透传消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
	for (EMMessage *message in aCmdMessages) {
		EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
		NSLog(@"收到的action是 -- %@",body.action);
	}
}

- (void)playSoundAndVibration{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_lastPlaySoundDate];
	if (timeInterval < kDefaultPlaySoundInterval) {
		//如果距离上次响铃和震动时间太短, 则跳过响铃
		//NSLog(@"skip ringing & vibration %@, %@", [NSDate date], _lastPlaySoundDate);
		return;
	}
	
	//保存最后一次响铃时间
	_lastPlaySoundDate = [NSDate date];
	
	// 收到消息时，播放音频
	[self playNewMessageSound];
	// 收到消息时，震动
	[self playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
	EMPushOptions *options = [[EMClient sharedClient] pushOptions];
	//发送本地推送
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate date]; //触发通知的时间
	if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
		NSString *messageStr = [EaseSDKHelper latestMessageDetail:message];
		notification.alertBody = [NSString stringWithFormat:@"%@", messageStr];
	} else {
		notification.alertBody = @"你收到一条新消息";
	}
	
#if TARGET_IPHONE_SIMULATOR
	notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
#endif
	
	notification.alertAction = @"打开";
	notification.timeZone = [NSTimeZone defaultTimeZone];
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_lastPlaySoundDate];
	if (timeInterval < kDefaultPlaySoundInterval) {
		//NSLog(@"skip ringing & vibration %@, %@", [NSDate date], _lastPlaySoundDate);
		return;
	}
	
	notification.soundName = UILocalNotificationDefaultSoundName;
	_lastPlaySoundDate = [NSDate date];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
	[userInfo setObject:message.conversationId forKey:kConversationChatter];
	notification.userInfo = userInfo;
	
	//发送通知
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	[UIApplication sharedApplication].applicationIconBadgeNumber += 1;
}

#if IS_USE_CALL == 1
#pragma mark - EMCallManagerDelegate
- (void)didReceiveCallIncoming:(EMCallSession *)aSession
{
	if (_callSession && _callSession.status != EMCallSessionStatusDisconnected) {
		[[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonBusy];
	}
	
	if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
		[[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonFailed];
	}
	
	_callSession = aSession;
	if (_callSession) {
		[self _startCallTimer];
		
		[Common getApiWithParams:@{@"app":@"member", @"act":@"get_contact", @"member_id":_callSession.remoteUsername} success:^(NSMutableDictionary *json) {
			//NSLog(@"%@", json.descriptionASCII);
			if ([json[@"data"] isDictionary]) {
				EaseProfileModel *model = [[EaseProfileModel alloc]init];
				model.name = json[@"data"][@"name"];
				model.avatarURL = json[@"data"][@"avatar"];
				
				_callController = [[CallViewController alloc] initWithSession:_callSession isCaller:NO status:[NSString stringWithFormat:@"邀请你%@聊天", _callSession.type==EMCallTypeVoice?@"语音":@"视频"]];
				_callController.model = model;
				_callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
				[APPCurrentController presentViewController:_callController animated:NO completion:nil];
			}
		} fail:nil];
	}
}

- (void)didReceiveCallConnected:(EMCallSession *)aSession
{
	if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
		_callController.statusLabel.text = @"正在等待对方接受邀请";
		
		AVAudioSession *audioSession = [AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[audioSession setActive:YES error:nil];
	}
}

- (void)didReceiveCallAccepted:(EMCallSession *)aSession
{
	if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
		[[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonFailed];
	}
	
	if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
		[self _stopCallTimer];
		
		//NSString *connectStr = aSession.connectType == EMCallConnectTypeRelay ? @"Relay" : @"Direct";
		_callController.statusLabel.text = @"";
		_callController.timeLabel.hidden = NO;
		[_callController startTimer];
		[_callController startShowInfo];
		_callController.cancelButton.hidden = NO;
		_callController.rejectButton.hidden = YES;
		_callController.answerButton.hidden = YES;
	}
}

- (void)didReceiveCallTerminated:(EMCallSession *)aSession
						  reason:(EMCallEndReason)aReason
						   error:(EMError *)aError
{
	if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
		[self _stopCallTimer];
		
		_callSession = nil;
		
		[_callController close];
		_callController = nil;
		
		if (aReason != EMCallEndReasonHangup) {
			NSString *reasonStr = @"";
			switch (aReason) {
				case EMCallEndReasonNoResponse:
				{
					reasonStr = @"对方没有回应";
				}
					break;
				case EMCallEndReasonDecline:
				{
					reasonStr = @"对方拒绝接听";
				}
					break;
				case EMCallEndReasonBusy:
				{
					reasonStr = @"通话中";
				}
					break;
				case EMCallEndReasonFailed:
				{
					reasonStr = @"连接失败";
				}
					break;
				default:
					break;
			}
			
			if (aError) {
				NSString *message = aError.errorDescription;
				if ([message indexOf:@"offline"]!=NSNotFound) message = @"对方不在线";
				[ProgressHUD showWarning:message];
			}
			else {
				[ProgressHUD showWarning:reasonStr];
			}
		}
	}
}

- (void)didReceiveCallNetworkChanged:(EMCallSession *)aSession status:(EMCallNetworkStatus)aStatus
{
	if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
		[_callController setNetwork:aStatus];
	}
}

- (void)makeCall:(NSNotification*)notify
{
	if (notify.object) {
		[self makeCallWithUsername:[notify.object valueForKey:@"chatter"] isVideo:[[notify.object objectForKey:@"type"] boolValue] model:[notify.object objectForKey:@"model"]];
	}
}

- (void)_startCallTimer
{
	_callTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_cancelCall) userInfo:nil repeats:NO];
}

- (void)_stopCallTimer
{
	if (_callTimer == nil) {
		return;
	}
	
	[_callTimer invalidate];
	_callTimer = nil;
}

- (void)_cancelCall
{
	[self hangupCallWithReason:EMCallEndReasonNoResponse];
	
	[ProgressHUD showWarning:@"对方没有接听"];
}

- (void)makeCallWithUsername:(NSString *)aUsername isVideo:(BOOL)aIsVideo model:(EaseProfileModel*)model
{
	if ([aUsername length] == 0) {
		return;
	}
	
	if (aIsVideo) {
		_callSession = [[EMClient sharedClient].callManager makeVideoCall:aUsername error:nil];
	}
	else {
		_callSession = [[EMClient sharedClient].callManager makeVoiceCall:aUsername error:nil];
	}
	
	if (_callSession) {
		[self _startCallTimer];
		
		_callController = [[CallViewController alloc] initWithSession:_callSession isCaller:YES status:@"正在等待对方接受邀请"];
		_callController.model = model;
		[APPCurrentController presentViewController:_callController animated:YES completion:nil];
	}
	else {
		[ProgressHUD showError:@"创建通话失败"];
	}
}

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
	[self _stopCallTimer];
	
	if (_callSession) {
		[[EMClient sharedClient].callManager endCall:_callSession.sessionId reason:aReason];
	}
	
	_callSession = nil;
	[_callController close];
	_callController = nil;
}

- (void)answerCall
{
	if (_callSession) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			EMError *error = [[EMClient sharedClient].callManager answerCall:self->_callSession.sessionId];
			if (error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (error.code == EMErrorNetworkUnavailable) {
						[ProgressHUD showError:@"网络连接失败"];
					}
					else {
						[self hangupCallWithReason:EMCallEndReasonFailed];
					}
				});
			}
		});
	}
}


- (void)_clearHelper
{
	[[EMClient sharedClient] logout:NO];
	[self hangupCallWithReason:EMCallEndReasonFailed];
}
#endif

#pragma mark - Auto Login Delegate

- (void)willAutoReconnect{
	//NSLog(@"连接中");
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
	if (error) {
		//NSLog(@"连接失败，稍后将会重新尝试连接");
	} else {
		//NSLog(@"连接成功");
	}
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
	if (!error) {
		//刷新聊天列表
	}
}

#pragma mark - app delegate notifications

// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)_setupAppDelegateNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidEnterBackgroundNotif:)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
	[[EMClient sharedClient] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
	[[EMClient sharedClient] applicationWillEnterForeground:notif.object];
}

#pragma mark - register apns
// 注册推送
- (void)_registerRemoteNotification
{
	UIApplication *application = [UIApplication sharedApplication];
	application.applicationIconBadgeNumber = 0;
	
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
		UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
		[application registerUserNotificationSettings:settings];
	}
	
#if !TARGET_IPHONE_SIMULATOR
	//iOS8 注册APNS
	if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
		[application registerForRemoteNotifications];
	} else {
		UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
		UIRemoteNotificationTypeSound |
		UIRemoteNotificationTypeAlert;
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
	}
#endif
}

#pragma mark - send message
+ (void)sendMessage:(EMMessage *)message completion:(void (^)(EMMessage *message, EMError *error))completion
{
	[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
		if (completion) completion(aMessage, aError);
	}];
}

+ (EMMessage *)sendTextMessage:(NSString *)text
							to:(NSString *)toUser
				   messageType:(EMChatType)messageType
					messageExt:(NSDictionary *)messageExt

{
	EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
	NSString *from = [[EMClient sharedClient] currentUsername];
	EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
	message.chatType = messageType;
	
	return message;
}

+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
									 longitude:(double)longitude
									   address:(NSString *)address
											to:(NSString *)to
								   messageType:(EMChatType)messageType
									messageExt:(NSDictionary *)messageExt
{
	EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude longitude:longitude address:address];
	NSString *from = [[EMClient sharedClient] currentUsername];
	EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
	message.chatType = messageType;
	
	return message;
}

+ (EMMessage *)sendImageMessageWithImageData:(NSData *)imageData
										  to:(NSString *)to
								 messageType:(EMChatType)messageType
								  messageExt:(NSDictionary *)messageExt
{
	EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:imageData displayName:@"image.png"];
	NSString *from = [[EMClient sharedClient] currentUsername];
	EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
	message.chatType = messageType;
	
	return message;
}

+ (EMMessage *)sendImageMessageWithImage:(UIImage *)image
									  to:(NSString *)to
							 messageType:(EMChatType)messageType
							  messageExt:(NSDictionary *)messageExt
{
	NSData *data = UIImageJPEGRepresentation(image, 1);
	
	return [self sendImageMessageWithImageData:data to:to messageType:messageType messageExt:messageExt];
}

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
									duration:(NSInteger)duration
										  to:(NSString *)to
								 messageType:(EMChatType)messageType
								  messageExt:(NSDictionary *)messageExt
{
	EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:localPath displayName:@"audio"];
	body.duration = (int)duration;
	NSString *from = [[EMClient sharedClient] currentUsername];
	EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
	message.chatType = messageType;
	
	return message;
}

+ (EMMessage *)sendVideoMessageWithURL:(NSURL *)url
									to:(NSString *)to
						   messageType:(EMChatType)messageType
							messageExt:(NSDictionary *)messageExt
{
	EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[url path] displayName:@"video.mp4"];
	NSString *from = [[EMClient sharedClient] currentUsername];
	EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
	message.chatType = messageType;
	
	return message;
}

#pragma mark - private
- (BOOL)_needShowNotification:(NSString *)fromChatter
{
	BOOL ret = YES;
	NSArray *igGroupIds = [[EMClient sharedClient].groupManager getAllIgnoredGroupIds];
	for (NSString *str in igGroupIds) {
		if ([str isEqualToString:fromChatter]) {
			ret = NO;
			break;
		}
	}
	return ret;
}

@end
