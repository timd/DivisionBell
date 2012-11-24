//
//  DBParser.h
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBParser : NSObject

+(DBParser *)sharedInstance;
-(NSDictionary *)parseUpdateJsonFromAPI:(NSData *)response;
-(NSDictionary *)parseSingleUpdateWithData:(NSData *)jsonData;

@end
