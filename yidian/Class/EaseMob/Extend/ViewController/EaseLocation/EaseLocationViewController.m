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

#import <CoreLocation/CoreLocation.h>
#import "EaseLocationViewController.h"
#import "EaseAnnotation.h"
#import "EaseAnnotationView.h"
#import "Global.h"

//#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MapZoomLevel 200.f

const double m_x_pi = 3.14159265358979324 * 3000.0 / 180.0;
//火星转百度坐标
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon)
{
	double x = gg_lon, y = gg_lat;
	double z = sqrt(x * x + y * y) + 0.00002 * sin(y * m_x_pi);
	double theta = atan2(y, x) + 0.000003 * cos(x * m_x_pi);
	*bd_lon = z * cos(theta) + 0.0065;
	*bd_lat = z * sin(theta) + 0.006;
}
//百度坐标转火星
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
	double x = bd_lon - 0.0065, y = bd_lat - 0.006;
	double z = sqrt(x * x + y * y) - 0.00002 * sin(y * m_x_pi);
	double theta = atan2(y, x) - 0.000003 * cos(x * m_x_pi);
	*gg_lon = z * cos(theta);
	*gg_lat = z * sin(theta);
}

static EaseLocationViewController *defaultLocation = nil;

@interface EaseLocationViewController () <MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,EaseAnnotationViewDelegate>
{
    MKMapView *_mapView;
    EaseAnnotation *_annotation;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
	BOOL _isSendLocation;
	BOOL _loadLocation;
	MKCoordinateRegion _userRegion;
}
@property (strong, nonatomic) NSString *address;
@end

@implementation EaseLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
		_address = @"";
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate address:(NSString*)address
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
		_address = address;
    }
    
    return self;
}

+ (instancetype)defaultLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocation = [[EaseLocationViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return defaultLocation;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	_mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	_mapView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"位置信息";
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	_mapView.mapType = MKMapTypeStandard;
	_mapView.delegate = self;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
	
    if (_isSendLocation) {
        _mapView.showsUserLocation = YES;//显示当前位置
		
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"发送" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
		[self startLocation];
		
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		[doubleTap setNumberOfTapsRequired:2];
		[singleTap requireGestureRecognizerToFail:doubleTap];
		[_mapView addGestureRecognizer:singleTap];
		[_mapView addGestureRecognizer:doubleTap];
		
		UIButton *goUserLocBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, SCREEN_HEIGHT-64-40-20, 40, 40)];
		goUserLocBtn.backgroundColor = [UIColor clearColor];
		[goUserLocBtn setImage:[UIImage imageNamed:@"chat_location_position"] forState:UIControlStateNormal];
		[goUserLocBtn setImage:[UIImage imageNamed:@"chat_location_position_press"] forState:UIControlStateHighlighted];
		[goUserLocBtn addTarget:self action:@selector(goUserLocation:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:goUserLocBtn];
    }
    else {
        [self removeToLocation:_currentLocationCoordinate];
    }
}

- (void)handleSingleTap:(UIGestureRecognizer*)gestureRecognizer {
	CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
	//这里touchMapCoordinate就是该点的经纬度了
	CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
	
	__weak typeof(self) weakSelf = self;
	CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
		if (!error && array.count > 0) {
			CLPlacemark *placemark = [array objectAtIndex:0];
			weakSelf.address = placemark.name;
			[self removeToLocation:touchMapCoordinate];
		}
	}];
}

- (void)handleDoubleTap:(UIGestureRecognizer*)gestureRecognizer {
	
}

- (void)goUserLocation:(id)sender{
	if (!_loadLocation) return;
	[_mapView setRegion:[_mapView regionThatFits:_userRegion] animated:YES];
	
	__weak typeof(self) weakSelf = self;
	CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:_userRegion.center.latitude longitude:_userRegion.center.longitude];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
		if (!error && array.count > 0) {
			CLPlacemark *placemark = [array objectAtIndex:0];
			weakSelf.address = placemark.name;
			[self removeToLocation:_userRegion.center];
		}
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	_loadLocation = YES;
	//当前位置
	_userRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, MapZoomLevel, MapZoomLevel);
	
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.address = placemark.name;
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [ProgressHUD dismiss];
    if (error.code == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
        default:
            break;
    }
}

//显示大头针标注
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	if (_isSendLocation) {
		return nil;
	}
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	if ([annotation isKindOfClass:[EaseAnnotation class]]) {
		static NSString *identifier = @"MKAnnotationView";
		EaseAnnotationView *annotationView = (EaseAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (!annotationView) {
			annotationView = [[EaseAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
			annotationView.delegate = self;
		}
		
		annotationView.backgroundColor = [UIColor clearColor];
		annotationView.annotation = annotation;
		[annotationView layoutSubviews];
		[annotationView setCanShowCallout:NO];
		
		return annotationView;
	} else {
		return nil;
	}
}

#pragma mark - public

- (void)startLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [ProgressHUD show:@"定位中"];
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
	if ([_mapView.annotations count]) {
		[_mapView removeAnnotations:_mapView.annotations];
	}
	
    if (_annotation == nil) {
        _annotation = [[EaseAnnotation alloc] init];
    }
    else {
        [_mapView removeAnnotation:_annotation];
    }
	
	if (_isSendLocation) {
		_annotation.coordinate = coords;
		[_mapView addAnnotation:_annotation];
	} else {
		CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:coords.latitude longitude:coords.longitude];
		CLGeocoder *geocoder = [[CLGeocoder alloc]init];
		[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
			if (!error && placemarks.count > 0) {
				CLPlacemark *placemark = [placemarks objectAtIndex:0];
				//NSString *province = placemark.administrativeArea ? placemark.administrativeArea : @""; //省
				//NSString *city = placemark.locality ? placemark.locality : @""; //市
				NSString *district = placemark.subLocality ? placemark.subLocality : @""; //区
				_annotation.coordinate = coords;
				_annotation.title = district;
				_annotation.subtitle  = _address;
				_annotation.annotationStatus = NaviSuc;
				[_mapView addAnnotation:_annotation];
				[_mapView selectAnnotation:_annotation animated:YES];
			}
		}];
	}
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [ProgressHUD dismiss];
    
    _currentLocationCoordinate = locationCoordinate;
	
	float zoomLevel = 0.01;
	MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
	//MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_currentLocationCoordinate, MapZoomLevel, MapZoomLevel);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (void)sendLocation
{
	if (!_loadLocation) return;
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocationLatitude:longitude:address:)]) {
        [_delegate sendLocationLatitude:_currentLocationCoordinate.latitude longitude:_currentLocationCoordinate.longitude address:_address];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)EaseAnnotationViewNaviClick{
	[self showActionSheet];
}

- (NSArray *)hasMapApp{
	NSArray *mapSchemeArr = @[@"comgooglemaps://", @"iosamap://navi", @"baidumap://map/"];
	NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图", nil];
	for (int i = 0; i < [mapSchemeArr count]; i++) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[mapSchemeArr objectAtIndex:i]]]) {
			if (i == 0) {
				[appListArr addObject:@"谷歌地图"];
			} else if (i == 1) {
				[appListArr addObject:@"高德地图"];
			} else if (i == 2) {
				[appListArr addObject:@"百度地图"];
			}
		}
	}
	return appListArr;
}

- (void)showActionSheet{
	NSArray *appListArr = [self hasMapApp];
	NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@", _address];
	
	UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:sheetTitle delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:nil];
	for (NSString *title in appListArr) {
		[sheet addButtonWithTitle:title];
	}
	[sheet addButtonWithTitle:@"取消"];
	sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
	sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([btnTitle isEqualToString:@"苹果地图"]) {
		CLLocationCoordinate2D to;
		to.latitude = _currentLocationCoordinate.latitude;
		to.longitude = _currentLocationCoordinate.longitude;
		MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
		MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
		toLocation.name = _address;
		[MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
		
	} else if ([btnTitle isEqualToString:@"谷歌地图"]) {
		NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit", _userRegion.center.latitude, _userRegion.center.longitude, _currentLocationCoordinate.latitude, _currentLocationCoordinate.longitude];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
		
	} else if ([btnTitle isEqualToString:@"高德地图"]) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2", _address, _currentLocationCoordinate.latitude, _currentLocationCoordinate.longitude]];
		[[UIApplication sharedApplication] openURL:url];
		
	} else if ([btnTitle isEqualToString:@"百度地图"]) {
		double bdNowLat, bdNowLon, bdNavLat, bdNavLon;
		bd_encrypt(_userRegion.center.latitude, _userRegion.center.longitude, &bdNowLat, &bdNowLon);
		bd_encrypt(_currentLocationCoordinate.latitude, _currentLocationCoordinate.longitude, &bdNavLat, &bdNavLon);
		NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving", bdNowLat, bdNowLon, bdNavLat, bdNavLon];
		NSURL *url = [NSURL URLWithString:stringURL];
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end
