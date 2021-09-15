//
//  CCLocationManager.h
//

/*
 集成说明：
 1、导入 CoreLocation.framework
 2、在Info.plist添加
	NSLocationAlwaysUsageDescription ＝ 打开定位服务才能获取当前位置
	NSLocationWhenInUseUsageDescription ＝ 打开定位服务才能获取当前位置
 3、通过block回调获取经纬度、地理位置等, block必须在主线程运行,否则不会回调
 
 //获取坐标
 [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
	NSLog(@"%f %f", locationCorrrdinate.latitude, locationCorrrdinate.longitude);
 }];
 
 //获取城市
 [[CCLocationManager shareLocation] getCity:^(NSString *province, NSString *city, NSString *district, NSString *address) {
	NSLog(@"%@", city);
 }];
 
 //获取详细地址信息
 [[CCLocationManager shareLocation] getDetail:^(NSString *address, NSDictionary *detail) {
	NSLog(@"%@", detail);
 }];
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
typedef void (^LocationLLBlock)(double latitude, double longitude);
typedef void (^LocationErrorBlock) (NSError *error);
typedef void (^JsonBlock) (NSDictionary *jsonBlock);
typedef void (^CityBlock)(NSString *province, NSString *city, NSString *district, NSString *address);
typedef void (^AddressBlock)(NSString *address, NSDictionary *detail);

@interface CCLocationManager : NSObject<CLLocationManagerDelegate>

+ (CCLocationManager *)shareLocation;

//获取坐标
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock;

//获取坐标,返回double类型
- (void)getLocationCoordinateWithDouble:(LocationLLBlock)locaiontllBlock;
- (void)getBaiduCoordinateWithDouble:(LocationLLBlock)locaiontllBlock;

//获取坐标和省市区
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withCity:(CityBlock)cityBlock;
- (void)getBaiduCoordinate:(LocationBlock)locaiontBlock withCity:(CityBlock)cityBlock;
- (void)getBaiduGeocoder:(JsonBlock)jsonBlock;

//获取省市区
- (void)getCity:(CityBlock)cityBlock;

//获取省市区和定位失败
- (void)getCity:(CityBlock)cityBlock error:(LocationErrorBlock)errorBlock;

//获取坐标和详细地址
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withAddress:(AddressBlock)addressBlock;

//获取详细地址信息
- (void)getDetail:(AddressBlock)addressBlock;

//计算两个地点之间的距离
- (double)distanceWithLat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2;

@end
