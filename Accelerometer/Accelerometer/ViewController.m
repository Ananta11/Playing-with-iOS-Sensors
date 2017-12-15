//
//  ViewController.m
//  Accelerometer
//
//  Created by Ananta Shahane on 08/11/17.
//  Copyright © 2017 Ananta Shahane. All rights reserved.
//

#import "ViewController.h"
#import "CoreMotion/CoreMotion.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *StaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *DynamicLabel;
@property (weak, nonatomic) IBOutlet UIButton *StaticButton;
@property (weak, nonatomic) IBOutlet UIButton *StartDynamicButton;
@property (weak, nonatomic) IBOutlet UIButton *StopDynamicButton;
@property (strong, nonatomic) CMMotionManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (assign, nonatomic) double x,y,z;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.StaticLabel.text = @"No Data";
    self.DynamicLabel.text = @"No Data";
    self.image.layer.cornerRadius = 150;
    self.image.layer.masksToBounds = YES;
    self.StaticButton.enabled = NO;
    self.StartDynamicButton.enabled = NO;
    self.StopDynamicButton.enabled = NO;
    self.manager = [[CMMotionManager alloc] init];
    if(self.manager.accelerometerAvailable)
    {
        self.StaticButton.enabled = YES;
        self.StartDynamicButton.enabled = YES;
        [self.manager startAccelerometerUpdates];
    }
    else
    {
        self.StaticLabel.text = self.DynamicLabel.text = @"Accelerometer not available.";
    }
    self.x = 0;
    self.y = 0;
    self.z = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)StaticCall:(id)sender {
    CMAccelerometerData *Acceleration = [self.manager accelerometerData];
    if(Acceleration != nil)
    {
        CMAcceleration acceleration = Acceleration.acceleration;
        self.StaticLabel.text = [NSString stringWithFormat:@"%lfî + %lfĵ + %lfǩ",acceleration.x, acceleration.y, acceleration.z];
    }
}

- (IBAction)DynamicStart:(id)sender {
    [self.manager startAccelerometerUpdates];
    self.StartDynamicButton.enabled = NO;
    self.StopDynamicButton.enabled = YES;
    self.manager.accelerometerUpdateInterval = 0.01;
    ViewController *__weak weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        double x = accelerometerData.acceleration.x;
        double y = accelerometerData.acceleration.y;
        double z = accelerometerData.acceleration.z;
        self.x = .9*self.x + .1*x;
        self.y = .9*self.y + .1*y;
        self.z = .9*self.z + .1*z;
        double rotation  = -atan2(self.x,-self.y);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.DynamicLabel.text = [NSString stringWithFormat:@"%lfî + %lfĵ + %lfǩ",x, y, z];
            weakSelf.image.transform = CGAffineTransformMakeRotation(rotation);
        }];
        
    }];
}
- (IBAction)StopDynamic:(id)sender {
    [self.manager stopAccelerometerUpdates];
    self.StopDynamicButton.enabled = NO;
    self.StartDynamicButton.enabled = YES;
}

@end
