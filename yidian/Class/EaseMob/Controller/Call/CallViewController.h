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
#import <Hyphenate/EMCallManagerDelegate.h>

#define kLocalCallBitrate @"EaseMobLocalCallBitrate"

@class EaseConversationModel, EaseProfileModel;

@interface CallViewController : UIViewController
{
    NSTimer *_timeTimer;
    
    UIView *_topView;
    UILabel *_statusLabel;
    UILabel *_timeLabel;
    UILabel *_nameLabel;
    UIImageView *_headerImageView;
    
    //操作按钮显示
    UIView *_actionView;
    UIButton *_silenceButton;
    UILabel *_silenceLabel;
    UIButton *_speakerOutButton;
    UILabel *_speakerOutLabel;
    UIButton *_rejectButton;
    UIButton *_answerButton;
    UIButton *_cancelButton;
    
    UIButton *_recordButton;
    UIButton *_videoButton;
    UIButton *_voiceButton;
    UIButton *_switchCameraButton;
}

@property (nonatomic,assign) BOOL showRecordBtn;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *rejectButton;
@property (strong, nonatomic) UIButton *answerButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) EaseProfileModel *model;

- (instancetype)initWithSession:(EMCallSession *)session
                       isCaller:(BOOL)isCaller
                         status:(NSString *)statusString;

+ (BOOL)canVideo;

+ (void)saveBitrate:(NSString*)value;

- (void)startTimer;

- (void)startShowInfo;

- (void)close;

- (void)setNetwork:(EMCallNetworkStatus)status;

@end
