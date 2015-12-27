//
//  main.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/16/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtils.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDate * start = [NSDate date];
        NSUInteger maxsum = 0;
        
//        NSString * s1 = @"99";
//        NSString * s2 = @"99";
//        NSString * s3 = @"196";
//        
//        NSLog(@"%@ ^ %@ = %@", s1, s2, [StringUtils powerInteger:s1 byTwoDigitIntegerExponent:s2]);
//        NSLog (@"%@ %s a Lychrel number", s3, [StringUtils isLychrel:s3 forMaxIteratons:50]?"is":"is not");
        for (int base = 1; base <100; ++base) {
            for (int exp = 1; exp < 100; ++exp) {
                NSUInteger sum = [StringUtils sumDigits:[StringUtils powerInteger:@(base).description byTwoDigitIntegerExponent:@(exp).description]];
                if (sum > maxsum) {
                    maxsum=sum;
                }
            }
        }
        NSLog(@"The biggest sum is %lu", (unsigned long)maxsum);
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];

        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
