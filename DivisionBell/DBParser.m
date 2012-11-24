//
//  DBParser.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "DBParser.h"

@implementation DBParser

+(DBParser *)sharedInstance {
    
    static DBParser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBParser alloc] init];
    });
    
    return sharedInstance;
    
}

-(NSDictionary *)parseUpdateJsonFromAPI:(NSData *)response {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    return dict;
}

-(NSDictionary *)parseSingleUpdateWithData:(NSData *)jsonData {
    
    NSError *error = nil;
    NSDictionary *topLevel = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    
    if (error) {
        return nil;
    }
    
    return topLevel;
    
}


@end
