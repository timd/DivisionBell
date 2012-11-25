//
//  CMViewController.m
//  DivisionBell
//
//  Created by Tim on 24/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CMAppDelegate.h"
#import "CMViewController.h"
#import "DBParser.h"
#import "TWFYParser.h"
#import "TWFYClient.h"

#import "CMDivisionAlert.h"

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

@property (nonatomic, strong) UIView *alert;

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
    
    UIColor *baize = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pool_table"]];
    [self.view setBackgroundColor:baize];
    
    [self.nameLabel setFont:[UIFont fontWithName:@"Rosarivo-Regular" size:18]];
    [self.activityLabel setFont:[UIFont fontWithName:@"Rosarivo-Regular" size:18]];
    [self.detailLabel setFont:[UIFont fontWithName:@"Rosarivo-Regular" size:18]];
    
    [self.imageView.layer setMasksToBounds:NO];
    [self.imageView.layer setCornerRadius:8.0f];
    [self.imageView.layer setShadowOffset:CGSizeMake(0, 5)];
    [self.imageView.layer setShadowRadius:5.0f];
    [self.imageView.layer setShadowOpacity:0.5f];
    
    [self.nameLabel setText:nil];
    [self.activityLabel setText:@"The House is not sitting."];
    [self.detailLabel setText:nil];
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
    [self.dbClient getUpdateFromAPI];
    self.hasUpdated = YES;
}

-(IBAction)didTapTriggerButton:(id)sender {
    
    if (self.alert) {
        [self.alert removeFromSuperview];
    }
    
    NSDictionary *update = @{@"bell" : @"1"};
    [self didReceiveUpdate:update];
}

-(IBAction)didTapClearButton:(id)sender {

    if (self.alert) {
        [self.alert removeFromSuperview];
    }

    [self.nameLabel setText:nil];
    [self.activityLabel setText:@"The House is not sitting."];
    [self.detailLabel setText:nil];
    [self.imageView setImage:nil];
    self.hasUpdated = NO;

}

#pragma mark -
#pragma mark AppDelegate protocol

-(void)didReceiveUpdate:(NSDictionary *)update {
    
    // Handle division bell
    if ([[update objectForKey:@"bell"] isEqualToString:@"1"]) {
        
        [self drawAlertView];

/*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Division bell!" message:@"Hurry to the Lobby!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
*/
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

#pragma mark -
#pragma mark Alert view

-(void)drawAlertView {
    
    self.alert = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"norwegian_rose"]];
    [self.alert setBackgroundColor:background];
    
    [self.alert.layer setMasksToBounds:NO];
    [self.alert.layer setCornerRadius:8.0f];
    [self.alert.layer setShadowOffset:CGSizeMake(0, 10)];
    [self.alert.layer setShadowRadius:5.0f];
    [self.alert.layer setShadowOpacity:0.5f];
    
    UIView *portcullis = [[UIView alloc] initWithFrame:CGRectMake(95, 30, 90, 109)];
    UIColor *portcullisBackground = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"portcullis"]];
    [portcullis setBackgroundColor:portcullisBackground];
    [portcullis.layer setMasksToBounds:NO];
    [portcullis.layer setCornerRadius:8.0f];
    [portcullis.layer setShadowOffset:CGSizeMake(0, 3)];
    [portcullis.layer setShadowRadius:2.0f];
    [portcullis.layer setShadowOpacity:0.25f];
    [self.alert addSubview:portcullis];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 280, 40)];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont fontWithName:@"Copperplate-Bold" size:25.0f]];
    [title setText:@"Division called!"];
    [self.alert addSubview:title];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert:)];
    [tapper setNumberOfTapsRequired:1];
    [tapper setNumberOfTouchesRequired:1];
    [self.alert addGestureRecognizer:tapper];
    
    self.alert.transform = CGAffineTransformScale(self.alert.transform, 0.0f, 0.0f);
    [self.view addSubview:self.alert];
    
    [UIView animateWithDuration:0.25 animations:^{

        [self.alert setTransform:CGAffineTransformIdentity];

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            // Scale up
            self.alert.transform = CGAffineTransformScale(self.alert.transform, 1.05f, 1.05f);
        } completion:^(BOOL finished) {
            // Scale down
            [UIView animateWithDuration:0.25 animations:^{
                self.alert.transform = CGAffineTransformScale(self.alert.transform, 0.95f, 0.95f);
            }];
        }];
    
    }];
    

    
}

-(IBAction)dismissAlert:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alert.transform = CGAffineTransformScale(self.alert.transform, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [self.alert removeFromSuperview];
    }];
    
}


@end
