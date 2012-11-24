//
//  CMViewController.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "CMAppDelegate.h"
#import "CMViewController.h"
#import "DBParser.h"


@interface CMViewController ()

@property (nonatomic, strong) DBClient *dbClient;
@property (nonatomic, strong) DBParser *dbParser;

@property (nonatomic, strong) CMAppDelegate *appDelegate;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *activityLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@end

@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (CMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate setDelegate:self];
    
    self.dbClient = [DBClient sharedInstance];
    [self.dbClient setDelegate:self];
    
    self.dbParser = [DBParser sharedInstance];
    
}

-(void)viewDidUnload {
    [self.appDelegate setDelegate:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didReceiveUpdate:(NSDictionary *)update {
    
    [self.dbClient getUpdateFromAPI];
    
}

-(void)apiRepliedWithResponse:(id)response forCall:(NSString *)call {
    
    NSLog(@"API replied with response %@ for call %@", response, call);
    
    NSDictionary *responseDict = [self.dbParser parseUpdateJsonFromAPI:response];
    
    NSLog(@"API replied with dict %@ for call %@", responseDict, call);
    
    NSString *name = [responseDict objectForKey:@"name"];
    NSString *activity = [responseDict objectForKey:@"activity"];
    NSString *detail = [responseDict objectForKey:@"detail"];
    
    [self.nameLabel setText:name];
    [self.activityLabel setText:activity];
    [self.detailLabel setText:detail];
    
}

@end
