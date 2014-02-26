/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ NetAssociation.h                                                                                 ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Nov03/10. Updated by Tomasz Rybakiewicz on Feb20/14.                   ║
  ║ Copyright 2010 Ramsay Consulting. All rights reserved.                                           ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

/**
 NetAssociation represents one time server.  When it is created, it sends the first time query,
 evaluates the quality of the reply, and keeps the queries running till the server goes 'bad'
 or its creator kills it.
 */
@interface NetAssociation : NSObject

///--------------------------------------
/// @name Initializing an Net Association
///--------------------------------------

/**
 Creates and returns a new `NetAssociation` object initialized with given NTP server IP address.
 
 @param serverIpAddress The NTP server IP address.
 @return A new `NetAssociation` object initialized with the given IP address.
*/
+ (instancetype)associationWithServerIpAddress:(NSString*)serverIpAddress;

/**
 Intializes the receiver with the given ntp server ip address.

 This is the designated initializer.

 @param serverIpAddress The NTP server IP address.
 @return The receiver, initialized with the given ip address.
*/
- (id)initWithServerIpAddress:(NSString *)serverIpAddress;

///-------------------------------------------------------
/// @name Enabling/Disabling Net Association time querying
///-------------------------------------------------------

/**
 This enables time querying. It sets query timer the fire time randonly within the next five seconds.
 */
- (void) enable;

/*
 This stops time querying. It sets query timer the fire time to the infinite future.
 */
- (void) finish;

///-------------------------------------
/// @name Gettings Net Association Stats
///-------------------------------------

/**
 Returns Net Association statistics.
 
 Returned stats are: server, leap_indicator, version_number, protocol_mode, stratum, poll interval, precision_exp, root_delay, dispersion, reference_ID
 
 @return NSDictionary with receiver stats.
 */
- (NSDictionary*)stats;

///-------------------------------------------
/// @name Accessing Net Association Properties
///-------------------------------------------

/**
 Is this clock trustworthy.
 */
@property (readonly) BOOL trusty;

/**
 Offset from device time in seconds.
 */
@property (readonly) double offset;

/**
 Is this clock always trusted.
 */
@property (assign, nonatomic) BOOL alwaysTrust;

@end
