//
//  Common.h
//
//  Created by ajsong on 15/4/23.
//  Copyright (c) 2015年 Guangzhou Santi Trade Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (NSString*)apiUrlWithFile:(NSString*)file params:(NSDictionary*)params;

+ (NSString*)getApiWithParams:(NSDictionary*)params complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)getApiWithParams:(NSDictionary*)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithParams:(NSDictionary*)params cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithParams:(NSDictionary*)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithFile:(NSString*)file params:(NSDictionary*)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url type:(NSString*)type success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)getApiWithUrl:(NSString*)url type:(NSString*)type feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (NSString*)postAutoApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postAutoApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;

+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data type:(NSString*)type timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)uploadApiWithParams:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)uploadApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail;
+ (NSString*)uploadApiWithFile:(NSString*)file params:(NSDictionary*)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (void)successExecute:(NSDictionary*)json;
+ (void)errorExecute:(NSDictionary*)json;
+ (void)getKuaidiWithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)getKD100WithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)getICKDWithSpellName:(NSString*)spellName mailNo:(NSString*)mailNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)getAuditKey:(NSString*)key completion:(void (^)(NSDictionary *configs))completion;
+ (BOOL)isAuditKey;

@end
