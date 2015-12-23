//
//  PokerHand.h
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/21/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _suit_t {heart, spade, diamond, club} suit_t;

typedef struct _card_t {
    int n;
    suit_t suit;
} card_t;

@interface PokerHand : NSObject

-(instancetype)initWithString: (NSString *) str;

@end
