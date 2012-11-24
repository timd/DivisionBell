//
//  DBClient.h
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "AFHTTPClient.h"

@protocol DBClientDelegate <NSObject>

-(void)apiRepliedWithResponse:(id)response forCall:(NSString *)call;

@end

@interface DBClient : AFHTTPClient

@property (nonatomic, weak) id <DBClientDelegate> delegate;

+(DBClient *)sharedInstance;

-(void)getUpdateFromAPI;

@end
