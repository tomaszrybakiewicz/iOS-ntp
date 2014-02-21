//
//  ViewController.m
//  ntpDemo
//
//  Created by ryba on 2/21/14.
//  Copyright (c) 2014 Tomasz Rybakiewicz. All rights reserved.
//

#import "ViewController.h"
#import <iOS-ntp/NetworkClock.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTime];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)updateTime {
    NSDate *systemTime = [NSDate date];
    NSDate *networkTime = [[NetworkClock sharedInstance] networkTime];
    NSTimeInterval difference = [networkTime timeIntervalSinceDate:systemTime];
    
    self.systemTimeLabel.text =  [NSString stringWithFormat:@"system:  %@", systemTime];
    self.networkTimeLabel.text = [NSString stringWithFormat:@"network: %@", networkTime];
    self.differenceLabel.text = [NSString stringWithFormat:@"difference: %5.3f sec", difference];
}

@end
