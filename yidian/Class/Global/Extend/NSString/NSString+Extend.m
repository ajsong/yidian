//
//  NSString+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "Global.h"
#import "CommonCrypto/CommonDigest.h"
#import <CoreText/CoreText.h>

#pragma mark - NSString+Extend
@interface NSMutableString (TagReplace)
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array;
@end
@implementation NSMutableString (TagReplace)
- (BOOL)replaceFirstTagItoArray:(NSMutableArray*)array{
	NSRange openTagRange = [self rangeOfString:@"<"];
	if (openTagRange.length == 0) return NO;
	NSRange closeTagRange = [self rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(openTagRange.location+openTagRange.length, self.length - (openTagRange.location+openTagRange.length))];
	if (closeTagRange.length == 0) return NO;
	NSRange range = NSMakeRange(openTagRange.location, closeTagRange.location-openTagRange.location+1);
	NSString *tag = [self substringWithRange:range];
	[self replaceCharactersInRange:range withString:@""];
	BOOL isEndTag = [tag rangeOfString:@"</"].length == 2;
	if (isEndTag) {
		NSString *openTag = [tag stringByReplacingOccurrencesOfString:@"</" withString:@"<"];
		NSInteger count = array.count;
		for (NSInteger i=count-1; i>=0; i--) {
			NSDictionary *dict = array[i];
			NSString* dtag = dict[@"tag"];
			if ([dtag isEqualToString:openTag]) {
				NSNumber *loc = dict[@"loc"];
				if ([loc integerValue] < range.location) {
					[array removeObjectAtIndex:i];
					NSString *strippedTag = [openTag substringWithRange:NSMakeRange(1, openTag.length-2)];
					[array addObject:@{@"loc":loc, @"tag":strippedTag, @"endloc":@(range.location)}];
				}
				break;
			}
		}
	} else {
		[array addObject:@{@"loc":@(range.location), @"tag":tag}];
	}
	return YES;
}
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array{
	while ([self replaceFirstTagItoArray:array]) {}
}
@end
@implementation AttributedStyleAction
- (instancetype)initWithAction:(void(^)())action{
	self = [super init];
	if (self) {
		self.action = action;
	}
	return self;
}
- (NSDictionary*)styledAction{
	return @{@"AttributedStyleAction":self};
}
+ (NSDictionary*)action:(void(^)())action{
	AttributedStyleAction *styledAction = [[AttributedStyleAction alloc]initWithAction:action];
	return [styledAction styledAction];
}
@end

@implementation NSString (GlobalExtend)

//获取本地储存
- (id)getUserDefaults{
	return [[NSUserDefaults standardUserDefaults] valueForKey:self];
}
- (NSString*)getUserDefaultsString{
	return [[NSUserDefaults standardUserDefaults] stringForKey:self];
}
- (int)getUserDefaultsInt{
	id data = [self getUserDefaults];
	if (![data isInt]) return 0;
	return [data intValue];
}
- (NSInteger)getUserDefaultsInteger{
	return [[NSUserDefaults standardUserDefaults] integerForKey:self];
}
- (CGFloat)getUserDefaultsFloat{
	return [[NSUserDefaults standardUserDefaults] floatForKey:self];
}
- (BOOL)getUserDefaultsBool{
	return [[NSUserDefaults standardUserDefaults] boolForKey:self];
}
- (NSMutableArray*)getUserDefaultsArray{
	NSArray *data = [[NSUserDefaults standardUserDefaults] arrayForKey:self];
	if (data.isArray) {
		return [NSMutableArray arrayWithArray:data];
	} else {
		return [[NSMutableArray alloc]init];
	}
}
- (NSMutableDictionary*)getUserDefaultsDictionary{
	NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:self];
	if (data.isDictionary) {
		return [NSMutableDictionary dictionaryWithDictionary:data];
	} else {
		return [[NSMutableDictionary alloc]init];
	}
}

//保存到本地储存
- (void)setUserDefaultsWithData:(id)data{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:self];
	[userDefaults setObject:data forKey:self];
	[userDefaults synchronize];
}

//替换本地储存某些key的值
- (void)replaceUserDefaultsWithData:(NSDictionary*)data{
	NSMutableDictionary *dict = [self getUserDefaultsDictionary];
	if (!dict) dict = [[NSMutableDictionary alloc]init];
	for (NSString *key in data) {
		[dict setObject:data[key] forKey:key];
	}
	[self setUserDefaultsWithData:dict];
}

//删除本地储存
- (void)deleteUserDefaults{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:self];
	[userDefaults synchronize];
}

//模拟数据库操作
- (NSMutableArray*)getList:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	return [arr getList:where];
}

- (NSMutableDictionary*)getRow:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	return [arr getRow:where];
}

- (NSMutableArray*)getCell:(NSMutableArray*)field where:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	return [arr getCell:field where:where];
}

- (NSInteger)getCount:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	return [arr getCount:where];
}

- (void)insertUserDefaults:(NSDictionary*)data{
	[self insertUserDefaults:data keepRow:0];
}
- (void)insertUserDefaults:(NSDictionary*)data keepRow:(NSInteger)num{
	NSMutableArray *arr = [self getUserDefaultsArray];
	[arr insertUserDefaults:self data:data keepRow:num];
}

- (void)updateUserDefaults:(NSDictionary*)data where:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	[arr updateUserDefaults:self data:data where:where];
}

- (void)deleteRowUserDefaults:(NSDictionary*)where{
	NSMutableArray *arr = [self getUserDefaultsArray];
	[arr deleteRowUserDefaults:self where:where];
}

//自动宽度
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height{
	NSDictionary *attributes = @{NSFontAttributeName:font};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
	CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:options attributes:attributes context:NULL];
	return CGSizeMake(rect.size.width, rect.size.height);
	//NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	//[paragraphStyle setLineBreakMode:NSLineBreakByClipping];
	//[paragraphStyle setAlignment:NSTextAlignmentCenter];
	//NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle };
	//[str drawInRect:CGRectMake(0, 0, MAXFLOAT, height) withAttributes:attributes];
}

//自动高度
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width{
	NSDictionary *attributes = @{NSFontAttributeName:font};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
	CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:options attributes:attributes context:NULL];
	return CGSizeMake(rect.size.width, rect.size.height);
}

//全小写
- (NSString*)strtolower{
	return [self lowercaseString];
}

//全大写
- (NSString*)strtoupper{
	return [self uppercaseString];
}

//各单词首字母大写
- (NSString*)strtoupperFirst{
	return [self capitalizedString];
}

//清除首尾空格和换行
- (NSString*)trim{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//清除首尾指定字符串
- (NSString*)trim:(NSString*)assign{
	return [self preg_replace:[NSString stringWithFormat:@"^(%@)*|(%@)*$", assign, assign] with:@""];
}

//清除换行
- (NSString*)trimNewline{
	NSString *str = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return str;
}

//一个字符串搜索另一个字符串
- (NSInteger)indexOf:(NSString*)str{
	if (self.length<=0) return NSNotFound;
	NSRange range = [self rangeOfString:str];
	NSInteger location = range.location;
	NSInteger length = range.length;
	if (length>0) {
		return location;
	} else {
		return NSNotFound;
	}
}

//替换字符串
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2{
	if (self.length<=0) return @"";
	return [self stringByReplacingOccurrencesOfString:r1 withString:r2];
}

//截取字符串
- (NSString*)substr:(NSInteger)start length:(NSInteger)length{
	if (self.length<start || self.length-start<length) return self;
	return [self substringWithRange:NSMakeRange(start,length)];
}

//截取字符串,从指定位置开始到最后,负数:从字符串结尾的指定位置开始
- (NSString*)substr:(NSInteger)start{
	if (start<0) {
		start = self.length + start;
		if (start<0) start = 0;
	}
	if (self.length<start) return self;
	return [self substringFromIndex:start];
}

//从左边开始截取字符串
- (NSString*)left:(NSInteger)length{
	if (self.length<length) return self;
	return [self substringToIndex:length];
}

//从右边开始截取字符串
- (NSString*)right:(NSInteger)length{
	if (self.length<length) return self;
	NSUInteger len = self.length;
	NSUInteger start = 0;
	if (len>length) start = len - length;
	return [self substringFromIndex:start];
}

//获取中英文混编的字符串长度
- (NSInteger)fontLength{
	if (self.length<=0) return 0;
	NSInteger p = 0;
	for (int i=0; i<self.length; i++) {
		NSRange range = NSMakeRange(i, 1);
		NSString *subString = [self substringWithRange:range];
		const char *cString = [subString UTF8String];
		if (strlen(cString) == 3) {
			p += 2;
		} else {
			p++;
		}
	}
	return p;
}

//分割字符串转为数组
- (NSMutableArray*)split:(NSString*)symbol{
	return [self explode:symbol];
}
- (NSMutableArray*)explode:(NSString*)symbol{
	NSArray *array = [self componentsSeparatedByString:symbol];
	return [NSMutableArray arrayWithArray:array];
}

//网址参数转字典
- (NSMutableDictionary*)params{
	return [self params:@"?"];
}
- (NSMutableDictionary*)params:(NSString*)mark{
	NSArray *parts = [self split:mark];
	if (parts.count<2) return nil;
	parts = [parts.lastObject split:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	for (int i=0; i<parts.count; i++) {
		NSArray *kv = [parts[i] split:@"="];
		[params setObject:[[kv[1] URLDecode] replace:@"+" to:@" "] forKey:kv[0]];
	}
	return params;
}

//截取所需字符串
//cropHtml(HTML代码, 所需代码前面的特征代码[会被去除], 所需代码末尾的特征代码[会被去除])
//得到代码后请自行使用str_replace所需代码部分中不需要的代码
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr{
	NSString *webHtml = self;
	if(webHtml.length>0){
		if(startStr.length>0 && [webHtml indexOf:startStr]!=NSNotFound){
			NSArray *array = [webHtml split:startStr];
			webHtml = array[1];
		}
		if(overStr.length>0 && [webHtml indexOf:overStr]!=NSNotFound){
			NSArray *array = [webHtml split:overStr];
			webHtml = array[0];
		}
	}
	return webHtml;
}

//删除例如 [xxxx] 组合的字符串段落
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix{
	NSString *str = nil;
	NSInteger length = self.length;
	if (length > 0) {
		if ([suffix isEqualToString:[self substringFromIndex:length-suffix.length]]) {
			if ([self rangeOfString:prefix].location == NSNotFound){
				str = [self substringToIndex:length-prefix.length];
			} else {
				str = [self substringToIndex:[self rangeOfString:prefix options:NSBackwardsSearch].location];
			}
		} else {
			for (int i=1; i<=2; i++) {
				if (length>i) {
					if ([[self substringFromIndex:length-i] isEmoji]) {
						return [self substringToIndex:length-i];
						break;
					}
				}
			}
			str = [self substringToIndex:length-1];
		}
	}
	return str;
}

//正则表达式test
- (BOOL)preg_test:(NSString*)patton{
	if (self.length<=0) return NO;
	NSArray *matcher = [self preg_match:patton];
	return matcher.isArray;
	//NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patton];
	//return [match evaluateWithObject:self];
}

//正则表达式replace
- (NSString*)preg_replace:(NSString*)patton with:(NSString*)templateStr{
	if (self.length<=0) return @"";
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];
	NSString *modified = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:templateStr];
	return modified;
}

//正则表达式replace, 根据replacement返回字符串来替换
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement{
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length || !replacement) return self;
	NSString *modified = self;
	NSArray *matches = [self preg_match:patton];
	if (matches.count) {
		for (NSInteger i=0; i<matches.count; i++) {
			NSDictionary *matcher = matches[i];
			NSInteger loc = [modified indexOf:matcher[@"value"]];
			NSInteger len = [matcher[@"value"] length];
			modified = [modified stringByReplacingCharactersInRange:NSMakeRange(loc, len) withString:replacement(matcher, i)];
		}
	}
	return modified;
}

//正则表达式match
- (NSMutableArray*)preg_match:(NSString*)patton{
	NSMutableArray *matcher = [[NSMutableArray alloc]init];
	if (!self.length) return matcher;
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
																		   options:NSRegularExpressionCaseInsensitive
																			 error:&error];
	if (error) {
		NSLog(@"%@", error);
		return matcher;
	}
	NSArray *matches = [regex matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
	//NSLog(@"%@", matches);
	for (NSTextCheckingResult *match in matches) {
		NSMutableArray *t = [[NSMutableArray alloc]init];
		for (NSInteger i=1; i<=match.numberOfRanges-1; i++) {
			if ([match rangeAtIndex:i].length) {
				[t addObject:[self substringWithRange:[match rangeAtIndex:i]]];
			} else {
				[t addObject:@""];
			}
		}
		NSString *value = [self substringWithRange:match.range];
		NSDictionary *m = @{@"value":value, @"group":t};
		[matcher addObject:m];
	}
	return matcher;
}

//Json字符串转Dictionary、Array
- (id)formatJson{
	if (!self.length) return [[NSMutableDictionary alloc]init];
	NSString *json = self;
	json = [self replace:@":null" to:@":\"\""];
	json = [json replace:@":[]" to:@":\"\""];
	json = [json replace:@":{}" to:@":\"\""];
	NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

//是否为整型
- (BOOL)isInt{
	return [self isInt:self.length];
}
- (BOOL)isInt:(NSInteger)length{
	NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
	int val;
	return [scan scanInt:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
	return [self isFloat:self.length];
}
- (BOOL)isFloat:(NSInteger)length{
	NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
	float val;
	return [scan scanFloat:&val] && [scan isAtEnd];
}

//用户名
- (BOOL)isUsername{
	NSString *re = @"^[A-Za-z0-9]{6,20}+$";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}


//密码
- (BOOL)isPassword{
	NSString *re = @"^[a-zA-Z0-9]{6,20}+$";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}

//是否存在中文字
- (BOOL)hasChinese{
	BOOL has = NO;
	NSInteger length = self.length;
	for (NSInteger i=0; i<length; i++) {
		NSRange range = NSMakeRange(i, 1);
		NSString *subString = [self substringWithRange:range];
		const char *string = [subString UTF8String];
		if (strlen(string) == 3) {
			has = YES;
			break;
		}
	}
	return has;
}

//全中文
- (BOOL)isChinese{
	NSString *re = @"^[\u4e00-\u9fa5]+$";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}

//邮箱
- (BOOL)isEmail{
	NSString *re = @"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}

//手机号码
- (BOOL)isMobile{
	NSString *re = @"^1[3-8]+\\d{9}$";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}

//网址
- (BOOL)isUrl{
	NSString *re = @"^(http|https|ftp):(\\/\\/|\\\\)(([\\w\\/\\\\+\\-~`@:%])+\\.)+([\\w\\/\\\\.=\\?\\+\\-~`@\\':!%#]|(&amp;)|&)+";
	NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
	return [match evaluateWithObject:self];
}

//身份证
- (BOOL)isIDCard{
	NSInteger length = self.length;
	if (length!=15 && length!=18) return NO;
	NSArray *codeArray = @[@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2"];
	NSDictionary *checkCodeDic = [NSDictionary dictionaryWithObjects:@[@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2"]
															 forKeys:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
	int sumValue = 0;
	if (length==18) {
		if (![self isInt:17]) return NO;
		for (int i=0; i<17; i++) {
			sumValue += [[self substringWithRange:NSMakeRange(i, 1)]intValue] * [[codeArray objectAtIndex:i]intValue];
		}
		NSString *strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d", sumValue%11]];
		if ([strlast isEqualToString:[[self substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) return YES;
	} else {
		if (![self isInt:15]) return NO;
		NSRegularExpression *regularExpression;
		int year = [self substringWithRange:NSMakeRange(6,2)].intValue + 1900;
		if (year%4==0 || (year%100==0 && year%4==0)) {
			regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
																	options:NSRegularExpressionCaseInsensitive
																	  error:nil];
		} else {
			regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
																	options:NSRegularExpressionCaseInsensitive
																	  error:nil];
		}
		sumValue = (int)[regularExpression numberOfMatchesInString:self
														   options:NSMatchingReportProgress
															 range:NSMakeRange(0, length)];
		if (sumValue > 0) return YES;
	}
	return NO;
}

//是否Emoji表情
- (BOOL)isEmoji{
	__block BOOL returnValue = NO;
	[self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		const unichar hs = [substring characterAtIndex:0];
		if (0xd800 <= hs && hs <= 0xdbff) {
			if (substring.length > 1) {
				const unichar ls = [substring characterAtIndex:1];
				const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
				if (0x1d000 <= uc && uc <= 0x1f77f) {
					returnValue = YES;
				}
			}
		} else if (substring.length > 1) {
			const unichar ls = [substring characterAtIndex:1];
			if (ls == 0x20e3) {
				returnValue = YES;
			}
		} else {
			if (0x2100 <= hs && hs <= 0x27ff) {
				returnValue = YES;
			} else if (0x2B05 <= hs && hs <= 0x2b07) {
				returnValue = YES;
			} else if (0x2934 <= hs && hs <= 0x2935) {
				returnValue = YES;
			} else if (0x3297 <= hs && hs <= 0x3299) {
				returnValue = YES;
			} else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
				returnValue = YES;
			}
		}
	}];
	return returnValue;
}

//获取完整文件名(带后缀名)(支持网址)
- (NSString*)getFullFilename{
	return [self lastPathComponent];
}

//获取文件名(不带后缀名)
- (NSString*)getFilename{
	return [self stringByDeletingPathExtension];
}

//获取后缀名
- (NSString*)getSuffix{
	return [self pathExtension];
}

- (NSString*)ASCII{
	NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	return str;
}

- (NSString*)Unicode{
	NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding];
	return str;
}

//URL编码
- (NSString*)URLEncode{
	return [self URLEncode:NSUTF8StringEncoding];
}

//URL编码,可设置字符编码
- (NSString*)URLEncode:(NSStringEncoding)encoding{
	NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+", @"$", @",", @"!", @"'", @"(", @")", @"*", nil];
	NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
							 @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C",
							 @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
	NSInteger len = [escapeChars count];
	NSMutableString *temp = [[self
							  stringByAddingPercentEscapesUsingEncoding:encoding]
							 mutableCopy];
	int i;
	for (i=0; i<len; i++) {
		[temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
	}
	NSString *outStr = [NSString stringWithString:temp];
	return outStr;
}

//URL解码
- (NSString*)URLDecode{
	return [self URLDecode:NSUTF8StringEncoding];
}

//URL解码,可设置字符编码
- (NSString*)URLDecode:(NSStringEncoding)encoding{
	return [self stringByReplacingPercentEscapesUsingEncoding:encoding];
}

//转Base64
- (NSString*)base64{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [Global dataToBase64:data];
}

//Base64转NSString
- (NSString*)base64ToString{
	NSData *data = [self base64ToData];
	return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

//Base64转NSData
- (NSData*)base64ToData{
	if (self == nil) [NSException raise:NSInvalidArgumentException format:@""];
	if (self.length == 0) return [NSData data];
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	static char *decodingTable = NULL;
	if (decodingTable == NULL) {
		decodingTable = malloc(256);
		if (decodingTable == NULL) return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++) decodingTable[(short)encodingTable[i]] = i;
	}
	const char *characters = [self cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL) return nil; //Not an ASCII string!
	char *bytes = malloc(((self.length + 3) / 4) * 3);
	if (bytes == NULL) return nil;
	NSUInteger length = 0;
	NSUInteger i = 0;
	while (YES) {
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++) {
			if (characters[i] == '\0') break;
			if (isspace(characters[i]) || characters[i] == '=') continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX) { //Illegal character!
				free(bytes);
				return nil;
			}
		}
		if (bufferLength == 0) break;
		if (bufferLength == 1) { //At least two characters are needed to produce one byte!
			free(bytes);
			return nil;
		}
		//Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2) bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3) bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

//Base64转UIImage
- (UIImage*)base64ToImage{
	NSURL *url = [NSURL URLWithString:self];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *image = [UIImage imageWithData:data];
	return image;
}

//转MD5, 16位:CC_MD5_DIGEST_LENGTH, 64位:CC_MD5_BLOCK_BYTES
- (NSString*)md5{
	const char *cStr = [self UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
	for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", digest[i]];
	return output;
}

//转SHA1, 20位:CC_SHA1_DIGEST_LENGTH, 64位:CC_SHA1_BLOCK_BYTES
- (NSString*)sha1{
	NSInteger length = CC_SHA1_BLOCK_BYTES;
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:self.length];
	uint8_t digest[length];
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	NSMutableString* output = [NSMutableString stringWithCapacity:length * 2];
	for (int i = 0; i < length; i++) [output appendFormat:@"%02x", digest[i]];
	return output;
}

//转化简单HTML代码为iOS文本
- (NSAttributedString*)simpleHtml{
	NSAttributedString *html = [[NSAttributedString alloc] initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
	return html;
}

//缓存网络图片
- (void)cacheImageAndCompletion:(void (^)(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[Global cacheImageWithUrl:self completion:completion];
}

//使用标签自定义UILabel字体
//www.itnose.net/detail/6177538.html
/*
 NSString *string = [NSString stringWithFormat:@"<e>￥</e><bp>%.1f</bp>", [dic[@"price"]floatValue]];
 NSDictionary *style = @{@"body":@[FONT(12),COLORRGB(@"c0c0c0")], @"e":FONTBOLD(10), @"bp":FONT(16)};
 price.attributedText = [string attributedStringWithStyleDictionary:style];
 */
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook{
	NSMutableArray *tags = [[NSMutableArray alloc]init];
	NSMutableString *ms = [self mutableCopy];
	[ms replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceAllTagsIntoArray:tags];
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:ms];
	NSObject *bodyStyle = styleBook[@"body"];
	if (bodyStyle) [self styleAttributedString:as range:NSMakeRange(0, as.length) withStyle:bodyStyle withStyleBook:styleBook];
	for (NSDictionary *tag in tags) {
		if (tag[@"loc"]!=nil && tag[@"endloc"]!=nil) {
			NSString *t = tag[@"tag"];
			NSNumber *loc = tag[@"loc"];
			NSNumber *endloc = tag[@"endloc"];
			NSRange range = NSMakeRange([loc integerValue], [endloc integerValue] - [loc integerValue]);
			NSObject *style = styleBook[t];
			if (style) {
				//*//
				if ([t isEqualToString:@"b"]) { //字体宽度,正值中空,负值填充
					[as removeAttribute:NSStrokeWidthAttributeName range:range];
					[as addAttribute:NSStrokeWidthAttributeName value:style range:range];
				} else if ([t isEqualToString:@"u"]) { //下划线,值越大线条越粗
					[as removeAttribute:NSUnderlineStyleAttributeName range:range];
					[as addAttribute:NSUnderlineStyleAttributeName value:style range:range];
				} else if ([t isEqualToString:@"i"]) { //字形倾斜度,正值右倾,负值左倾
					[as removeAttribute:NSObliquenessAttributeName range:range];
					[as addAttribute:NSObliquenessAttributeName value:style range:range];
				} else if ([t isEqualToString:@"s"]) { //中划线,值越大线条越粗
					[as removeAttribute:NSStrikethroughStyleAttributeName range:range];
					[as addAttribute:NSStrikethroughStyleAttributeName value:style range:range];
				} else if ([t isEqualToString:@"line-height"]) { //中划线,值越大线条越粗
					NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
					[paragraphStyle setLineSpacing:[(NSNumber*)style floatValue]];
					[as removeAttribute:NSParagraphStyleAttributeName range:range];
					[as addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
				} else if ([t isEqualToString:@"margin-bottom"]) { //文字位置偏移,正值上偏,负值下偏
					[as removeAttribute:NSBaselineOffsetAttributeName range:range];
					[as addAttribute:NSBaselineOffsetAttributeName value:style range:range];
				} else if ([t isEqualToString:@"letter-spacing"]) { //字体间隔,值越大间隔越大
					[as removeAttribute:NSKernAttributeName range:range];
					[as addAttribute:NSKernAttributeName value:style range:range];
				} else if ([t isEqualToString:@"style"]) { //字体样式,值为NSMutableParagraphStyle
					[as removeAttribute:NSParagraphStyleAttributeName range:range];
					[as addAttribute:NSParagraphStyleAttributeName value:style range:range];
				}
				//*/
				//自定义标签
				[self styleAttributedString:as range:range withStyle:style withStyleBook:styleBook];
			}
		}
	}
	return as;
}
- (void)styleAttributedString:(NSMutableAttributedString*)as range:(NSRange)range withStyle:(NSObject*)style withStyleBook:(NSDictionary*)styleBook{
	if ([style isKindOfClass:[NSArray class]]) {
		for (NSObject *subStyle in (NSArray*)style) {
			[self styleAttributedString:as range:range withStyle:subStyle withStyleBook:styleBook];
		}
	} else if ([style isKindOfClass:[NSString class]]) {
		[self styleAttributedString:as range:range withStyle:styleBook[(NSString*)style] withStyleBook:styleBook];
	} else if ([style isKindOfClass:[NSDictionary class]]) {
		[as setAttributes:(NSDictionary*)style range:range];
	} else if ([style isKindOfClass:[UIFont class]]) {
		UIFont *font = (UIFont*)style;
		CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
		if (aFont) {
			[as removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range];
			[as addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
			CFRelease(aFont);
		}
	} else if ([style isKindOfClass:[UIColor class]]) {
		[as removeAttribute:NSForegroundColorAttributeName range:range];
		[as addAttribute:NSForegroundColorAttributeName value:(UIColor*)style range:range];
	} else if ([style isKindOfClass:[NSURL class]]) {
		[as removeAttribute:NSLinkAttributeName range:range];
		[as addAttribute:NSLinkAttributeName value:(NSURL*)style range:range];
	} else if ([style isKindOfClass:[UIImage class]]) {
		UIImage *image = (UIImage*)style;
		NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
		attachment.image = image;
		//CGSize s = [self sizeWithAttributes:@{NSFontAttributeName:_textFont}];
		//attachment.bounds = CGRectMake(0, (s.height-image.size.height)/2-(_textFont.lineHeight*0.1), image.size.width, image.size.height);
		[as replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	}
}

@end
