//
//  main.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/16/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Primes.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDate * start = [NSDate date];
        int numDiagonalNumbers = 1;
        int numDiagonalPrimes = 0;
        int i = 3;
        for (; ; i+=2){
            numDiagonalNumbers += 4;
            unsigned long long highestD = i * i;
            for (int j = 0; j < 4; ++j) {
                if ([Primes isPrime:highestD]) {
                    ++numDiagonalPrimes;
                }
                highestD -= (i-1);
            }
            if ((double)numDiagonalPrimes / (double)numDiagonalNumbers < 0.1) break;
        }

        NSLog(@"%d numbers on each side", i);
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
