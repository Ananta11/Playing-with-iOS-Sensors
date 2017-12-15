//
//  ViewController.m
//  ReverseGeoCode
//
//  Created by Ananta Shahane on 19/08/17.
//  Copyright © 2017 Ananta Shahane. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;
#import "MapKit/Mapkit.h"

@interface ViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *geoCodeLabel;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (weak, nonatomic) IBOutlet UIImageView *centerPin;
@property (assign, nonatomic) BOOL lookingUp;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.geoCoder = [[CLGeocoder alloc] init];
    self.geoCodeLabel.text = nil;
    self.geoCodeLabel.alpha = 0.5;
    self.lookingUp = NO;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self executeLookUp];
}

-(void) executeLookUp
{
    if(self.lookingUp == NO)
    {
        CLLocationCoordinate2D coord = [self locationAtCenterOfMapView];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        [self startReverseGeoCode:loc];
    }
}

-(CLLocationCoordinate2D) locationAtCenterOfMapView{
    CGPoint centerOfPin = CGPointMake(CGRectGetMidX(self.centerPin.bounds), CGRectGetMaxY(self.centerPin.bounds));
    return [self.mapView convertPoint:centerOfPin toCoordinateFromView:self.centerPin];
}

-(void) startReverseGeoCode: (CLLocation *) location
{
    self.geoCodeLabel.enabled = NO;
    [self.geoCoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray * placeMarks, NSError * error){
         if(error){
             UIAlertController *ac = [UIAlertController alertControllerWithTitle: @"There was a problem reverse geocoding..." message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:ac animated:YES completion:nil];
             return;
         }
         NSMutableSet *mapedPlacesDescs = [NSMutableSet new];
         for (CLPlacemark *p  in placeMarks)
         {
             if(p.name != nil)
             {
                 [mapedPlacesDescs addObject:p.name];
             }
             if(p.administrativeArea != nil)
             {
                 [mapedPlacesDescs addObject:p.administrativeArea];
             }
             if(p.country != nil)
             {
                 [mapedPlacesDescs addObject:p.country];
             }
             self.geoCodeLabel.text = [[mapedPlacesDescs allObjects] componentsJoinedByString:@"\n"];
         }
     }
     ];
    self.geoCodeLabel.alpha = 1.0;
    self.geoCodeLabel.enabled = YES;
}

@end
