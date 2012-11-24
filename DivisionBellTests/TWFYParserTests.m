//
//  ParserTest.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "Kiwi.h"
#import "TWFYParser.h"

SPEC_BEGIN(TWFYParserTests)

describe(@"A basic test", ^{
    
    __block TWFYParser *parser = nil;
    
    beforeEach(^{
        
        parser = [TWFYParser sharedInstance];
        
    });
    
    context(@"when created", ^{
        
        it(@"should exist", ^{
            [parser shouldNotBeNil];
        });
        
        it(@"should respond to parseMpDataWithJson:", ^{
            [[parser should] respondToSelector:@selector(parseGetPersonData:)];
        });
        
    });
    
    context(@"parsing the TWFY response", ^{

        __block NSDictionary *returnDict = nil;
        
        beforeEach(^{
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForResource:@"getPerson" ofType:@"json"];
            
            NSError *error = nil;
            NSString *dataString = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
            NSData *fileData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            returnDict = [parser parseGetPersonData:fileData];

        });
        
        it(@"should return an NSDictionary", ^{
            
            // Load file
            [returnDict shouldNotBeNil];
            [[returnDict should] beKindOfClass:[NSDictionary class]];
        });

        it(@"should return a dictionary containing a key:value of image:/images/mpsL/10546.jpeg", ^{
            [[[returnDict objectForKey:@"image"] should] equal:@"/images/mpsL/10546.jpeg"];
        });
        
    });

});
    
SPEC_END