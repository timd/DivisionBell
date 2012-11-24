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
#import "TWFYParser.h"
#import "TWFYClient.h"

#import <AudioToolbox/AudioToolbox.h>

@interface CMViewController ()

@property (nonatomic, strong) DBClient *dbClient;
@property (nonatomic, strong) DBParser *dbParser;
@property (nonatomic, strong) TWFYParser *twfyParser;

@property (nonatomic, strong) CMAppDelegate *appDelegate;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *activityLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@property (nonatomic) BOOL hasUpdated;

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
    self.twfyParser = [TWFYParser sharedInstance];
    
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

#pragma mark -
#pragma mark Interation

-(IBAction)didTapUpdateButton:(id)sender {
    
    if (!self.hasUpdated) {
        [self.dbClient getUpdateFromAPI];
        self.hasUpdated = YES;
    } else {
        [self.nameLabel setText:@"Name"];
        [self.activityLabel setText:@"Activity"];
        [self.detailLabel setText:@"Detail"];
        self.hasUpdated = NO;
    }
}

-(IBAction)didTapTriggerButton:(id)sender {
    NSDictionary *update = @{@"bell" : @"1"};
    [self didReceiveUpdate:update];
}

#pragma mark -
#pragma mark AppDelegate protocol

-(void)didReceiveUpdate:(NSDictionary *)update {
    
    // Handle division bell
    if ([[update objectForKey:@"bell"] isEqualToString:@"1"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Division bell!" message:@"Hurry to the Lobby!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        NSLog(@"didReceiveBellUpdate");
        return;
        
    }
    
    NSLog(@"didReceiveUpdate: %@", update);
    [self.dbClient getUpdateFromAPI];
    
}

#pragma mark -
#pragma mark DBClient protocol methods

-(void)apiRepliedWithResponse:(id)response forCall:(NSString *)call {
    
    if ([call isEqualToString:@"pushUpdate"]) {
    
        NSLog(@"API replied with response %@ for call %@", response, call);
        
        NSDictionary *responseDict = [self.dbParser parseSingleUpdateWithData:response];
        
        NSLog(@"API replied with dict %@ for call %@", responseDict, call);
        
        NSDictionary *personPayload = [responseDict objectForKey:@"person"];
        
        NSString *name = [personPayload  objectForKey:@"name"];
        NSString *person_id = [personPayload objectForKey:@"person_id"];
        NSString *activity = [responseDict objectForKey:@"activity"];
        
        NSString *detail = [responseDict objectForKey:@"topic"];
        
        [self.nameLabel setText:name];
        [self.activityLabel setText:activity];
        [self.detailLabel setText:detail];
        
        // Update images from TWFY data
        TWFYClient *twfyClient = [TWFYClient sharedInstance];
        [twfyClient setDelegate:self];
        [twfyClient getDataForPerson:person_id];
        
    } else if ([call isEqualToString:@"getPerson"]) {
        
        NSLog(@"Call received for getPerson");
        NSLog(@"Response = %@", response);
        
        NSDictionary *personDict = [self.twfyParser parseGetPersonData:response];
        
        NSLog(@"image = %@", [personDict objectForKey:@"image"]);
        
    }

}

-(void)playSound {
    
    // ivar
    SystemSoundID mBeep;
    
    // Create the sound ID
    NSString* path = [[NSBundle mainBundle]
                      pathForResource:@"Beep" ofType:@"aiff"];
    NSURL* url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
    
    // Play the sound
    AudioServicesPlaySystemSound(mBeep);
    
    // Dispose of the sound
    AudioServicesDisposeSystemSoundID(mBeep);
}

@end
