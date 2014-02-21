//
//  ViewController.h
//  ntpDemo
//
//  Created by ryba on 2/21/14.
//  Copyright (c) 2014 Tomasz Rybakiewicz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *systemTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *differenceLabel;

@end
