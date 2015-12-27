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

        long double numerators [1000];
        long double denominators [1000];
        int nl [1000];
        int dl [1000];
        nl[0] = nl[1] = dl[0] = dl[1] = 1;
        int count = 0;
        numerators[0] = 3.0;
        numerators[1] = 7.0;
        denominators[0] = 2.0;
        denominators[1] = 5.0;
        for (int i=2; i<1000; ++i) {
            denominators[i] = denominators[i-1] + numerators[i-1];
            numerators[i] = denominators[i] + denominators[i-1];
            if ( [MathUtils numDigitsLDbl:numerators[i]]> [MathUtils numDigitsLDbl:denominators[i]])
                ++count;
        }

        NSLog(@"%d number numberators longer", count);
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];

        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
