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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

#define IS_USE_CALL 0 //是否使用视频通话
#define IMGEASE(string) [UIImage imageNamed:[NSString stringWithFormat:@"EaseUIResource.bundle/%@", string]]

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_CALL @"callOutWithChatter"
#define KNOTIFICATION_CALL_CLOSE @"callControllerClose"

#define kGroupMessageAtList @"em_at_list"
#define kGroupMessageAtAll @"all"

#define kSDKConfigEnableConsoleLogger @"SDKConfigEnableConsoleLogger"
#define kEaseUISDKConfigIsUseLite @"isUselibEaseMobClientSDKLite"

@interface EaseProfileModel : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatarURL;
@end

#if IS_USE_CALL == 1
#import "EMCallManagerDelegate.h"
@interface EaseSDKHelper : NSObject<EMClientDelegate,EMChatManagerDelegate,EMCallManagerDelegate>
@property (strong, nonatomic) EMCallSession *callSession;
#else
@interface EaseSDKHelper : NSObject<EMClientDelegate,EMChatManagerDelegate>
#endif

//init easemob 后需设置下面两项
@property (nonatomic,strong) Class chatListClass;
@property (nonatomic,strong) Class chatViewClass;

@property (nonatomic) BOOL isShowingimagePicker;
@property (nonatomic) BOOL isLite;

+ (instancetype)shareHelper;
+ (NSString*)latestMessageTime:(EMMessage*)message;
+ (NSString*)latestMessageDetail:(EMMessage*)message;
+ (BOOL)isLogin;
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success;
+ (void)registerWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success;
+ (void)updateNickname:(NSString *)nickname;
+ (void)logout; //主动退出
- (NSString*)currentUsername;
- (void)asyncConversationFromDB;
- (void)asyncPushOptions;
- (void)updatePushOptions;

#if IS_USE_CALL == 1
#pragma mark - call
- (void)makeCallWithUsername:(NSString *)aUsername isVideo:(BOOL)aIsVideo model:(EaseProfileModel*)model;
- (void)hangupCallWithReason:(EMCallEndReason)aReason;
- (void)answerCall;
#endif

#pragma mark - init easemob
- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions appkey:(NSString *)appkey apnsCertName:(NSString *)apnsCertName;

#pragma mark - send message
+ (void)sendMessage:(EMMessage *)message completion:(void (^)(EMMessage *message, EMError *error))completion;

+ (EMMessage *)sendTextMessage:(NSString *)text
							to:(NSString *)to
				   messageType:(EMChatType)messageType
					messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
									 longitude:(double)longitude
									   address:(NSString *)address
											to:(NSString *)to
								   messageType:(EMChatType)messageType
									messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageMessageWithImageData:(NSData *)imageData
										  to:(NSString *)to
								 messageType:(EMChatType)messageType
								  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageMessageWithImage:(UIImage *)image
									  to:(NSString *)to
							 messageType:(EMChatType)messageType
							  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
									duration:(NSInteger)duration
										  to:(NSString *)to
								 messageType:(EMChatType)messageType
								  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVideoMessageWithURL:(NSURL *)url
									to:(NSString *)to
						   messageType:(EMChatType)messageType
							messageExt:(NSDictionary *)messageExt;

@end
