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

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate+EaseMob.h"
#import <Hyphenate/EMClient+Call.h>
#import "CallViewController.h"
#import "UIImageView+EMWebCache.h"
#import "EaseConversationModel.h"

@interface CallViewController ()
{
    __weak EMCallSession *_callSession;
    BOOL _isCaller;
    NSString *_status;
    int _timeLength;
	
	AVAudioPlayer *_ringPlayer;
    NSString * _audioCategory;
    
    //视频属性显示区域
    UIView *_propertyView;
    UILabel *_sizeLabel;
    UILabel *_timedelayLabel;
    UILabel *_framerateLabel;
    UILabel *_lostcntLabel;
    UILabel *_remoteBitrateLabel;
    UILabel *_localBitrateLabel;
    NSTimer *_propertyTimer;
    //弱网检测
    UILabel *_networkLabel;
}

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation CallViewController

- (instancetype)initWithSession:(EMCallSession *)session
                       isCaller:(BOOL)isCaller
                         status:(NSString *)statusString
{
    self = [super init];
    if (self) {
        _callSession = session;
        _isCaller = isCaller;
        _timeLabel.text = @"";
        _timeLength = 0;
        _status = statusString;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud valueForKey:kLocalCallBitrate] && _callSession.type == EMCallTypeVideo) {
            [session setVideoBitrate:[[ud valueForKey:kLocalCallBitrate] intValue]];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self performSelector:@selector(_initializeSubviews) withObject:nil afterDelay:0];
}

- (void)_initializeSubviews{
	[self.view addGestureRecognizer:self.tapRecognizer];
	
	[self _setupSubviews];
	
	_nameLabel.text = _model ? _model.name : _callSession.remoteUsername;
	if (_model) {
		[_headerImageView em_setImageWithURL:[NSURL URLWithString:_model.avatarURL] placeholderImage:IMGEASE(@"user")];
	} else {
		_headerImageView.image = IMGEASE(@"user");
	}
	_statusLabel.text = _status;
	if (_isCaller) {
		self.rejectButton.hidden = YES;
		self.answerButton.hidden = YES;
		self.cancelButton.hidden = NO;
	}
	else {
		self.cancelButton.hidden = YES;
		self.rejectButton.hidden = NO;
		self.answerButton.hidden = NO;
	}
	
	if (_callSession.type == EMCallTypeVideo) {
		[self _initializeVideoView];
		[self.view bringSubviewToFront:_topView];
		[self.view bringSubviewToFront:_actionView];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) self.view = nil;
}

#pragma mark - getter

- (BOOL)isShowCallInfo
{
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"showCallInfo"];
    return [object boolValue];
}

#pragma makr - property

- (UITapGestureRecognizer *)tapRecognizer
{
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    }
    
    return _tapRecognizer;
}

#pragma mark - subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
	[self.view addSubview:bgImageView];
	if (_model) {
		[bgImageView em_setImageWithURL:[NSURL URLWithString:_model.avatarURL] placeholderImage:IMGEASE(@"call_bg")];
		UIToolbar *mask = [[UIToolbar alloc]initWithFrame:bgImageView.bounds];
		mask.barStyle = UIBarStyleBlackTranslucent;
		[bgImageView addSubview:mask];
	} else {
		bgImageView.image = IMGEASE(@"call_bg");
	}
	
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, _topView.frame.size.width - 20, 20)];
    _statusLabel.font = [UIFont systemFontOfSize:15.0];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:self.statusLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_statusLabel.frame), _topView.frame.size.width, 15)];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:_timeLabel];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_topView.frame.size.width - 80) / 2, CGRectGetMaxY(_statusLabel.frame) + 20, 80, 80)];
	_headerImageView.layer.masksToBounds = YES;
	_headerImageView.layer.cornerRadius = _headerImageView.frame.size.height/2;
    [_topView addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 5, _topView.frame.size.width, 30)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.text = _callSession.remoteUsername;
    [_topView addSubview:_nameLabel];
    
    _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameLabel.frame) + 5, _topView.frame.size.width, 20)];
    _networkLabel.font = [UIFont systemFontOfSize:14.0];
    _networkLabel.backgroundColor = [UIColor clearColor];
    _networkLabel.textColor = [UIColor whiteColor];
    _networkLabel.textAlignment = NSTextAlignmentCenter;
    _networkLabel.hidden = YES;
    [_topView addSubview:_networkLabel];
    
    if (_callSession.type == EMCallTypeVideo) {
        _switchCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_statusLabel.frame) + 20, 40, 40)];
		[_switchCameraButton setBackgroundColor:[UIColor clearColor]];
		[_switchCameraButton setImage:IMGEASE(@"call_camera") forState:UIControlStateNormal];
        //[_switchCameraButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
        //[_switchCameraButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_switchCameraButton addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
        _switchCameraButton.userInteractionEnabled = YES;
		[_topView addSubview:_switchCameraButton];
		
		if (_showRecordBtn) {
			_recordButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_switchCameraButton.frame)+50, 40, 40)];
			//_recordButton.layer.cornerRadius = 20.f;
			//[_recordButton setTitle:@"录制" forState:UIControlStateNormal];
			//[_recordButton setTitle:@"停止" forState:UIControlStateSelected];
			//[_recordButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
			[_recordButton setImage:IMGEASE(@"call_record") forState:UIControlStateNormal];
			[_recordButton setImage:IMGEASE(@"call_record_h") forState:UIControlStateSelected];
			[_recordButton setBackgroundColor:[UIColor clearColor]];
			[_recordButton addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
			[_topView addSubview:_recordButton];
			
			_videoButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_recordButton.frame)+20, 40, 40)];
			//_videoButton.layer.cornerRadius = 20.f;
			//[_videoButton setTitle:@"不录视频" forState:UIControlStateNormal];
			//[_videoButton setTitle:@"录制视频" forState:UIControlStateSelected];
			//[_videoButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
			[_videoButton setImage:IMGEASE(@"call_record_video_h") forState:UIControlStateNormal];
			[_videoButton setImage:IMGEASE(@"call_record_video") forState:UIControlStateSelected];
			[_videoButton setBackgroundColor:[UIColor clearColor]];
			[_videoButton addTarget:self action:@selector(videoPauseAction) forControlEvents:UIControlEventTouchUpInside];
			_videoButton.hidden = YES;
			[_topView addSubview:_videoButton];
			
			_voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_videoButton.frame)+20, 40, 40)];
			//_voiceButton.layer.cornerRadius = 20.f;
			//[_voiceButton setTitle:@"不录语音" forState:UIControlStateNormal];
			//[_voiceButton setTitle:@"录制语音" forState:UIControlStateSelected];
			//[_voiceButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
			[_voiceButton setImage:IMGEASE(@"call_record_voice_h") forState:UIControlStateNormal];
			[_voiceButton setImage:IMGEASE(@"call_record_voice") forState:UIControlStateSelected];
			[_voiceButton setBackgroundColor:[UIColor clearColor]];
			[_voiceButton addTarget:self action:@selector(voicePauseAction) forControlEvents:UIControlEventTouchUpInside];
			_voiceButton.hidden = YES;
			[_topView addSubview:_voiceButton];
		}
	}
	
    _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, self.view.frame.size.width, 220)];
    _actionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_actionView];
    
    CGFloat tmpWidth = _actionView.frame.size.width / 2;
    _silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 40) / 2, 40, 40, 40)];
    [_silenceButton setImage:IMGEASE(@"call_silence") forState:UIControlStateNormal];
    [_silenceButton setImage:IMGEASE(@"call_silence_h") forState:UIControlStateSelected];
    [_silenceButton addTarget:self action:@selector(silenceAction) forControlEvents:UIControlEventTouchUpInside];
	[_actionView addSubview:_silenceButton];
    
    _silenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(_silenceButton.frame) + 5, tmpWidth - 60, 20)];
    _silenceLabel.backgroundColor = [UIColor clearColor];
    _silenceLabel.textColor = [UIColor whiteColor];
    _silenceLabel.font = [UIFont systemFontOfSize:13.0];
    _silenceLabel.textAlignment = NSTextAlignmentCenter;
    _silenceLabel.text = @"静音";
	[_actionView addSubview:_silenceLabel];
    
    _speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 40) / 2, _silenceButton.frame.origin.y, 40, 40)];
    [_speakerOutButton setImage:IMGEASE(@"call_out") forState:UIControlStateNormal];
    [_speakerOutButton setImage:IMGEASE(@"call_out_h") forState:UIControlStateSelected];
    [_speakerOutButton addTarget:self action:@selector(speakerOutAction) forControlEvents:UIControlEventTouchUpInside];
	[_actionView addSubview:_speakerOutButton];
    
    _speakerOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(tmpWidth + 30, CGRectGetMaxY(_speakerOutButton.frame) + 5, tmpWidth - 60, 20)];
    _speakerOutLabel.backgroundColor = [UIColor clearColor];
    _speakerOutLabel.textColor = [UIColor whiteColor];
    _speakerOutLabel.font = [UIFont systemFontOfSize:13.0];
    _speakerOutLabel.textAlignment = NSTextAlignmentCenter;
    _speakerOutLabel.text = @"扬声器";
	[_actionView addSubview:_speakerOutLabel];
    
    _rejectButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 64) / 2, CGRectGetMaxY(_speakerOutLabel.frame) + 20, 64, 64)];
	//[_rejectButton setTitle:@"拒绝" forState:UIControlStateNormal];
	[_rejectButton setImage:IMGEASE(@"call_off") forState:UIControlStateNormal];
    [_rejectButton setBackgroundColor:[UIColor clearColor]];
    [_rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:_rejectButton];
    
    _answerButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 64) / 2, _rejectButton.frame.origin.y, 64, 64)];
	//[_answerButton setTitle:@"接听" forState:UIControlStateNormal];
	[_answerButton setImage:IMGEASE(@"call_on") forState:UIControlStateNormal];
    [_answerButton setBackgroundColor:[UIColor clearColor]];
    [_answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:_answerButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 64) / 2, _rejectButton.frame.origin.y, 64, 64)];
	//[_cancelButton setTitle:@"挂断" forState:UIControlStateNormal];
	[_cancelButton setImage:IMGEASE(@"call_off") forState:UIControlStateNormal];
    [_cancelButton setBackgroundColor:[UIColor clearColor]];
    [_cancelButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:_cancelButton];
}

- (void)_initializeVideoView
{
    //1.对方窗口
    _callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 288 / 352, self.view.frame.size.height)];
    [self.view addSubview:_callSession.remoteVideoView];
    
    //2.自己窗口
    CGFloat width = 80;
    CGFloat height = self.view.frame.size.height / self.view.frame.size.width * width;
    _callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(_statusLabel.frame), width, height)];
    [self.view addSubview:_callSession.localVideoView];
    
    //3、属性显示层
    _propertyView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(_actionView.frame) - 90, self.view.frame.size.width - 20, 90)];
    _propertyView.backgroundColor = [UIColor clearColor];
    _propertyView.hidden = ![self isShowCallInfo];
    [self.view addSubview:_propertyView];
    
    width = (CGRectGetWidth(_propertyView.frame) - 20) / 2;
    height = CGRectGetHeight(_propertyView.frame) / 3;
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_sizeLabel];
    
    _timedelayLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    _timedelayLabel.backgroundColor = [UIColor clearColor];
    _timedelayLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_timedelayLabel];
    
    _framerateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height, width, height)];
    _framerateLabel.backgroundColor = [UIColor clearColor];
    _framerateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_framerateLabel];
    
    _lostcntLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height, width, height)];
    _lostcntLabel.backgroundColor = [UIColor clearColor];
    _lostcntLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_lostcntLabel];
    
    _localBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height * 2, width, height)];
    _localBitrateLabel.backgroundColor = [UIColor clearColor];
    _localBitrateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_localBitrateLabel];
    
    _remoteBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height * 2, width, height)];
    _remoteBitrateLabel.backgroundColor = [UIColor clearColor];
    _remoteBitrateLabel.textColor = [UIColor redColor];
    [_propertyView addSubview:_remoteBitrateLabel];
}

#pragma mark - private

- (void)_reloadPropertyData
{
    if (_callSession) {
        _sizeLabel.text = [NSString stringWithFormat:@"%@%i/%i", NSLocalizedString(@"call.videoSize", @"Width/Height: "), [_callSession getVideoWidth], [_callSession getVideoHeight]];
        _timedelayLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoTimedelay", @"Timedelay: "), [_callSession getVideoTimedelay]];
        _framerateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoFramerate", @"Framerate: "), [_callSession getVideoFramerate]];
        _lostcntLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLostcnt", @"Lostcnt: "), [_callSession getVideoLostcnt]];
        _localBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLocalBitrate", @"Local Bitrate: "), [_callSession getVideoLocalBitrate]];
        _remoteBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoRemoteBitrate", @"Remote Bitrate: "), [_callSession getVideoRemoteBitrate]];
    }
}

- (void)_beginRing
{
    [_ringPlayer stop];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    _ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_ringPlayer setVolume:1];
    _ringPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    if([_ringPlayer prepareToPlay])
    {
        [_ringPlayer play]; //播放
    }
}

- (void)_stopRing
{
    [_ringPlayer stop];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int h = _timeLength / 3600;
    int m = (_timeLength - h * 3600) / 60;
    int s = _timeLength - h * 3600 - m * 60;
	
	NSString *hour = [self fillZero:h];
	NSString *minute = [self fillZero:m];
	NSString *second = [self fillZero:s];
    
    if (h > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    }
    else if (m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@", minute, second];
    }
    else {
        _timeLabel.text = [NSString stringWithFormat:@"00:%@", second];
    }
}
- (NSString*)fillZero:(int)integer{
	NSMutableString *string = [[NSMutableString alloc]init];
	for (NSInteger i=0; i<2; i++) {
		[string appendString:@"0"];
	}
	[string appendFormat:@"%ld", (long)integer];
	NSString *str = [NSString stringWithFormat:@"%@", string];
	str = [Global right:str length:2];
	return str;
}

#pragma mark - UITapGestureRecognizer

- (void)viewTapAction:(UITapGestureRecognizer *)tap
{
	if (_topView.hidden) {
		_topView.alpha = 0;
		_actionView.alpha = 0;
		_topView.hidden = NO;
		_actionView.hidden = NO;
		[UIView animateWithDuration:0.3 animations:^{
			_topView.alpha = 1;
			_actionView.alpha = 1;
		}];
	} else {
		[UIView animateWithDuration:0.3 animations:^{
			_topView.alpha = 0;
			_actionView.alpha = 0;
		} completion:^(BOOL finished) {
			_topView.hidden = YES;
			_actionView.hidden = YES;
		}];
	}
}

#pragma mark - action

- (void)switchCameraAction
{
    [_callSession setCameraBackOrFront:_switchCameraButton.selected];
    _switchCameraButton.selected = !_switchCameraButton.selected;
}

- (void)recordAction
{
    _recordButton.selected = !_recordButton.selected;
    if (_recordButton.selected) {
        NSString *recordPath = NSHomeDirectory();
        recordPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", recordPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:recordPath]) {
            [fm createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [_callSession startVideoRecord:recordPath];
		_videoButton.alpha = 0;
		_voiceButton.alpha = 0;
		_videoButton.hidden = NO;
		_voiceButton.hidden = NO;
		[UIView animateWithDuration:0.3 animations:^{
			_videoButton.alpha = 1;
			_voiceButton.alpha = 1;
		}];
    } else {
		NSString *tempPath = [_callSession stopVideoRecord];
		[UIView animateWithDuration:0.3 animations:^{
			_videoButton.alpha = 0;
			_voiceButton.alpha = 0;
		} completion:^(BOOL finished) {
			_videoButton.hidden = YES;
			_voiceButton.hidden = YES;
		}];
        if (tempPath.length > 0) {
//            NSURL *videoURL = [NSURL fileURLWithPath:tempPath];
//            MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//            [moviePlayerController.moviePlayer prepareToPlay];
//            moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//            [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
        }
    }
}

- (void)videoPauseAction
{
    _videoButton.selected = !_videoButton.selected;
    if (_videoButton.selected) {
        [[EMClient sharedClient].callManager pauseVideoTransfer:_callSession.sessionId];
    } else {
        [[EMClient sharedClient].callManager resumeVideoTransfer:_callSession.sessionId];
    }
}

- (void)voicePauseAction
{
    _voiceButton.selected = !_voiceButton.selected;
    if (_voiceButton.selected) {
        [[EMClient sharedClient].callManager pauseVoiceAndVideoTransfer:_callSession.sessionId];
    } else {
        [[EMClient sharedClient].callManager resumeVoiceAndVideoTransfer:_callSession.sessionId];
    }
}

- (void)silenceAction
{
    _silenceButton.selected = !_silenceButton.selected;
    [[EMClient sharedClient].callManager markCallSession:_callSession.sessionId isSilence:_silenceButton.selected];
}

- (void)speakerOutAction
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (_speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    _speakerOutButton.selected = !_speakerOutButton.selected;
}

- (void)answerAction
{
    [self _stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    _audioCategory = audioSession.category;
    if(![_audioCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
#if IS_USE_CALL == 1
    [[EaseSDKHelper shareHelper] answerCall];
#endif
}

- (void)hangupAction
{
    [_timeTimer invalidate];
    [self _stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
	[audioSession setActive:YES error:nil];
#if IS_USE_CALL == 1
	[[EaseSDKHelper shareHelper] hangupCallWithReason:EMCallEndReasonHangup];
#endif
}

- (void)rejectAction
{
    [_timeTimer invalidate];
    [self _stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
	[audioSession setActive:YES error:nil];
#if IS_USE_CALL == 1
	[[EaseSDKHelper shareHelper] hangupCallWithReason:EMCallEndReasonDecline];
#endif
}

#pragma mark - public

+ (BOOL)canVideo
{
    if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)){\
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:@"没有相机权限" message:@"请在 \"设置\"-\"私隐\"-\"相机\"." delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alt show];
            return NO;
        }
    }
    
    return YES;
}

+ (void)saveBitrate:(NSString*)value
{
    NSScanner* scan = [NSScanner scannerWithString:value];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:value forKey:kLocalCallBitrate];
        [ud synchronize];
    }
}

- (void)startTimer
{
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)startShowInfo
{
    if (_callSession.type == EMCallTypeVideo && [self isShowCallInfo]) {
        [self _reloadPropertyData];
        _propertyTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_reloadPropertyData) userInfo:nil repeats:YES];
    }
}

- (void)setNetwork:(EMCallNetworkStatus)status
{
    switch (status) {
        case EMCallNetworkStatusNormal:
        {
            _networkLabel.text = @"";
            _networkLabel.hidden = YES;
        }
            break;
        case EMCallNetworkStatusUnstable:
        {
            _networkLabel.text = @"当前网络不稳定";
            _networkLabel.hidden = NO;
        }
            break;
        case EMCallNetworkStatusNoData:
        {
			NSLog(@"没有通话数据");
            _networkLabel.text = @"没有通话数据";
            _networkLabel.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)close
{
    _callSession.remoteVideoView.hidden = YES;
    _callSession = nil;
    _propertyView = nil;
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
