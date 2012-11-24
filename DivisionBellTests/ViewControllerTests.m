//
//  ParserTest.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "Kiwi.h"
#import "DBParser.h"
#import "CMViewController.h"

SPEC_BEGIN(ViewControllerTests)

describe(@"A basic test", ^{
    
    __block DBParser *parser = nil;
    __block CMViewController *vc = nil;
    
    beforeEach(^{
        parser = [[DBParser alloc] init];
        vc = [[CMViewController alloc] init];
        [parser shouldNotBeNil];
    });
    
    context(@"when created", ^{
        
        it(@"should exist", ^{
            [vc shouldNotBeNil];
        });
        
        it(@"should respond to parseMpDataWithJson:", ^{
            [[vc should] respondToSelector:@selector(apiRepliedWithResponse:forCall:)];
        });
        
    });
    
    context(@"when handing api responses for a normal update", ^{
        
        __block NSDictionary *returnDict = nil;
        
        beforeEach(^{
            
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForResource:@"single" ofType:@"json"];
            
            NSError *error = nil;
            NSString *dataString = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
            NSData *fileData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            returnDict = [parser parseSingleUpdateWithData:fileData];
            
        });
        
        
    });
    
});

SPEC_END