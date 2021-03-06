//
//  CMAppDelegate.h
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PushUpdateProtocol <NSObject>

-(void)didReceiveUpdate:(NSDictionary *)update;

@end

@class CMViewController;

@interface CMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CMViewController *viewController;
@property (nonatomic, weak) id <PushUpdateProtocol> delegate;

@end
