/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ NetworkClock.h                                                                                   ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Oct17/10. Updated by Tomasz Rybakiewicz on Feb20/14.                   ║
  ║ Copyright 2010 Ramsay Consulting. All rights reserved.                                           ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

/**
 The NetworkClock is a singleton class which will provide the best estimate of the difference in time
 between the device's system clock and the time returned by a collection of time servers.
 
 NetworkClock can be initialized with NTP hosts file:

    [[NetworkClock clockWithNTPHostsFile:[[NSBundle mainBundle] pathForResource:@"ntp.hosts" ofType:@""]];
    NSDate *networkTime = [[NetworkClock sharedInstance] networkTime];
 
     // ------ ntp.hosts file ------
     time.apple.com
     192.168.123.12 alwaystrust
     #ignored line
     // --- (END) ntp.hosts file ---
 
 Or it can be initialized with NTP hosts array:
 
    [[NetworkClock clockWithNTPHosts:@[
        @"time.apple.com",
        @"192.168.123.12 alwaystrust"   // 'alwaystrust' flag ignores dispersion and stratum check for this NTP server
    ]];
    NSDate *networkTime = [[NetworkClock sharedInstance] networkTime];
 
 Invoking [NetworkClock sharedInstance] before either [NetworkClock clockWithNTPHostsFile:] or [NetworkClock clockWithNTPHosts:] is equavilent to:
 
    [[NetworkClock clockWithNTPHostsFile:[[NSBundle mainBundle] pathForResource:@"ntp.hosts" ofType:@""]];
 
 */
@interface NetworkClock : NSObject

///----------------------------------------------
/// @name Configuring the Shared Clock Instance
///----------------------------------------------

/**
 Return the shared instance of the network clock
 
 @return The shared clock instance.
 */
+ (instancetype)sharedInstance;

/**
 Set the shared instance of the network clock
 
 @param instance The new shared instance.
 */
+ (void)setSharedInstance:(NetworkClock *)instance;

///-------------------------------------
/// @name Initializing an Network Clock
///-------------------------------------

/**
 Creates and returns a new `NetworkClock` object initialized with a list of `NetAssociation` objects that was in turn initialized with the given NTP hosts file.
 
 @param filePath The full path to NTP hosts file with wich to initialize `NetAssociation` objects.
 @return A new `NetworkClock` object initialized with the given hosts file.
 */
+ (instancetype)clockWithNTPHostsFile:(NSString *)filePath;


/**
 Creates and returns a new `NetworkClock` object initialized with a list of `NetAssociation` objects that was in turn initialized with the given NTP hosts array.
 
 @param ntpHosts The NSArray of NSString NTP hosts with wich to initialize `NetAssociation` objects.
 @return A new `NetworkClock` object initialized with the given hosts array.
 */

+ (instancetype)clockWithNTPHosts:(NSArray *)ntpHosts;

/**
 Intializes the receiver with the given Hosts File path.
 
 This is the designated initializer. If the `sharedInstnace` instance is `nil`, the receive will be set as the `sharedInstnace`.
 
 @param filePath The full path to hosts file with wich to initialize the receiver.
 @return The receiver, initialized with the given hosts file.
 */
- (id)initWithNTPHostsFile:(NSString *)filePath;

/**
 Intializes the receiver with the given Hosts array.
 
 If the `sharedInstnace` instance is `nil`, the receive will be set as the `sharedInstnace`.
 
 @param ntpHosts The NSArray of NSString NTP hosts with wich to initialize `NetAssociation` objects.
 @return The receiver, initialized with the given hosts array.
 */
- (id)initWithNTPHosts:(NSArray *)ntpHosts;

///-------------------------------------
/// @name Requesting Network Time
///-------------------------------------

/**
 Return latest network time.
 
 This method returns the device clock time adjusted for the offset to network-derived UTC. Since this could be called very frequently, the average offset is recomputed  every 30 seconds.
 
 @return The device clock time adjusted for the offset to network-derived UTC.
 */
- (NSDate *)networkTime;


///-----------------------------------------
/// @name Accessing Network Clock Properties
///-----------------------------------------

/**
 Array of all registered `NetAssociation` objects.
 */
@property (strong, nonatomic, readonly) NSMutableArray *timeAssociations;

@end