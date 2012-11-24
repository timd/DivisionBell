//
//  CMViewController.h
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAppDelegate.h"

@interface CMViewController : UIViewController <UpdateProtocol>

-(void)didReceiveUpdate:(NSDictionary *)update;

@end
