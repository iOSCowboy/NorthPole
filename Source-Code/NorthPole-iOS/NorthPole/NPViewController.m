//
//  NPViewController.m
//  NorthPole
//
//  Created by Hector Zarate on 11/30/13.
//  Copyright (c) 2013 Hector Zarate. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "NPViewController.h"
#import <PebbleKit/PebbleKit.h>


static const CLLocationDistance NPDefaultDistanceFilter         = 0.0;  // [m]
static const NSTimeInterval NPDefaultRecentTimeInterval         = 15.0; // [s]

@interface NPViewController () <CLLocationManagerDelegate, PBPebbleCentralDelegate>

@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;

@property (nonatomic, strong) PBWatch* pebbleWatch;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupCoreLocation];
    [self setupPebble];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPebble
{
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"com.mieldemaple.NorthPole"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    self.pebbleWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [PBPebbleCentral defaultCentral].delegate = self;
    
    
    
    
}



- (void)setupCoreLocation
{
    
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    // TODO: Consider and ponder Significant-Change Location Service
    [locationManager startUpdatingLocation];
    
    self.locationManager = locationManager;
}

- (void) setupPebbleWatch: (PBWatch *)paramPebbleWatch
{

}


#pragma mark - LocationManagerDelegate


-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    CLLocation* lastLocation = [locations lastObject];
    NSDate *timestampForLastLocation  = lastLocation.timestamp;
    
    NSTimeInterval howRecentLocationIs = [timestampForLastLocation timeIntervalSinceNow];
    
    if (abs(howRecentLocationIs) < NPDefaultRecentTimeInterval)
    {
        self.altitudeLabel.text = [NSString stringWithFormat:@"%0.3f m", lastLocation.altitude];
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"There was an error while retrieving location"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}


#pragma mark - Pebble WatchDelegate

- (void)pebbleCentral:(PBPebbleCentral*)central
      watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew
{
    self.pebbleWatch = watch;
    
    NSDictionary *update = @{ @(0):[NSNumber numberWithUint8:42],
                              @(1):@"a string" };
    
    [self.pebbleWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent message.");
        }
        else {
            NSLog(@"Error sending message: %@", error);
        }
    }];
    
    
}


- (void)pebbleCentral:(PBPebbleCentral*)central
   watchDidDisconnect:(PBWatch*)watch
{
    
    if (self.pebbleWatch == watch ||
        [watch isEqual:self.pebbleWatch])
    {
        self.pebbleWatch = nil;
    }
}


@end
