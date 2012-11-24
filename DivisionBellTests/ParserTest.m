//
//  ParserTest.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "Kiwi.h"
#import "DBParser.h"

SPEC_BEGIN(ParserTests)

describe(@"A basic test", ^{
    
    __block DBParser *parser = nil;
    
    beforeEach(^{

        parser = [[DBParser alloc] init];
        
    });
    
    context(@"when created", ^{
        
        it(@"should exist", ^{
            [parser shouldNotBeNil];
        });
        
        it(@"should respond to parseMpDataWithJson:", ^{
            [[parser should] respondToSelector:@selector(parseSingleUpdateWithData:)];
        });
        
    });
    
    context(@"when handling a single update", ^{

        __block NSDictionary *returnDict = nil;
        
        beforeEach(^{

            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForResource:@"single" ofType:@"json"];
            
            NSError *error = nil;
            NSString *dataString = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
            NSData *fileData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            returnDict = [parser parseSingleUpdateWithData:fileData];

        });
        
        it(@"should return an NSDictionary of stuff when passed a JSON file", ^{
            [returnDict shouldNotBeNil];
        });
        
        it(@"should have a key called datetime", ^{
            [[returnDict objectForKey:@"datetime"] shouldNotBeNil];
        });
        
        it(@"should have a 'datetime' key with a value of '2012-11-22 14:20'", ^{
            [[[returnDict objectForKey:@"datetime"] should] equal:@"2012-11-22 14:20"];
        });
        
        it(@"should have a key of 'topic' with a value of ''VOTING ELIGIBILITY (PRISONERS) ''", ^{
            [[[returnDict objectForKey:@"topic"] should] equal:@"'VOTING ELIGIBILITY (PRISONERS) '"];
        });
        
        it(@"should have a key of 'activity' with a value of 'STATEMENT'", ^{
            [[[returnDict objectForKey:@"activity"] should] equal:@"STATEMENT"];
        });
        
        it(@"should have a key of 'person'", ^{
            [[returnDict objectForKey:@"person"] shouldNotBeNil];
        });
        
        it(@"should have a key of person containing a dictionary", ^{
            [[[returnDict objectForKey:@"person"] should] isKindOfClass:[NSDictionary class]];
        });
        
        it(@"should have a dictionary containing 'Dods_id'", ^{
            NSDictionary *personDict = [returnDict objectForKey:@"person"];
            [[[personDict objectForKey:@"Dods_Id"] shouldEventually] shouldNotBeNil];
        });
        
        it(@"should have a Dods_Id of 25311", ^{
            NSDictionary *personDict = [returnDict objectForKey:@"person"];
            [[[personDict objectForKey:@"Dods_Id"] shouldEventually] equal:@"25311"];
        });
    
    });
    
});

SPEC_END