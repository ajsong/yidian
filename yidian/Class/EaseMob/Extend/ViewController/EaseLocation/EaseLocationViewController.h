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
#import <MapKit/MapKit.h>

@protocol EMLocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
				  longitude:(double)longitude
					address:(NSString *)address;
@end

@interface EaseLocationViewController : UIViewController

@property (nonatomic, assign) id<EMLocationViewDelegate> delegate;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate address:(NSString*)address;

@end
