//
//  StringUtils.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/24/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils



+(NSString *)multiplyInteger:(NSString *)first bySingleDigitInteger: (unichar)second {
    if (second == '0') return @"0";
    NSMutableString * temp = [NSMutableString stringWithString:first];
    for (int i = 1; i < (second - '0'); ++i) {
        temp = [NSMutableString stringWithString:[self addInteger:temp toInteger:first]];
    }
    return temp;
}

+(NSString *) multiplyInteger:(NSString *)first byTwoDigitInteger:(NSString *)second {
    if (second.length == 1) return [self multiplyInteger:first bySingleDigitInteger:[second characterAtIndex:0]];
    NSString * l1 = [self multiplyInteger:first bySingleDigitInteger:[second characterAtIndex:1]];
    NSString * l2 = [NSString stringWithFormat:@"%@0",[self multiplyInteger:first bySingleDigitInteger:[second characterAtIndex:0]]];
    return [self addInteger:l1 toInteger:l2];
}

+(NSString *)powerInteger:(NSString *)base byTwoDigitIntegerExponent:(NSString *)exp {
    NSMutableString * temp = [NSMutableString stringWithString:@"1"];
    for (int i = 0; i < exp.integerValue; ++i)
    {
        temp = [NSMutableString stringWithString:[self multiplyInteger:temp byTwoDigitInteger:base]];
    }
    return temp;
}

+(BOOL)isPalindrom: (NSString *) str {
    NSUInteger right = ((str.length)-1);
    for (int left = 0; left < right; ++left, --right) {
        if ([str characterAtIndex:left] != [str characterAtIndex:right]) return NO;
    }
    return YES;
}

+(NSString *) reverseString: (NSString *) str {
    int len = (int)str.length;
    NSMutableString * temp = [[NSMutableString alloc] initWithCapacity:len];
    for (int i=len-1; i>=0; --i) {
        [temp appendFormat:@"%c", [str characterAtIndex:i]];
    }
    return temp;
}

+(NSString *)addInteger:(NSString *)first toSameLengthInteger:(NSString *)second {
    int l1 = (int)first.length;
    int l2 = (int)second.length;
    if(l1 != l2) return nil;
    NSMutableString * temp = [[NSMutableString alloc] initWithCapacity:(l1+1)];
    int sum = 0;
    int carry = 0;
    for (int i=l1-1; i>=0; --i) {
        sum = [first characterAtIndex:i] - '0' + [second characterAtIndex:i] - '0' + carry;
        if (sum >= 10 ) {
            carry = 1;
            sum -= 10;
        }
        else
        {
            carry = 0;
        }
        [temp appendFormat:@"%d", sum];
    }
    if (carry > 0) [temp appendFormat:@"%d", carry];

    return [self reverseString:temp];
}

+(NSString *)addInteger:(NSString *)first toInteger:(NSString *)second {
    int l1 = (int)first.length;
    int l2 = (int)second.length;
    NSString * temp;
    NSString * pad;
    if (l1 > l2) {
        pad = [@"" stringByPaddingToLength:(l1-l2) withString:@"0" startingAtIndex:0];
        temp = [NSString stringWithFormat:@"%@%@", pad, second];
        return [self addInteger:first toSameLengthInteger:temp];
    }
    //else
    pad = [@"" stringByPaddingToLength:(l2-l1) withString:@"0" startingAtIndex:0];
    temp = [NSString stringWithFormat:@"%@%@", pad, first];
    return [self addInteger:temp toSameLengthInteger:second];
}

+(BOOL)isLychrel:(NSString *)str forMaxIteratons:(int)m {
    NSString * temp = nil;
    for (int i = 0; i<m; ++i) {
        temp = [self addInteger:str
            toSameLengthInteger:[self reverseString:str]];
        if ([self isPalindrom:temp]) {
            return NO;
        } else {
            str = temp;
            temp = nil;
        }
    }
    return YES;
}

+(NSUInteger)sumDigits:(NSString *)numstring {
    NSUInteger sum = 0;
    for (int i=0; i < [numstring length]; ++i) {
        sum += ([numstring characterAtIndex:i] - '0');
    }
    return sum;
}

@end
