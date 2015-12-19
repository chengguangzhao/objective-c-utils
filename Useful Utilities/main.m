//
//  main.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/16/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Primes.h"
#import "MathUtils.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDate * start = [NSDate date];
        long long total = 0;
        unsigned long long upper = 5000000;
        for (unsigned long long i = 2; i <= upper; ++i) {
//            if ([MathUtils isPrime:i]) ++total;
            if ([Primes isPrime:i]) ++total;
//            if ([Primes isPrimeMixed:i]) ++total;
                //NSLog(@"%d is prime", i);
        }
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        NSLog(@"There are %lld primes under %lld", total, upper);
        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
