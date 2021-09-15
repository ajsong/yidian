//
//  SParameter.h
//
//  Created by ajsong on 2015-4-21.
//  Copyright (c) 2014 ajsong. All rights reserved.
//
#define API_PRODUCTION 0 //生产环境

//API接口
#if API_PRODUCTION==0
#define API_URL @"http://youbesun.softstao.com" //API接口服务器地址
#else
#define API_URL @"http://bq.youbesun.com"
#endif
#define API_FILE @"api.php" //API接口文件
#define API_PARAMETER [NSString stringWithFormat:@"&sign=%@", SIGN] //API接口追加参数, 格式: &field1=value1&field2=value2
#define API_ERROR_SENDEMAIL @"" //API接口出错发送到指定邮箱, 留空不发送

#define API_KEY_ERROR @"error" //API接口返回成功key
#define API_KEY_ERROR_CODE 0 //API接口返回成功key的值
#define API_KEY_MSG @"msg" //API接口返回信息key
#define API_KEY_MSGTYPE @"msg_type" //API接口返回信息值key

//应用Scheme
#define APP_SCHEME @"yidian"

//友盟
#define UM_APPKEY @"565f96b467e58e8991005732"

//新浪微博分享安全域名(因为使用友盟分享,所以不用修改)
#define SINA_APPKEY @"" //AppKey(只为显不显示用)(为空即不显示)
#define SINA_SECRET @"" //AppSecret
#define SINA_SSOURL @"http://sns.whalecloud.com/sina2/callback" //新浪微博回调地址,必须跟新浪微博后台设置的回调地址一致

//QQ分享
#define QQ_APPID @"1105266225" //AppID
#define QQ_APPKEY @"xwsQ4ArA0QQ34bvI" //AppKey

//微信分享(支付)
#define WX_APPID @"wx672874f42b1938ce" //AppID
#define WX_APPSECRET @"bddd6b87e0bb4f5bb52a9e9d64d171fa" //AppSecret
#define WX_MCHID @"1393659202" //商户号
#define WX_PARTNERID @"bddd6b87e0bb4f5bb52a9e9d64d171fa" //商户API密钥
#define WX_NOTIFY_URL [NSString stringWithFormat:@"%@/wx_notify_url.php", API_URL] //支付结果回调页面

//支付宝
#define ALIPAY_PARTNER @"2088121751901670" //合作身份者ID
#define ALIPAY_SELLER @"elinkminan@foxmail.com" //卖家支付宝帐户
#define ALIPAY_PRIVATEKEY @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAPLk0nSf6cLyNQH7XcGFP47YpzeLwwsKPZkFfQO9TOaKdVGJddbEUr6GwzaHhdlfErghdjzkyfd6LNxYPUnWm2sX9vnupYftTs3v8pUARieuySAjBrGzmkPBVPaCJ5ignSIBVLxx/f/9h3lMoFXa39CpAb1ioi1lCgZrk7/96G//AgMBAAECgYBuxl8ZI0lYSGBWfA6BUMTw3+w7T/lvEoePP0qJpw7oYaMpwZhFj5nxHMLxHpOz1EFUSqaDFRDrVgQZpgClqUONi5dRq6zg8AKkxySGa+lEmAOov2dbs87Hyxlhc0hmKHaVbuEQzA93RSBvCLovjlDykdNwCrpyeqz2XoQ4Ha1gMQJBAPpNLxEDsyMnH0Auy46L+fx29qTO1KjjCnFVupiP0/o0c5OKP0n4vetY4EqSwusAKZrtqiex/+Rd/8Nhc4X7gscCQQD4bHbyGQ0Ud/+X9/OdXDLgQMTALTL2+k792S75PhAZuwjy2lh0QWyvfWLOoqMhERuk38lqWZgi2M/nwKKq8XEJAkEArJtRW8BbZmByMoaSpShuKeW3zIs9J4H6D5H47YAxxBcrpJDveAlqnsNZWNPASuJ/znEap+kd99PCrm+jhL+evQJAI1vM0kieg/tQdeDk29DzrNeLKY9FYcHe3GK9PNyIjiEA9Q/+5w0o2xGNrruXXG2C8cSodmqqLMuPS/0vKgWTgQJACa0SNyvmcTrg0McL79Eu10sEuU+6WO9XpT0mCHojlAYEwSi01VYOIQao7MukGZTEql3uSdJrMimt27fiUWR4bg==" //商户私钥
#define ALIPAY_NOTIFY_URL [NSString stringWithFormat:@"%@/ali_notify_url.php", API_URL] //支付结果回调页面
#define ALIPAY_APPSCHEME APP_SCHEME //应用注册scheme,同时需要在Info.plist定义URL types

//腾讯Bugly
#define BUGLY_APPID @"02d7687990"

//环信
#define EASEMOB_APPKEY @"zhangdong#yidian"
#define EASEMOB_APNSCERTNAME @"yidian"

//又拍云
#define UPYUN_IMGURL @"http://yidian2015.b0.upaiyun.com"
#define UPYUN_BUCKET @"yidian2015"
#define UPYUN_SECRET @"cUY7LDcWu03f5/xaK0lJxHSb3oQ="

//百度接口
//城市范围内的关键字地点
#define BAIDU_PLACE(keyword, city) [NSString stringWithFormat:@"http://api.map.baidu.com/place/v2/search?q=%@&region=%@&output=json&ak=bwaWdfBatpKYvBGxOdne78Ij", keyword, city]
//经纬度转地点
#define BAIDU_GEOCODER(lat, lng) [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?location=%@,%@&output=json&ak=bwaWdfBatpKYvBGxOdne78Ij", lat, lng]
//GPS坐标转百度坐标
#define BAIDU_GEOCONV(lat, lng) [NSString stringWithFormat:@"http://api.map.baidu.com/geoconv/v1/?coords=%@,%@&ak=8dCDnV31Xg1QBbrWyrHmquR3", lng, lat]

#define PERSON [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"person"]]
#define SIGN ((PERSON.isDictionary && [PERSON[@"sign"] isset]) ? PERSON[@"sign"] : @"")

#define MAINCOLOR [UIColor colorWithRed:255/255.f green:120/255.f blue:137/255.f alpha:1.f] //ff7889
#define MAINSUBCOLOR [UIColor colorWithRed:218/255.f green:0/255.f blue:0/255.f alpha:1.f] //da0000
#define NAVBGCOLOR [UIColor colorWithRed:255/255.f green:120/255.f blue:137/255.f alpha:1.f] //ff7889
#define NAVTEXTCOLOR [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1.f] //fff
#define BACKCOLOR [UIColor colorWithRed:243/255.f green:243/255.f blue:243/255.f alpha:1.f] //f3f3f3

/*
[[IQKeyboardManager sharedManager] setEnable:NO]; //关闭智能键盘
[[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:0]; //键盘距离UITextField
[[IQKeyboardManager sharedManager] considerToolbarPreviousNextInViewClass:[UIScrollView class]]; //在UIScrollView内所有UITextField都使用Toolbar
textField.inputAccessoryView = [[UIView alloc]init]; //不使用UIToolbar

两个数字比较大小, 取平均值法
大的为 (a+b + abs(a-b)) / 2
小的为 (a+b - abs(a-b)) / 2
如果取 a/b 余数不为0, 则说明a>b
(a / b) ? a : b

链式语法
- ( Person *(^)(NSString *food) )eat{
	return ^(NSString *food){
		NSLog(@"吃饭---- %@", food);
		return self;
	};
}
p.eat(@"白菜").other2();

定义block
typedef void(^MyBlock)(NSString *text);
*/
