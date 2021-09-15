//
//  NSString+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSString+Extend
@interface AttributedStyleAction : NSObject
@property (readwrite,copy) void(^action)();
- (instancetype)initWithAction:(void(^)())action;
- (NSDictionary*)styledAction;
+ (NSDictionary*)action:(void(^)())action;
@end
@interface NSString (GlobalExtend)
- (id)getUserDefaults;
- (NSString*)getUserDefaultsString;
- (int)getUserDefaultsInt;
- (NSInteger)getUserDefaultsInteger;
- (CGFloat)getUserDefaultsFloat;
- (BOOL)getUserDefaultsBool;
- (NSMutableArray*)getUserDefaultsArray;
- (NSMutableDictionary*)getUserDefaultsDictionary;
- (void)setUserDefaultsWithData:(id)data;
- (void)replaceUserDefaultsWithData:(NSDictionary*)data;
- (void)deleteUserDefaults;
- (NSMutableArray*)getList:(NSDictionary*)where;
- (NSMutableDictionary*)getRow:(NSDictionary*)where;
- (NSMutableArray*)getCell:(NSMutableArray*)field where:(NSDictionary*)where;
- (NSInteger)getCount:(NSDictionary*)where;
- (void)insertUserDefaults:(NSDictionary*)data;
- (void)insertUserDefaults:(NSDictionary*)data keepRow:(NSInteger)num;
- (void)updateUserDefaults:(NSDictionary*)data where:(NSDictionary*)where;
- (void)deleteRowUserDefaults:(NSDictionary*)where;
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height;
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width;
- (NSString*)strtolower;
- (NSString*)strtoupper;
- (NSString*)strtoupperFirst;
- (NSString*)trim;
- (NSString*)trim:(NSString*)assign;
- (NSString*)trimNewline;
- (NSInteger)indexOf:(NSString*)str;
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2;
- (NSString*)substr:(NSInteger)start length:(NSInteger)length;
- (NSString*)substr:(NSInteger)start;
- (NSString*)left:(NSInteger)length;
- (NSString*)right:(NSInteger)length;
- (NSInteger)fontLength;
- (NSMutableArray*)split:(NSString*)symbol;
- (NSMutableArray*)explode:(NSString*)symbol;
- (NSMutableDictionary*)params;
- (NSMutableDictionary*)params:(NSString*)mark;
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr;
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix;
- (BOOL)preg_test:(NSString*)patton;
- (NSString*)preg_replace:(NSString*)patton with:(NSString*)templateStr;
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement;
- (NSMutableArray*)preg_match:(NSString*)patton;
- (id)formatJson;
- (BOOL)isInt;
- (BOOL)isInt:(NSInteger)length;
- (BOOL)isFloat;
- (BOOL)isFloat:(NSInteger)length;
- (BOOL)isUsername;
- (BOOL)isPassword;
- (BOOL)hasChinese;
- (BOOL)isChinese;
- (BOOL)isEmail;
- (BOOL)isMobile;
- (BOOL)isUrl;
- (BOOL)isIDCard;
- (BOOL)isEmoji;
- (NSString*)getFullFilename;
- (NSString*)getFilename;
- (NSString*)getSuffix;
- (NSString*)ASCII;
- (NSString*)Unicode;
- (NSString*)URLEncode;
- (NSString*)URLEncode:(NSStringEncoding)encoding;
- (NSString*)URLDecode;
- (NSString*)URLDecode:(NSStringEncoding)encoding;
- (NSString*)base64;
- (NSString*)base64ToString;
- (NSData*)base64ToData;
- (UIImage*)base64ToImage;
- (NSString*)md5;
- (NSString*)sha1;
- (NSAttributedString*)simpleHtml;
- (void)cacheImageAndCompletion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook;
@end
