//
//  main.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/16/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathUtils.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDate * start = [NSDate date];
        int count = 0;
        long long upper = 10000000;
        for (int i=2; i < upper; ++i) {
            if ([MathUtils isPrime:i])
                ++count;
                //NSLog(@"%d is prime", i);
        }
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        NSLog(@"There are %d primes under %lld", count, upper);
        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
