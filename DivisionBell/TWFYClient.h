//
//  TWFYClient.h
//  TWFY
//
//  Created by Tim on 23/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "AFHTTPClient.h"

@protocol TWFYClientDelegate <NSObject>

-(void)apiRepliedWithResponse:(id)response forCall:(NSString *)call;

@end

@interface TWFYClient : AFHTTPClient

@property (nonatomic, weak) id <TWFYClientDelegate> delegate;

+(TWFYClient *)sharedInstance;
-(void)getDataForPerson:(NSString *)personID;
    
@end
