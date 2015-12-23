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

        PokerHand * h = [[PokerHand alloc] initWithString:[hands[0] substringToIndex:14]];
        NSLog(@"%@", h );

        
                     
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        //NSLog(@"%lu", (unsigned long)allLinedStrings.count);
        NSLog(@"%f milliseconds has elapsed.", -timeInterval*1000);
    }
    return 0;
}
