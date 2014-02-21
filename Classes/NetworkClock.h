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
+ (void)setSharedInstance:(NetworkClock*)instance;

///-------------------------------------
/// @name Initializing an Network Clock
///-------------------------------------

/**
 Creates and returns a new `NetworkClock` object initialized with a list of `NetAssociation` objects that was in turn initialized with the given NTP hosts file.
 
 @param filePath The full path to NTP hosts file with wich to initialize `NetAssociation` objects.
 @return A new `NetworkClock` object initialized with the given hosts file.
 */
+ (instancetype)clockNTPHostsFile:(NSString*)filePath;

/**
 Intializes the receiver with the given Hosts File path.
 
 This is the designated initializer. If the `sharedInstnace` instance is `nil`, the receive will be set as the `sharedInstnace`.
 
 @param filePath The full path to hosts file with wich to initialize the receiver.
 @return The receiver, initialized with the given hosts file.
 */
- (id)initWithNTPHostsFile:(NSString*)filePath;

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