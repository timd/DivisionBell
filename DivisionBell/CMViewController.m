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
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

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
        [self.imageView setImage:nil];
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
    
        NSDictionary *responseDict = [self.dbParser parseSingleUpdateWithData:response];
        NSDictionary *personPayload = [responseDict objectForKey:@"person"];
        
        if (personPayload) {
        
            // Have received data for a person
            NSString *name = [personPayload  objectForKey:@"name"];
            NSString *person_id = [personPayload objectForKey:@"person_id"];
            NSString *detail = [responseDict objectForKey:@"topic"];
            
            [self.nameLabel setText:name];
            [self.detailLabel setText:detail];
            
            // Update images from TWFY data
            TWFYClient *twfyClient = [TWFYClient sharedInstance];
            [twfyClient setDelegate:self];
            [twfyClient getDataForPerson:person_id];
            
        } else {

            // HOUSE UP received, can only update activity
            [self.nameLabel setText:nil];
            [self.detailLabel setText:nil];
            [self.imageView setImage:nil];

        }

        NSString *activity = [responseDict objectForKey:@"activity"];
        [self.activityLabel setText:activity];

        
    } else if ([call isEqualToString:@"getPerson"]) {
        
        NSDictionary *personDict = [self.twfyParser parseGetPersonData:response];
        NSLog(@"image = %@", [personDict objectForKey:@"image"]);
        NSLog(@"first_name = %@", [personDict objectForKey:@"first_name"]);
        NSLog(@"last_name = %@", [personDict objectForKey:@"last_name"]);
        NSLog(@"party = %@", [personDict objectForKey:@"party"]);
        NSLog(@"image_height = %@", [personDict objectForKey:@"image_height"]);
        NSLog(@"image_width = %@", [personDict objectForKey:@"image_width"]);
        
        [self.imageView setImage:nil];
        
        if ([personDict objectForKey:@"image"]) {
            NSString *imageURLString = [NSString stringWithFormat:@"http://www.theyworkforyou.com%@", [personDict objectForKey:@"image"]];
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            //NSData *data = [NSData dataWithContentsOfURL:imageURL];
            //UIImage *image = [UIImage imageWithData:data];
            //[self.imageView setImage:image];
            [self getImage:imageURL];
        } else {
            [self.imageView setImage:[UIImage imageNamed:@"thatcher.jpg"]];
        }

    }

}

-(void)getImage:(NSURL *)imageURL {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^{
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
            [self.imageView setNeedsDisplay];
        });
    });
    
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
