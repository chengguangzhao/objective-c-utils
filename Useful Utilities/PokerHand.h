//
//  PokerHand.h
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/21/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerHand : NSObject

-(instancetype)initWithString: (NSString *) str;
-(unsigned long long) getScore;
-(NSString *) getHandName;

@end
