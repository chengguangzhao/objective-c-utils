//
//  MathUtils.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/17/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import "MathUtils.h"


@implementation MathUtils

+(BOOL)isPrime:(unsigned long long)num {
    if ((num & 1)==0) return (num == 2);
    if (num % 3 == 0) return (num == 3);
    double lim = sqrt(num);
    for (int i = 5; i <= lim; i += 6) 
        if (num % i == 0 || num % (i + 2) == 0) return NO;
    
    return YES;
}

@end
