//
//  BaseKiwiTest.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "Kiwi.h"

SPEC_BEGIN(BaseKiwiTests)

describe(@"A basic test", ^{
    
    it(@"should do something", ^{
        
        NSUInteger a = 10;
        NSUInteger b = 12;
        
        [[theValue(a+b) should] equal:theValue(22)];
        
    });
    
});

SPEC_END