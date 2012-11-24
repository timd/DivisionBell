//
//  CMParser.m
//  TWFY
//
//  Created by Tim on 04/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "TWFYParser.h"

#define kGetPersonCall @"getPerson"

@implementation TWFYParser

+(TWFYParser *)sharedInstance {
    
    static TWFYParser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TWFYParser alloc] init];
    });
    
    return sharedInstance;
    
}

-(NSDictionary *)parseGetPersonData:(NSData *)response {
    
    NSError *error = nil;
    NSArray *topLevel = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    if (error) {
        return nil;
    }
    
    NSUInteger index = [topLevel indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dictUnderTest = (NSDictionary *)obj;
        return [[dictUnderTest objectForKey:@"left_house"] isEqualToString:@"9999-12-31"];
    }];
    
    if (index != NSNotFound) {
        return [topLevel objectAtIndex:index];
    }
    
    return topLevel;
    
}
@end
