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
static const int _ONE_PAIR_SHIFTS [] = {20, 16, 12, 8};
static const int _TWO_PAIRS_SHIFTS [] = {24, 20, 16};       //highst to lowest
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
@property (strong) NSString * handname; //two pairs, flush, etc
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
        
        //set all flags to _UNSURE
        _fullhouse = _flush = _straight = _threeofakind = _twopairs = _onepair = _nothing = _UNSURE;
        _hand_score = 0;
        _handname = nil;
        [self calculateScore];
    }
    return self;
}

-(BOOL)hasFlush {
    if (_flush != _UNSURE) {
        return _flush;
    }
    for (int i=1; i<5; ++i) {
        NSLog(@"In hasFlush loop: i=%d,  [_cards[i] suit]: %@, _cards[0].suit: %@", i, _cards[i].suit, _cards[0].suit);
        if (![[_cards[i] suit] isEqualToString:_cards[0].suit]) {
            _flush = _NO;
            return _flush;
        }
    }
    _flush = _YES;
    _fullhouse = _fourofakind = _threeofakind = _twopairs = _onepair = _nothing = _NO;
    _results = [NSArray arrayWithObjects:_cards[4].rank_num,
                _cards[3].rank_num, _cards[2].rank_num, _cards[1].rank_num,
                _cards[0].rank_num, nil];
    return _flush;
}

-(BOOL)hasStraight {
    if (_straight != _UNSURE) { //already know
        return _straight;
    }
    for (int i=1; i<4; ++i) {   //each card is 1 bigger than previous card
        if (1 != ([_cards[i] rank_num].intValue -
                  [_cards[i-1] rank_num].intValue)) {
            _straight = _NO;
            return _straight;
        }
    }
    if (1 == ([_cards[4] rank_num].intValue - [_cards[3] rank_num].intValue))
    {
        _straight = _YES;
        _fullhouse = _fourofakind = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [NSArray arrayWithObjects:_cards[4].rank_num, nil];
        return _straight;
    }
    if (2 == [_cards[0] rank_num].intValue && 14 == [_cards[4] rank_num].intValue)
    {
        _straight = _YES;
        _fullhouse = _fourofakind = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [NSArray arrayWithObjects:_cards[3].rank_num, nil];
        return _straight;
    }
    _straight = _NO;
    return _straight;
}

-(BOOL)hasStraightFlush {
    if (_flush == _UNSURE) [self hasFlush];
    if ( _straight == _UNSURE) [self hasStraight];
    
    if (_straight == _YES && _flush == _YES)
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
        _fourofakind = _YES;
        _fullhouse = _flush = _straight = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, nil];
        return _fourofakind;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue &&
        _cards[1].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[1].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _fourofakind = _YES;
        _fullhouse = _flush = _straight = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[0].rank_num, nil];
        return _fourofakind;
    }
    _fourofakind = _NO;
    return _fourofakind == _YES;
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
        _fullhouse = _YES;
        _fourofakind = _flush = _straight = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[0].rank_num, nil];
        return _fullhouse;
    }
    if ((_cards[0].rank_num.intValue == _cards[1].rank_num.intValue &&
         _cards[0].rank_num.intValue == _cards[2].rank_num.intValue) &&
        _cards[3].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _fullhouse = _YES;
        _fourofakind = _flush = _straight = _threeofakind = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[3].rank_num, nil];
        return _fullhouse;
    }
    _fullhouse = _NO;
    return _fullhouse;
}

-(BOOL)hasThreeOfAKind {
    //make sure not 4-of-a-kind or full house first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == _YES) {_threeofakind = _NO; return _threeofakind;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == _YES) {_threeofakind = _NO; return _threeofakind;}
    //either 3-of-a-kind is lowest, middle, or highest of 5 cards
    if (_cards[2].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[1].rank_num.intValue)
    { //3-of-a-kind is lowest, highest 2 cards are kickers
        _threeofakind = _YES;
        _flush = _straight = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num,nil];
        return _threeofakind;
    }
    if (_cards[2].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[1].rank_num.intValue)
    { //3-of-a-kind is middle, highest and lowest cards are kickers
        _threeofakind = _YES;
        _flush = _straight = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[4].rank_num, _cards[0].rank_num,nil];
        return _threeofakind;
    }
    if (_cards[2].rank_num.intValue == _cards[3].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[4].rank_num.intValue)
    { //3-of-a-kind is highest, lowest 2 cards are kickers
        _threeofakind = _YES;
        _flush = _straight = _twopairs = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[1].rank_num, _cards[0].rank_num,nil];
        return _threeofakind;
    }
    _threeofakind = _NO;
    return _threeofakind;
}

-(BOOL)hasTwoPairs {
    //make sure not 4-of-a-kind or full house first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == _YES) {_twopairs = _NO; return _twopairs;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == _YES) {_twopairs = _NO; return _twopairs;}
    //two pairs are either both low, or both high, or one low and one high
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[2].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are both low
        _twopairs = _YES;
        _flush = _straight = _threeofakind = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[2].rank_num,
                    _cards[1].rank_num, _cards[4].rank_num,nil];
        return _twopairs;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue &&
        _cards[4].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are both high
        _twopairs = _YES;
        _flush = _straight = _threeofakind = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[1].rank_num, _cards[0].rank_num,nil];
        return _twopairs;
    }
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue &&
        _cards[4].rank_num.intValue == _cards[3].rank_num.intValue)
    { //two pairs are one high and one low
        _twopairs = _YES;
        _flush = _straight = _threeofakind = _onepair = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[1].rank_num, _cards[2].rank_num,nil];
        return _twopairs;
    }
    _twopairs = _NO;
    return _twopairs;
}

-(BOOL)hasOnePair {
    //make sure not 4-of-a-kind, full house, two pairs, three of a kind, first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == _YES) {_onepair = _NO; return _onepair;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == _YES) {_onepair = _NO; return _onepair;}
    if (_twopairs == _UNSURE) [self hasTwoPairs];
    if (_twopairs == _YES) {_onepair = _NO; return _onepair;}
    if (_threeofakind == _UNSURE) [self hasThreeOfAKind];
    if (_threeofakind == _YES) {_onepair = _NO; return _onepair;}
    
    if (_cards[1].rank_num.intValue == _cards[0].rank_num.intValue)
    { //pair is lowest, highest 3 cards are kickers
        _onepair = _YES;
        _flush = _straight = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num, _cards[2].rank_num, nil];
        return _onepair;
    }
    if (_cards[1].rank_num.intValue == _cards[2].rank_num.intValue)
    {
        _onepair = _YES;
        _flush = _straight = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[1].rank_num,
                    _cards[4].rank_num, _cards[3].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    if (_cards[3].rank_num.intValue == _cards[2].rank_num.intValue)
    {
        _onepair = _YES;
        _flush = _straight = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[4].rank_num, _cards[1].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    if (_cards[3].rank_num.intValue == _cards[4].rank_num.intValue)
    {
        _onepair = _YES;
        _flush = _straight = _nothing = _NO;
        _results = [[NSArray alloc] initWithObjects:_cards[3].rank_num,
                    _cards[2].rank_num, _cards[1].rank_num, _cards[0].rank_num, nil];
        return _onepair;
    }
    _onepair = _NO;
    return _onepair == _YES;
}

-(BOOL)hasNothing {
    if (_nothing != _UNSURE) return _nothing;
    //make sure not 4-of-a-kind, full house, two pairs, three of a kind, first
    if (_fourofakind == _UNSURE) [self hasFourOfAKind];
    if (_fourofakind == _YES) {_nothing = _NO; return NO;}
    if (_fullhouse == _UNSURE) [self hasFullHouse];
    if (_fullhouse == _YES) {_nothing = _NO; return NO;}
    if (_twopairs == _UNSURE) [self hasTwoPairs];
    if (_twopairs == _YES) {_nothing = _NO; return NO;}
    if (_threeofakind == _UNSURE) [self hasThreeOfAKind];
    if (_threeofakind == _YES) {_nothing = _NO; return NO;}
    //make sure not one pair, flush, straight
    if (_onepair == _UNSURE) [self hasOnePair];
    if (_onepair == _YES) {_nothing = _NO; return NO;}
    if (_flush == _UNSURE) [self hasFlush];
    if (_flush == _YES) {_nothing = _NO; return NO;}
    if (_straight == _UNSURE) [self hasStraight];
    if (_straight == _YES) {_nothing = _NO; return NO;}
    _nothing = _YES;
    _results = [[NSArray alloc] initWithObjects:_cards[4].rank_num,
                _cards[3].rank_num, _cards[2].rank_num,
                _cards[1].rank_num, _cards[0].rank_num,nil];
    return _nothing == _YES;
}

-(unsigned long long)calculateScore {
    if (_hand_score > 0) return _hand_score;
    unsigned long long temp = 0;
    if ([self hasStraightFlush]) {
        if ([_results[0] intValue] == 14) {
            _handname = @"Royal Straight Flush";
        } else {
            _handname = @"Straight Flush";
        }
        temp = [_results[0] intValue];
        _hand_score = temp << _STRAIGHT_FLUSH_SHIFT;
        return _hand_score;
    }
    if ([self hasFlush]) {
        _handname = @"Flush";
        for (int i=0; i < _results.count; ++i) {
            temp = [_results[i] intValue];
            _hand_score |= temp << _FLUSH_SHIFTS[i];
        }
        return _hand_score;
    }
    if ([self hasStraight]) {
        _handname = @"Straight";
        temp = [_results[0] intValue];
        _hand_score = temp << _STRAIGHT_SHIFT;
        return _hand_score;
    }
    if ([self hasFourOfAKind]) {
        _handname = @"Four of a Kind";
        temp = [_results[0] intValue];
        _hand_score = temp << _FOUR_OF_A_KIND_SHIFT;
        for (int i = 1; i < [_results count]; ++i) {
            temp = [_results[i] intValue];
            _hand_score |= temp << _KICKERS_SHIFTS[i-1];
        }
        return _hand_score;
    }
    if ([self hasFullHouse]) {
        _handname = @"Full House";
        for (int i = 0;
             i < [_results count] &&
             i < sizeof(_FULL_HOUSE_SHIFTS)/sizeof(_FULL_HOUSE_SHIFTS[0]);
             ++i)
        {
            temp = [_results[i] intValue];
            _hand_score |= temp << _FULL_HOUSE_SHIFTS[i];
        }
        return _hand_score;
    }

    if ([self hasThreeOfAKind]) {
        _handname = @"Three of a Kind";
        temp = [_results[0] intValue];
        _hand_score = temp << _THREE_OF_A_KIND_SHIFT;
        for (int i = 1; i < [_results count]; ++i) {
            temp = [_results[i] intValue];
            _hand_score |= temp << _KICKERS_SHIFTS[i-1];
        }
        return _hand_score;
    }
    if ([self hasTwoPairs]) {
        _handname = @"Two Pairs";
        for (int i = 0;
             i < [_results count] &&
             i < sizeof(_TWO_PAIRS_SHIFTS)/sizeof(_TWO_PAIRS_SHIFTS[0]);
             ++i)
        {
            temp = [_results[i] intValue];
            _hand_score |= temp << _TWO_PAIRS_SHIFTS[i];
        }
        return _hand_score;
    }
    if ([self hasOnePair]) {
        _handname = @"One Pair";
        for (int i = 0;
             i < [_results count] &&
             i < sizeof(_ONE_PAIR_SHIFTS)/sizeof(_ONE_PAIR_SHIFTS[0]);
             ++i)
        {
            temp = [_results[i] intValue];
            _hand_score |= temp << _ONE_PAIR_SHIFTS[i];
        }
        return _hand_score;
    }
    //has nothing
    [self hasNothing];
    _handname = @"Nothing";
    for (int i = 0;
         i < [_results count] &&
         i < sizeof(_KICKERS_SHIFTS)/sizeof(_KICKERS_SHIFTS[0]);
         ++i)
    {
        temp = [_results[i] intValue];
        _hand_score |= temp << _KICKERS_SHIFTS[i];
    }
    return _hand_score;
}

-(NSString *) getHandName {
    if (_handname == nil) {
        [self calculateScore];
    }
    return _handname;
}

-(unsigned long long)getScore {
    if (_hand_score == 0) {
        return [self calculateScore];
    }
    return _hand_score;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ %@ %@ %@ %@ with score %llu",
            [self getHandName],
            _cards[0],
            _cards[1],
            _cards[2],
            _cards[3],
            _cards[4],
            _hand_score];
}
@end