//
//  ViewController.m
//  GeoFenceing
//
//  Created by Ananta Shahane on 22/08/17.
//  Copyright © 2017 Ananta Shahane. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *UiSwitch;
@property (weak, nonatomic) IBOutlet UIButton *CheckStatus;
@property (weak, nonatomic) IBOutlet UILabel *StatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *EventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL mapISMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@property (strong, nonatomic) CLCircularRegion *geoRegion;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.UiSwitch.enabled = NO;
    self.CheckStatus.enabled = NO;
    
    self.mapISMoving = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;  //3 meters
    
    CLLocationCoordinate2D noLocation;
    noLocation.longitude = 73;
    noLocation.latitude = 53;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
    
    [self addCurrentAnnotation];
    
    [self InitialiseGeoRegion];
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES)
    {
        CLAuthorizationStatus currentStatus;
        currentStatus = [CLLocationManager authorizationStatus];
        if(currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse || currentStatus == kCLAuthorizationStatusAuthorizedAlways)
        {
            self.UiSwitch.enabled = YES;
        }
        else
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        UIUserNotificationType types = UIUserNotificationTypeBadge| UIUserNotificationTypeSound| UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    else
    {
        self.StatusLabel.text = @"Regions !supported";
    }
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    if(currentStatus == kCLAuthorizationStatusAuthorizedAlways || currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        self.UiSwitch.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.mapISMoving = YES;
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.mapISMoving = NO;
}

- (IBAction)SwitchClicked:(id)sender {
    if(self.UiSwitch.isOn)
    {
        self.MapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        self.CheckStatus.enabled = YES;
        [self.locationManager startMonitoringForRegion:self.geoRegion];
    }
    else
    {
        self.CheckStatus.enabled = NO;
        [self.locationManager stopUpdatingLocation];
        self.MapView.showsUserLocation = NO;
        [self.locationManager stopMonitoringForRegion:self.geoRegion];
    }
}

-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle =@"GeoFence alert.";
    note.alertBody = @"You have reached home.";
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.EventLabel.text = @"Reached Home";
}

-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"GeoFence Alert";
    note.alertBody = @"You have left the home.";
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.EventLabel.text = @"Outside";
}

-(void) addCurrentAnnotation
{
    self.currentAnno = [[MKPointAnnotation alloc] init];
    self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnno.title = @"My Location";
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.currentAnno.coordinate = locations.lastObject.coordinate;
    if(self.mapISMoving == NO)
    {
        [self centerMap:self.currentAnno];
    }
}

-(void) centerMap: (MKPointAnnotation * ) location
{
    [self.MapView setCenterCoordinate:location.coordinate animated:YES];
}

-(void) InitialiseGeoRegion
{
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(21.173767, 79.036846) radius:3 identifier:@"Home"];
}

- (IBAction)clickStatusCheck:(id)sender
{
    [self.locationManager requestStateForRegion:self.geoRegion];
}

-(void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region
{
    switch (state)
    {
        case CLRegionStateInside:
            self.StatusLabel.text = @"Inside Region";
            break;
        case CLRegionStateUnknown:
            self.StatusLabel.text = @"Unknown";
            break;
        case CLRegionStateOutside:
            self.StatusLabel.text = @"Outside Region";
            break;
        default:
            break;
    }
}

@end
