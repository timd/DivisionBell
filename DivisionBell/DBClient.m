//
//  DBClient.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "DBClient.h"
#import "OHHTTPStubs.h"

#define kAPIEndPoint @"http://rsparly.toastwaffle.com"


@implementation DBClient

+(DBClient *)sharedInstance {
    static DBClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIEndPoint]];
    });
    
    return sharedInstance;
}

-(void)stubNetworkCall {
    
#ifdef DEBUG
    
    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse*(NSURLRequest *request, BOOL onlyCheck) {
        
        NSString *basename = [request.URL.absoluteString lastPathComponent];
        NSLog(@"basename = %@", basename);
        if ([basename isEqualToString:@"get_annunciator.php"]) {

            return [OHHTTPStubsResponse responseWithFile:@"single.json"
                                             contentType:@"text/json"
                                            responseTime:OHHTTPStubsDownloadSpeedEDGE];
        }

        if ([basename rangeOfString:@"getPerson"].location == NSNotFound) {
            return nil;
        }
            
        return [OHHTTPStubsResponse responseWithFile:@"getPerson.json"
                                         contentType:@"text/json"
                                        responseTime:OHHTTPStubsDownloadSpeedEDGE];

    }];
    
#endif
    
}


-(void)getUpdateFromAPI {
    
    //[self stubNetworkCall];
    
    // Build API call
    // getPerson?key=ABCD&id=12345
    NSString *call = [NSString stringWithFormat:@"%@/get_annunciator.php", kAPIEndPoint];
    NSString *callType = @"pushUpdate";
    
    // Call TWFY API
    [self getPath:call parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.delegate apiRepliedWithResponse:responseObject forCall:callType];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.delegate apiRepliedWithResponse:nil forCall:callType];
        
    }];
    
}

@end
