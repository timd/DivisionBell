//
//  TWFYClient.m
//  TWFY
//
//  Created by Tim on 23/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "TWFYClient.h"

#ifdef DEBUG
#import "OHHTTPStubs.h"
#endif

#define kAPIEndpointURL @"http://www.theyworkforyou.com/api/"
#define kAPIKey @"CJLG8dFMDJ7WDDHJNvEHWj6o"
#define kShouldStubNetworkCalls YES


@implementation TWFYClient

+(TWFYClient *)sharedInstance {
    static TWFYClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TWFYClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.theyworkforyou.com/api/"]];
    });
    
    return sharedInstance;
}

-(void)stubNetworkCall {
    
#ifdef DEBUG
    
    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse*(NSURLRequest *request, BOOL onlyCheck) {
        
    //NSString *basename = [request.URL.absoluteString lastPathComponent];

    return [OHHTTPStubsResponse responseWithFile:@"getPerson.json"
                                     contentType:@"text/json"
                                    responseTime:OHHTTPStubsDownloadSpeedEDGE];
    }];
    
#endif
    
}

-(void)getDataForPerson:(NSString *)personID {
    
    //[self stubNetworkCall];

    // Set call back type
    NSString *callType = @"getPerson";
    
    // Convert to person
    
    // Build API call
    // getPerson?key=ABCD&id=12345
    NSString *call = [NSString stringWithFormat:@"%@getPerson?key=%@&id=%@", kAPIEndpointURL, kAPIKey, personID];
    
    // Call TWFY API
    [self getPath:call parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self.delegate apiRepliedWithResponse:responseObject forCall:callType];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [self.delegate apiRepliedWithResponse:nil forCall:callType];
        
    }];

}

@end
