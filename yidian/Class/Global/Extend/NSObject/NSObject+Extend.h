//
//  NSObject+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSObject+Extend
@interface NSObject (GlobalExtend)
- (NSMutableDictionary*)element;
- (void)removeElement:(NSString*)key;
- (NSString*)removeElement;
- (void)setRemoveElement:(NSString*)key;
- (BOOL)isInt;
- (BOOL)isFloat;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isDate;
- (BOOL)isset;
- (NSInteger)inArray:(NSArray*)array;
- (NSString*)inDictionary:(NSDictionary*)dictionary;
- (NSInteger)inArraySearch:(NSArray*)array;
- (id)changeType:(NSString*)className;
- (NSString*)stringValue;
- (NSNumber*)numberValue;
- (NSData*)dataValue;
- (NSDate*)dateValue;
- (NSArray*)arrayValue;
- (NSDictionary*)dictionaryValue;
- (id)jsonValue;
- (NSString*)jsonString;
- (NSDictionary*)getPropertiesAndVaules;
- (NSArray*)getProperties;
- (void)getMethods;
@end
