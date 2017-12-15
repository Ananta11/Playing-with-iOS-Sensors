//
//  ViewController.m
//  DeviceMotionDemo
//
//  Created by Ananta Shahane on 14/12/17.
//  Copyright © 2017 Ananta Shahane. All rights reserved.
//

#import "ViewController.h"
#import "CoreMotion/CoreMotion.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) CMMotionManager *CMManager;
@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) int imageCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = @[[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"], [UIImage imageNamed:@"3.jpg"], [UIImage imageNamed:@"4.jpg"]];
    
    self.imageCount = 0;
    [self chooseImage];
    
    self.CMManager = [[CMMotionManager alloc] init];
    [self.CMManager startAccelerometerUpdates];
    self.CMManager.accelerometerUpdateInterval = 1/60;
    
    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryZVertical;
//    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
//    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXMagneticNorthZVertical;
//    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXTrueNorthZVertical;
    
    
    
    ViewController * __weak weakSelf = self;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [self.CMManager startDeviceMotionUpdatesUsingReferenceFrame:frame toQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        double x = motion.userAcceleration.x;
        double y = motion.userAcceleration.y;
        double z = motion.userAcceleration.z;
        
        double bump = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
        
        if(bump > 3.0)
        {
            self.imageCount = ++self.imageCount%4;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self chooseImage];
        }];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)chooseImage
{
    self.ImageView.image = self.images[self.imageCount];
}

@end
