//
//  NSObject+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 ajsong. All rights reserved.
//

#import "Global.h"

#pragma mark - NSObject+Extend
@implementation NSObject (GlobalExtend)
- (NSMutableDictionary*)element{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, @"element");
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(self, @"element", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}

- (void)removeElement:(NSString*)key{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, @"element");
	if (!ele) return;
	[ele removeObjectForKey:key];
	objc_setAssociatedObject(self, @"element", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)removeElement{
	return nil;
}
- (void)setRemoveElement:(NSString*)key{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, @"element");
	if (!ele) return;
	if (!ele.count) return;
	if (!ele[key]) return;
	[self removeElement:key];
}

//是否为整型
- (BOOL)isInt{
	NSString *string = [NSString stringWithFormat:@"%@", self];
	NSScanner *scan = [NSScanner scannerWithString:string];
	int val;
	return [scan scanInt:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
	NSString *string = [NSString stringWithFormat:@"%@", self];
	NSScanner *scan = [NSScanner scannerWithString:string];
	float val;
	return [scan scanFloat:&val] && [scan isAtEnd];
}

//判断是否数组
- (BOOL)isArray{
	if (![self isset]) return NO;
	if ([self isKindOfClass:[NSArray class]]) return [((NSArray*)self) count]>0;
	return NO;
}

//判断是否字典
- (BOOL)isDictionary{
	if (![self isset]) return NO;
	if ([self isKindOfClass:[NSDictionary class]]) return [((NSDictionary*)self) count]>0;
	return NO;
}

//是否为日期字符串
- (BOOL)isDate{
	if ([self isKindOfClass:[NSDate class]]) return YES;
	if ([self isKindOfClass:[NSString class]]) {
		NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"\\d{4}-\\d{1,2}-\\d{1,2}( \\d{1,2}:\\d{1,2}:\\d{1,2})?"];
		return [match evaluateWithObject:((NSString*)self)];
	}
	return NO;
}

//判断对象是否有内容
- (BOOL)isset{
	if (!self || self == nil || [self isKindOfClass:[NSNull class]]) return NO;
	if ([self isKindOfClass:[NSString class]]) {
		return [(NSString*)self length]>0;
	} else if ([self isKindOfClass:[NSData class]]) {
		return [(NSData*)self length]>0;
	} else if ([self isKindOfClass:[NSArray class]]) {
		return [((NSArray*)self) count]>0;
	} else if ([self isKindOfClass:[NSDictionary class]]) {
		return [((NSDictionary*)self) count]>0;
	}
	return YES;
}

//判断数组是否包含, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArray:(NSArray*)array{
	NSInteger index = NSNotFound;
	if (!array.isArray) return index;
	NSString *own = self.jsonString;
	for (int i=0; i<array.count; i++) {
		NSString *item = [array[i] jsonString];
		if ([own isEqualToString:item]) {
			index = i;
			break;
		}
	}
	return index;
}

//判断字典是否包含, 包含即返回所在key, 否则返回空字符
- (NSString*)inDictionary:(NSDictionary*)dictionary{
	NSString *keyName = @"";
	if (!dictionary.isDictionary) return keyName;
	NSString *own = self.jsonString;
	for (NSString *key in dictionary) {
		NSString *item = [dictionary[key] jsonString];
		if ([own isEqualToString:item]) {
			keyName = key;
			break;
		}
	}
	return keyName;
}

//判断数组是否包含元素, 使用模糊查找, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArraySearch:(NSArray*)array{
	NSInteger index = NSNotFound;
	if (!array.isArray) return index;
	NSString *own = self.jsonString.lowercaseString;
	for (int i=0; i<array.count; i++) {
		NSString *item = [[array[i] jsonString] lowercaseString];
		if ([item indexOf:own]!=NSNotFound) {
			index = i;
			break;
		}
	}
	return index;
}

//强制转换类型
- (id)changeType:(NSString*)className{
	id obj = nil;
	if (className.length) {
		Class cls = NSClassFromString(className);
		if (cls) {
			if ([self isKindOfClass:cls]) obj = self;
		}
	}
	return obj;
}
- (NSString*)stringValue{
	return (NSString*)[self changeType:@"NSString"];
}
- (NSNumber*)numberValue{
	return (NSNumber*)[self changeType:@"NSNumber"];
}
- (NSData*)dataValue{
	return (NSData*)[self changeType:@"NSData"];
}
- (NSDate*)dateValue{
	return (NSDate*)[self changeType:@"NSDate"];
}
- (NSArray*)arrayValue{
	return (NSArray*)[self changeType:@"NSArray"];
}
- (NSDictionary*)dictionaryValue{
	return (NSDictionary*)[self changeType:@"NSDictionary"];
}

//Json字符串转Dictionary、Array
- (id)jsonValue{
	return [((NSString*)self) formatJson];
}

//Dictionary、Array转Json字符串
- (NSString*)jsonString{
	if (self == nil) return @"";
	if (![self isKindOfClass:[NSArray class]] && ![self isKindOfClass:[NSDictionary class]]) return [NSString stringWithFormat:@"%@", self];
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
	if (!jsonData || error!=nil) {
		NSLog(@"%@",error);
		return @"";
	} else {
		NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
		str = [str preg_replace:@"\\s*:\\s*null" with:@":\"\""];
		str = [str preg_replace:@"\\s*:\\s*\\[\\]" with:@":\"\""];
		str = [str preg_replace:@"\\s*:\\s*\\{\\}" with:@":\"\""];
		return str;
	}
}

//获取对象的所有属性和属性内容
- (NSDictionary*)getPropertiesAndVaules{
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([self class], &outCount);
	for (i=0; i<outCount; i++) {
		objc_property_t property = properties[i];
		const char *char_f = property_getName(property);
		NSString *propertyName = [NSString stringWithUTF8String:char_f];
		id propertyValue = [self valueForKey:(NSString *)propertyName];
		if (propertyValue) [props setObject:propertyValue forKey:propertyName];
	}
	free(properties);
	return props;
}
//获取对象的所有属性
- (NSArray*)getProperties{
	u_int count;
	objc_property_t *properties  =class_copyPropertyList([self class], &count);
	NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
	for (int i=0; i<count ; i++) {
		const char *propertyName =property_getName(properties[i]);
		[propertiesArray addObject:[NSString stringWithUTF8String:propertyName]];
	}
	free(properties);
	return propertiesArray;
}
//获取对象的所有方法
- (void)getMethods{
	unsigned int mothCout_f =0;
	Method* mothList_f = class_copyMethodList([self class], &mothCout_f);
	for (int i=0;i<mothCout_f;i++) {
		Method temp_f = mothList_f[i];
		IMP imp_f = method_getImplementation(temp_f);
		SEL name_f = method_getName(temp_f);
		const char *name_s = sel_getName(method_getName(temp_f));
		int arguments = method_getNumberOfArguments(temp_f);
		const char *encoding =method_getTypeEncoding(temp_f);
		NSLog(@"方法名:%@, 参数个数:%d, 编码方式:%@",
			  [NSString stringWithUTF8String:name_s],
			  arguments,
			  [NSString stringWithUTF8String:encoding]);
	}
	free(mothList_f);
}
@end
