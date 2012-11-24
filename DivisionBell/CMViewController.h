//
//  CMViewController.h
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAppDelegate.h"
#import "DBClient.h"
#import "TWFYClient.h"

@interface CMViewController : UIViewController <PushUpdateProtocol, DBClientDelegate, TWFYClientDelegate>

-(void)didReceiveUpdate:(NSDictionary *)update;
-(void)apiRepliedWithResponse:(id)response forCall:(NSString *)call;

@end
