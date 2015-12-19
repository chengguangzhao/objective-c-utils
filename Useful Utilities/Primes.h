//
//  SmallPrimes.h
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/19/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Primes : NSObject

+(BOOL) isPrimeStright:(unsigned long long)num;
+(BOOL) isPrimeMixed:(unsigned long long)num;
+(BOOL) isPrime: (unsigned long long) num;

@end
