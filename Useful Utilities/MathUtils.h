//
//  MathUtils.h
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/17/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

@interface MathUtils : NSObject

+(BOOL) isPrime: (unsigned long long) num;
+(BOOL) isAbundant: (NSUInteger) num;
+(BOOL) isPandigitalInteger: (NSUInteger) num;
+(BOOL) isPandigitalString: (NSString*) str;
+(NSMutableArray *) properDivisors: (NSUInteger) num;
+(int) numDigitsUInt: (unsigned int) n;
+(int) numDigitsULong: (unsigned long) n;
+(int) numDigitsLDbl: (long double) ld;
+(NSNumber *) wrapInt: (int) n;
+(NSNumber *) wrapLong: (long) n;

@end
