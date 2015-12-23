//
//  PokerHand.m
//  Useful Utilities
//
//  Created by Chengguang Zhao on 12/21/15.
//  Copyright © 2015 Chengguang Zhao. All rights reserved.
//

#import "PokerHand.h"

//MARK: Contants for validation
static const NSString * _rank_string = @"23456789TJQKA";    //valid card numbers
static const NSString * _suit_string = @"SHDC";             //valid card suits

//Shifts used to calculate poker hand score
static const int _KICKERS_SHIFTS [] = {16, 12, 8, 4, 0}; //highst to lowest kicker
static const int _ONE_PAIR_SHIFT = 20;
static const int _TWO_PAIRS_SHIFTS [] = {24, 20};       //highst to lowest
static const int _THREE_OF_A_KIND_SHIFT = 28;
static const int _STRAIGHT_SHIFT = 32;
static const int _FLUSH_SHIFTS [] = {36, 32, 28, 24, 20};//highst to lowest
static const int _FULL_HOUSE_SHIFTS [] = {40, 36};
static const int _FOUR_OF_A_KIND_SHIFT = 44;
static const int _STRAIGHT_FLUSH_SHIFT = 48;

static const signed char _UNSURE = -1;
static const signed char _YES = 1;
static const signed char _NO = 0;

//MARK: __Card interface
//helper class for holding a single card
@interface __Card: NSObject
@property (strong) NSString* rank;
@property (strong) NSString* suit;
@property (strong) NSNumber* rank_num;
-(instancetype)initWithString:(NSString *)str;
@end

//MARK: __Card implementation
@implementation __Card
-(instancetype)initWithString:(NSString *)str {
    if ([str length] != 2) {  //check each card string has exactly 2 characters
        return nil;
    }
    [self setRank:[str substringToIndex:1]];      //Rank or number of card is set with the first of
    [self setSuit:[str substringFromIndex:1]];
    if (self.rank.length != 1 || self.suit.length != 1) return nil;
    int t = 0;
    switch ([self.rank characterAtIndex:0]) {
        case 'T':
            t = 10;
            break;
        case 'J':
            t = 11;
            break;
        case 'Q':
            t = 12;
            break;
        case 'K':
            t = 13;
            break;
        case 'A':
            t = 14;
            break;
        default:    //Since card number has been validated, unaccounted numbers are numbered cards from 2 to 9
            t = (int)[self.rank characterAtIndex:0] - (int)'0';
            break;
    }
    NSNumber *tWrapped = [NSNumber numberWithInt:t];
    [self setRank_num:tWrapped];
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@:%@", _rank_num, _suit];
}
@end


//MARK: PokerHand private properties
@interface PokerHand()
@property (strong) NSMutableArray <__Card *> * cards;
@property unsigned long long hand_score;
@property signed char flush;
@property signed char straight;
@property signed char fourofakind;
@property signed char fullhouse;
@property signed char threeofakind;
@property signed char twopairs;
@property signed char onepair;
@property signed char nothing;
@property (strong) NSArray * results;
-(unsigned long long) calculateScore;
-(BOOL) hasStraightFlush;  //results: highest card
-(BOOL) hasFlush;          //results: yes or no
-(BOOL) hasStraight;       //results: highest card
-(BOOL) hasFourOfAKind;    //results: X and A; 4 of X and a kicker A
-(BOOL) hasFullHouse;      //results: X and Y; 3 of X and 2 of Y
-(BOOL) hasThreeOfAKind;   //results: X, A and B; 3 of X and kickers A and B
-(BOOL) hasTwoPairs;       //results: X, Y and A; 2 of X and Y and kicker A
-(BOOL) hasOnePair;        //results: X, A, B, and C; 2 of X and kickers A, B, and C
-(BOOL) hasNothing;        //results: yes or no
@end

//MARK: PokerHand Impelentation
@implementation PokerHand
-(BOOL)hasFlush {
    if (!_flush != _UNSURE) {
        return _flush;
    }
    for (int i=1; i<5; ++i) {
        if ([[_cards[i] suit] isEqualToString:[_cards[0] suit]]) {
            _flush = NO;
            return _flush;
        }
    }
    _flush = YES;
    _results = [NSArray arrayWithObjects:_cards[4].rank_num,
                _cards[3].rank_num, _cards[2].rank_num, _cards[1].rank_num,
                _cards[0].rank_num, nil];
    return _flush;
}

-(BOOL)hasStraight {
    if (_straight != _UNSURE) {
        return _straight;
    }
    for (int i=2; i<5; ++i) {   //each card is 1 bigger than previous card
        if (1 != ([_cards[i] rank_num].intValue -
                  [_cards[i-1] rank_num].intValue)) {
            _straight = NO;
            return _straight;
        }
    }
    if ( !( //lowest two cards are off by one OR one is ace and one is 2
           1 == ([_cards[1] rank_num].intValue - [_cards[0] rank_num].intValue) ||
           (2 == [_cards[1] rank_num].intValue && 14 == [_cards[0] rank_num].intValue)
           ))
    {
        _straight = NO;
        return _straight;
    }
    _straight = YES;
    _results = [NSArray arrayWithObjects:_cards[4].rank_num, nil];
    return _straight;
}

-(BOOL)hasStraightFlush {
    if (_flush == _UNSURE) [self hasFlush];
    if ( _straight == _UNSURE) [self hasStraight];
    
    if (_straight == YES && _flush == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)hasFourOfAKind {
    if (_fourofakind != _UNSURE) {
        return _fourofakind;
    }
    //either the first 4 cards or last 4 cards are the same
    if (_cards[0].rank_num.intValue == _cards[1].rank_num.intValue &&
        _cards[0].rank_num.intValue == _cards[2].rank_num.intValue &&
        _cards[0].rank_num.intValue == _cards[3].rank_num.intValue)
    {
        _fourofakind = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, nil];
        return _fourofakind;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue &&
        _cards[1].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[1].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _fourofakind = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[0].rank_num, nil];
        return _fourofakind;
    }
    _fourofakind = NO;
    return _fourofakind;
}

-(BOOL)hasFullHouse {
    if (_fullhouse != _UNSURE) {
        return _fullhouse;
    }
    //either pair followed by 3-of-a-kind or vice versa
    if (_cards[0].rank_num.intValue == _cards[1].rank_num.intValue &&
        (_cards[2].rank_num.intValue == _cards[3].rank_num.intValue &&
         _cards[2].rank_num.intValue == _cards[4].rank_num.intValue))
    {
        _fullhouse = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[0].rank_num, nil];
        return _fullhouse;
    }
    if ((_cards[0].rank_num.intValue == _cards[1].rank_num.intValue &&
         _cards[0].rank_num.intValue == _cards[2].rank_num.intValue) &&
        _cards[3].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _fullhouse = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[3].rank_num, nil];
        return _fullhouse;
    }
    _fullhouse = NO;
    return _fullhouse;
}

-(BOOL)hasThreeOfAKind {
    //make sure not 4-of-a-kind or full house first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == YES) {_threeofakind = NO; return _threeofakind;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == YES) {_threeofakind = NO; return _threeofakind;}
    //either 3-of-a-kind is lowest, middle, or highest of 5 cards
    if (_cards[2].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[1].rank_num.intValue)
    { //3-of-a-kind is lowest, highest 2 cards are kickers
        _threeofakind = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num,nil];
        return _threeofakind;
    }
    if (_cards[2].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[1].rank_num.intValue)
    { //3-of-a-kind is middle, highest and lowest cards are kickers
        _threeofakind = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[4].rank_num, _cards[0].rank_num,nil];
        return _threeofakind;
    }
    if (_cards[2].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[4].rank_num.intValue)
    { //3-of-a-kind is highest, lowest 2 cards are kickers
        _threeofakind = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[1].rank_num, _cards[0].rank_num,nil];
        return _threeofakind;
    }
    _threeofakind = NO;
    return _threeofakind;
}

-(BOOL)hasTwoPairs {
    //make sure not 4-of-a-kind or full house first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == YES) {_twopairs = NO; return _twopairs;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == YES) {_twopairs = NO; return _twopairs;}
    //two pairs are either both low, or both high, or one low and one high
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are both low
        _twopairs = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[1].rank_num, _cards[4].rank_num,nil];
        return _twopairs;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue &&
        _cards[4].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are both high
        _twopairs = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[1].rank_num, _cards[0].rank_num,nil];
        return _twopairs;
    }
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[4].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are one high and one low
        _twopairs = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[1].rank_num, _cards[2].rank_num,nil];
        return _twopairs;
    }
    _twopairs = NO;
    return _twopairs;
}

-(BOOL)hasOnePair {
    //make sure not 4-of-a-kind, full house, two pairs, three of a kind, first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == YES) {_onepair = NO; return _onepair;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == YES) {_onepair = NO; return _onepair;}
    if (_twopairs == _UNSURE) [self hasTwoPairs];
    if (_twopairs == YES) {_onepair = NO; return _onepair;}
    if (_threeofakind == _UNSURE) [self hasThreeOfAKind];
    if (_threeofakind == YES) {_onepair = NO; return _onepair;}
    
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue)
    { //pair is lowest, highest 3 cards are kickers
        _onepair = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num, _cards[2].rank_num, nil];
        return _onepair;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue)
    {
        _onepair = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    if (_cards[3].rank_num.intValue == _cards[2].rank_num.intValue)
    {
        _onepair = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[4].rank_num, _cards[1].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    if (_cards[3].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _onepair = YES;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[2].rank_num, _cards[1].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    _onepair = NO;
    return _onepair;
}

-(BOOL)hasNothing {
    if (_nothing != _UNSURE) return _nothing;
    //make sure not 4-of-a-kind, full house, two pairs, three of a kind, first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == YES) {_nothing = NO; return NO;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == YES) {_nothing = NO; return NO;}
    if (_twopairs == _UNSURE) [self hasTwoPairs];
    if (_twopairs == YES) {_nothing = NO; return NO;}
    if (_threeofakind == _UNSURE) [self hasThreeOfAKind];
    if (_threeofakind == YES) {_nothing = NO; return NO;}
    //make sure not one pair, flush, straight
    if (_onepair == _UNSURE) [self hasOnePair];
    if (_onepair == YES) {_nothing = NO; return NO;}
    if (_flush == _UNSURE) [self hasFlush];
    if (_flush == YES) {_nothing = NO; return NO;}
    if (_straight == _UNSURE) [self hasStraight];
    if (_straight == YES) {_nothing = NO; return NO;}
    _nothing = YES;
    return YES;
}

-(unsigned long long)calculateScore {
    unsigned long long result = 0;
    //check for flush
    
    //check for straight
    return result;
}

-(instancetype)initWithString:(NSString *)str {
    self = [super init];
    if (self) {
        //expect initiating string to be 14 characters long
        //and have the form "#S #S #S #S #S"
        //where # represents the number on card and S represents suit
        
        //Validation of input parameter string
        //check length
        if ([str length] < 14) return nil;   //str too short
        //chech number and suit
        for (int i = 0; i < 13; i += 3) {
            if ([_rank_string rangeOfString:
                 [str substringWithRange:
                  NSMakeRange(i, 1)]].location == NSNotFound)
                return nil;   //a number on card is not valid
            if ([_suit_string rangeOfString:
                 [str substringWithRange:
                  NSMakeRange(i+1, 1)]].location == NSNotFound)
                return nil;   //a number on card is not valid
        }
        //make sure there are five cards
        NSArray * sarray = [str componentsSeparatedByString:@" "];
        if (!([sarray count] == 5)) {
            return nil;
        }
        
        //Parse each card and add to _cards; expect 5 cards in a hand
        _cards = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; ++i) {           //create 5 Card objects
            __Card * card = [[__Card alloc] initWithString:sarray[i]];
            [_cards addObject:card];
        }
        
        //Sorting cards from low to high
        NSSortDescriptor *lowtohigh = [NSSortDescriptor sortDescriptorWithKey:
                                       @"rank_num" ascending:YES];
        [_cards sortUsingDescriptors:[NSArray arrayWithObject:lowtohigh]];
    }
    return self;
}
-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
            _cards[0],
            _cards[1],
            _cards[2],
            _cards[3],
            _cards[4]];
}
@end