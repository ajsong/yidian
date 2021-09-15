//
//  RegionAnnotationView.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-19.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "EaseAnnotation.h"

@protocol EaseAnnotationViewDelegate <NSObject>
-(void)EaseAnnotationViewNaviClick;
@end

@interface EaseAnnotationView : MKAnnotationView
@property(nonatomic,strong) UIView *regionDetailView;
@property(nonatomic,strong) UIImageView *bgImgView;
@property(nonatomic,assign) id<EaseAnnotationViewDelegate> delegate;
@property(nonatomic,strong) NSString *colorName; //blue, green
@property(nonatomic,strong) EaseAnnotation *regionAnnotaytion;
- (void)layoutSubviews;
@end
