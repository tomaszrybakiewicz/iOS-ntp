//
//  AppDelegate.m
//  ntpDemo
//
//  Created by ryba on 2/21/14.
//  Copyright (c) 2014 Tomasz Rybakiewicz. All rights reserved.
//

#import "AppDelegate.h"
#import <iOS-ntp/NetworkClock.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NetworkClock clockWithNTPHostsFile:[[NSBundle mainBundle] pathForResource:@"ntp.hosts" ofType:@""]];
    
    // Alternatively:
//    [NetworkClock clockWithNTPHosts:@[
//        @"time.apple.com",
//        @"south-america.pool.ntp.org alwaystrust"
//    ]];
    return YES;
}

@end
