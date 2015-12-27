//
//  StringUtils.h
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/24/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtils : NSObject

+(BOOL) isPalindrom: (NSString *) str;
+(BOOL) isLychrel: (NSString *) str forMaxIteratons: (int) m;
+(NSString *) reverseString: (NSString *) str;
+(NSString *) addInteger: (NSString *) first toSameLengthInteger: (NSString *) second;
+(NSString *) multiplyInteger: (NSString *) first bySingleDigitInteger: (unichar) second;
+(NSString *) multiplyInteger: (NSString *) first byTwoDigitInteger: (NSString *) second;
+(NSString *) addInteger:(NSString *)first toInteger:(NSString *)second;
+(NSString *) powerInteger:(NSString *)base byTwoDigitIntegerExponent:(NSString *)exp;
+(NSUInteger) sumDigits:(NSString *) numstring;

@end
