//
//  MathUtils.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/17/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import "MathUtils.h"


@implementation MathUtils

+(int)numDigitsUInt:(unsigned int) n {
    return n<100000?n<100?n<10?1:2:n<1000?3:n<10000?4:5:n<10000000?n<1000000?6:7:n<100000000?8:n<1000000000?9:10;
}

+(int)numDigitsULong:(unsigned long)n {
    if (n < 10000000000) { // <= 10 digits
        return n<100000?n<100?n<10?1:2:n<1000?3:n<10000?4:5:n<10000000?n<1000000?6:7:n<100000000?8:n<1000000000?9:10;
    } else { // > 10 digits
        if (n < 100000000000ull)
            return 11;
        if (n < 1000000000000ull)
            return 12;
        if (n < 10000000000000ull)
            return 13;
        if (n < 100000000000000ull)
            return 14;
        if (n < 1000000000000000ull)
            return 15;
        if (n < 10000000000000000ull)
            return 16;
        if (n < 100000000000000000ull)
            return 17;
        if (n < 1000000000000000000ull)
            return 18;
        if (n < 10000000000000000000ull)
            return 19;
        return 20;
    }
}

+(int)numDigitsLDbl:(long double) ld {
    if (ld<0) ld = -ld;
    if (ld==0) return 1;
    return log10l(ld);
}

+(NSNumber *)wrapInt:(int)n {
    return @(n);
}

+(NSNumber *)wrapLong:(long)n {
    return @(n);
}

+(BOOL)isPrime:(unsigned long long)num {
    if ((num & 1)==0) return (num == 2);
    if (num % 3 == 0) return (num == 3);
    double lim = sqrt(num);
    for (int i = 5; i <= lim; i += 6) 
        if (num % i == 0 || num % (i + 2) == 0) return NO;
    
    return YES;
}

+(NSMutableArray *)properDivisors:(NSUInteger)num {
    NSMutableArray * arr = [[NSMutableArray alloc] initWithObjects:@1, nil];
    float upper = num / 2.0;
    for (int i = 2; i <= upper; ++i)
        if (num % i == 0) {
            NSNumber * iWrapped = [NSNumber numberWithInt:i];
            [arr addObject:iWrapped];
        }
    return arr;
}

+(BOOL)isAbundant:(NSUInteger)num {
    NSMutableArray * divisors = [self properDivisors:num];
    NSUInteger sum = 0;
    for (NSNumber * n in divisors) {
        sum += [n intValue];
    }
    if (sum > num) return YES;
    return NO;
}

+(BOOL)isPandigitalInteger:(NSUInteger)num {
    return [self isPandigitalString:[NSString stringWithFormat:@"%lu", (unsigned long)num]];
}

+(BOOL)isPandigitalString:(NSString *)str {
    if ([str length] != 9) {
        return NO;
    }
    BOOL barr [9];
    for (int i=0; i< 9; ++i)
        barr[i] = NO;
    
    for (int i=0; i< 9; ++i)
        switch ([str characterAtIndex:i]) {
            case '1':
                if (barr[0]) return NO;
                barr[0] = YES;
                break;
            case '2':
                if (barr[1]) return NO;
                barr[1] = YES;
                break;
            case '3':
                if (barr[2]) return NO;
                barr[2] = YES;
                break;
            case '4':
                if (barr[3]) return NO;
                barr[3] = YES;
                break;
            case '5':
                if (barr[4]) return NO;
                barr[4] = YES;
                break;
            case '6':
                if (barr[5]) return NO;
                barr[5] = YES;
                break;
            case '7':
                if (barr[6]) return NO;
                barr[6] = YES;
                break;
            case '8':
                if (barr[7]) return NO;
                barr[7] = YES;
                break;
            case '9':
                if (barr[8]) return NO;
                barr[8] = YES;
                break;
                
            default:
                return NO;
                break;
        }
    return YES;
}
@end
