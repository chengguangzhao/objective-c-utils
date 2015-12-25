//
//  main.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/16/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Primes.h"
//#import "MathUtils.h"
#import "PokerHand.h"



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDate * start = [NSDate date];
        
        //Reading file
        NSString * filePath;
        NSFileManager *filemgr;
        NSData *databuffer;
        filemgr = [NSFileManager defaultManager];
        filePath = @"/Users/chengguangzhao/Documents/Dev/Useful Utilities/Useful Utilities/poker.txt";
        if ([filemgr isReadableFileAtPath: filePath ] == YES)
            NSLog (@"File exists and is readable");
        else
            NSLog (@"File not found or is not readable");
        databuffer = [NSData dataWithContentsOfFile:filePath];
        NSString *string = [NSString stringWithUTF8String:[databuffer bytes]];
        NSArray *hands = [string componentsSeparatedByString:@"\n"];
        
//        PokerHand * hand = [[PokerHand alloc] initWithString:@"2H 3H 4H 5H 6H"];
//        NSLog(@"%@", hand);
        
        int p1win = 0;
        NSMutableArray <PokerHand *> * p1arr = [NSMutableArray alloc].init;
        NSMutableArray <PokerHand *> * p2arr = [NSMutableArray alloc].init;
        for (NSString * hand in hands) {
            [p1arr addObject:[[PokerHand alloc] initWithString:[hand substringToIndex:14]]];
            [p2arr addObject:[[PokerHand alloc] initWithString:[hand substringFromIndex:15]]];
            NSLog(@"Player 1: %@ <==> Player 2: %@", p1arr.lastObject.getHandName,p2arr.lastObject.getHandName);
            if (p1arr.lastObject.getScore > p2arr.lastObject.getScore)
                ++p1win;
        }
        
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        NSLog(@"Player 1 won %d times", p1win);
        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
