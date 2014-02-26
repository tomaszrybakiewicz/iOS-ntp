/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║  NetworkClock.m                                                                                  ║
  ║                                                                                                  ║
  ║  Created by Gavin Eadie on Oct17/10                                                              ║
  ║  Copyright 2010 Ramsay Consulting. All rights reserved.                                          ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import "NetworkClock.h"
#import "AsyncUdpSocket.h"
#import "NetAssociation.h"

#import <arpa/inet.h>

#define kDefaultNTPHostsFile [[NSBundle mainBundle] pathForResource:@"ntp.hosts" ofType:@""]

//////////////////////////////////
// Shared Instance

static NetworkClock  *sharedInstance = nil;

///////////////////////////////////

@interface NetworkClock ()
@property (strong, nonatomic, readwrite) NSMutableArray *timeAssociations;
@property (strong, nonatomic) NSSortDescriptor *dispersionSortDescriptor;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (assign, nonatomic) NSTimeInterval timeIntervalSinceDeviceTime;

@end

@implementation NetworkClock

+ (instancetype) sharedInstance {
    if (nil == sharedInstance) {
        return [NetworkClock clockWithNTPHostsFile:kDefaultNTPHostsFile];
    }
    return sharedInstance;
}

+ (void)setSharedInstance:(NetworkClock *)instance {
    sharedInstance = instance;
}

+ (instancetype)clockWithNTPHostsFile:(NSString *)filePath {
    return [[NetworkClock alloc] initWithNTPHostsFile:filePath];
}

+ (instancetype)clockWithNTPHosts:(NSArray *)ntpHosts {
    return [[NetworkClock alloc] initWithNTPHosts:ntpHosts];
}

- (id)initWithNTPHostsFile:(NSString *)filePath {
    self = [super init];
    if (self) {
        [self setupSortDescriptors];
        [self setupTimeAssociationsFromFile:filePath];
        [self subscribeToAppBackgroundNotifications];
        [self subscribeToTimeAssociationNotifications];
        
        if (nil == sharedInstance) {
            [NetworkClock setSharedInstance:self];
        }
    }
    return self;
}

- (id)initWithNTPHosts:(NSArray *)ntpHosts {
    self = [super init];
    if (self) {
        [self setupSortDescriptors];
        [self setupTimeAssociationsFromArray:ntpHosts];
        [self subscribeToAppBackgroundNotifications];
        [self subscribeToTimeAssociationNotifications];

        if (nil == sharedInstance) {
            [NetworkClock setSharedInstance:self];
        }
    }
    return self;
}

#pragma mark - Setup methods

- (void)setupSortDescriptors {
    // Prepare a sort-descriptor to sort associations based on their dispersion
    self.dispersionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dispersion" ascending:YES];
    self.sortDescriptors = @[self.dispersionSortDescriptor];
}

- (void)setupTimeAssociationsFromFile:(NSString *)filePath {
    NSArray *ntpDomains = [self loadDomainNamesFromFile:filePath];
    NSDictionary *hostAddresses = [self resolveDomainAddressesFromArray:ntpDomains];
    
    // start an 'association' (network clock object) for each address.
    self.timeAssociations = [NSMutableArray arrayWithCapacity:48];
    for (NSString *server in [hostAddresses allKeys]) {
        NSString *ipAddress = hostAddresses[server][@"address"];
        NetAssociation *timeAssociation = [NetAssociation associationWithServerIpAddress:ipAddress];
        timeAssociation.alwaysTrust = [hostAddresses[server][@"alwaystrust"] boolValue];
        [self.timeAssociations addObject:timeAssociation];
        [timeAssociation enable]; // starts are randomized internally
    }
}

- (void)setupTimeAssociationsFromArray:(NSArray *)ntpHosts {
    NSDictionary *hostAddresses = [self resolveDomainAddressesFromArray:ntpHosts];
    
    // start an 'association' (network clock object) for each address.
    self.timeAssociations = [NSMutableArray arrayWithCapacity:48];
    for (NSString *server in [hostAddresses allKeys]) {
        NSString *ipAddress = hostAddresses[server][@"address"];
        NetAssociation *timeAssociation = [NetAssociation associationWithServerIpAddress:ipAddress];
        timeAssociation.alwaysTrust = [hostAddresses[server][@"alwaystrust"] boolValue];
        [self.timeAssociations addObject:timeAssociation];
        [timeAssociation enable]; // starts are randomized internally
    }
}

- (void)subscribeToAppBackgroundNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBack:)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationFore:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)subscribeToTimeAssociationNotifications {
    // get ready to catch any notifications from associations ...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associationTrue:)
                                                 name:@"assoc-good" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associationFake:)
                                                 name:@"assoc-fail" object:nil];
}

- (void)unsubscribeFromAllNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public

// Return the device clock time adjusted for the offset to network-derived UTC.  Since this could
// be called very frequently, we recompute the average offset every 30 seconds.
- (NSDate *) networkTime {
    return [[NSDate date] dateByAddingTimeInterval:-self.timeIntervalSinceDeviceTime];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"net-time" object:self];
}

#pragma mark - TimeAssociations Init

// Stop all the individual ntp clients ..
- (void) finishAssociations {
    for (NetAssociation * timeAssociation in self.timeAssociations) {
        [timeAssociation finish];
    }
    [self unsubscribeFromAllNotifications];
}


- (NSArray *)loadDomainNamesFromFile:(NSString *)filePath {
    NSString *fileData = [[NSString alloc] initWithData:[[NSFileManager defaultManager]
                                                         contentsAtPath:filePath]
                                               encoding:NSUTF8StringEncoding];
    
    return [fileData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

// for each NTP service domain name in the 'ntp.hosts' file : "0.pool.ntp.org" etc
// resolve the IP address of the named host : "0.pool.ntp.org" --> [123.45.67.89], ...
- (NSDictionary *)resolveDomainAddressesFromArray:(NSArray *)domains {
    NSMutableDictionary *hostAddresses = [NSMutableDictionary dictionaryWithCapacity:48];
    
    for (NSString * ntpDomainName in domains) {
        if ([ntpDomainName length] == 0 ||
            [ntpDomainName characterAtIndex:0] == ' ' || [ntpDomainName characterAtIndex:0] == '#') {
            continue;
        }
        CFStreamError       nameError;
        Boolean             nameFound;
        
        NSArray *entryComponents = [ntpDomainName componentsSeparatedByString:@" "];
        BOOL alwaysTrust = (1 < [entryComponents count] && [@"alwaystrust" isEqualToString:entryComponents[1]]);
                                                            
        CFHostRef ntpHostName = CFHostCreateWithName (kCFAllocatorDefault, (__bridge CFStringRef)entryComponents[0]);
        if (ntpHostName == nil) {
            LogInProduction(@"CFHostCreateWithName ntpHost <nil>");
            continue;                                           // couldn't create 'host object' ...
        }
        
        if (!CFHostStartInfoResolution (ntpHostName, kCFHostAddresses, &nameError)) {
            LogInProduction(@"CFHostStartInfoResolution error %i", (int)nameError.error);
            CFRelease(ntpHostName);
            continue;                                           // couldn't start resolution ...
        }
        
        CFArrayRef ntpHostAddrs = CFHostGetAddressing (ntpHostName, &nameFound);
        
        if (!nameFound) {
            LogInProduction(@"CFHostGetAddressing: NOT resolved");
            CFRelease(ntpHostName);
            continue;                                           // resolution failed ...
        }
        
        if (ntpHostAddrs == nil) {
            LogInProduction(@"CFHostGetAddressing: no addresses resolved");
            CFRelease(ntpHostName);
            continue;                                           // NO addresses were resolved ...
        }
        
        // for each (sockaddr structure wrapped by a CFDataRef/NSData *) associated with the hostname,
        // drop the IP address string into a Set to remove duplicates.
        for (NSData * ntpHost in (__bridge NSArray *)ntpHostAddrs) {
            hostAddresses[ntpDomainName] = @{@"address": [self hostAddress:(struct sockaddr_in *)[ntpHost bytes]],
                                             @"alwaystrust": @(alwaysTrust)};
//            [hostAddresses addObject:[self hostAddress:(struct sockaddr_in *)[ntpHost bytes]]];
        }
        CFRelease(ntpHostName);
    }
    return hostAddresses;
}

// obtain IP address, "xx.xx.xx.xx", from the sockaddr structure
- (NSString *) hostAddress:(struct sockaddr_in *) sockAddr {
	char addrBuf[INET_ADDRSTRLEN];
	if (inet_ntop(AF_INET, &sockAddr->sin_addr, addrBuf, sizeof(addrBuf)) == NULL) {
		[NSException raise:NSInternalInconsistencyException
                    format:@"Cannot convert address to string."];
	}
	return @(addrBuf);
}

#pragma mark - TimeAssociation Notifications

// associationTrue -- notification from a 'truechimer' association of a trusty offset
- (void) associationTrue:(NSNotification *) notification {
    NTP_Logging(@"*** true association: %@ (%i left)",
                    [notification object], [self.timeAssociations count]);
    [self offsetAverage];
}

// associationFake -- notification from an association that became a 'falseticker'
// .. if we already have 8 associations in play, drop this one.
- (void) associationFake:(NSNotification *) notification {
    if ([self.timeAssociations count] > 8) {
        NetAssociation *    association = [notification object];
        NTP_Logging(@"*** false association: %@ (%i left)", association, [self.timeAssociations count]);
        [self.timeAssociations removeObject:association];
        [association finish];
        association = nil;
    }
}


// be called very frequently, we recompute the average offset every 30 seconds.
- (void) offsetAverage {
    self.timeIntervalSinceDeviceTime = 0.0;
    
    short assocsTotal = [self.timeAssociations count];
    if (assocsTotal == 0) return;
    
    NSArray *sortedArray = [self.timeAssociations sortedArrayUsingDescriptors:self.sortDescriptors];
    short usefulCount = 0;
    
    for (NetAssociation * timeAssociation in sortedArray) {
        BOOL isValidOffset = (timeAssociation.offset < -0.0000001 || 0.0000001 < timeAssociation.offset);
        BOOL isTrusty = (timeAssociation.alwaysTrust && timeAssociation.trusty);
        if (isValidOffset && isTrusty) {
            usefulCount++;
            self.timeIntervalSinceDeviceTime += timeAssociation.offset;
        }
        if (usefulCount == 8) break;                // use 8 best dispersions
    }
    
    if (usefulCount > 0) {
        self.timeIntervalSinceDeviceTime /= usefulCount;
    }
}

#pragma mark - Application Notifications

// applicationBack -- catch the notification when the application goes into the background
- (void) applicationBack:(NSNotification *) notification {
    LogInProduction(@"*** application -> Background");
//  [self finishAssociations];
}


// applicationFore -- catch the notification when the application comes out of the background       ┃
- (void) applicationFore:(NSNotification *) notification {
    LogInProduction(@"*** application -> Foreground");
//  [self enableAssociations];
}


@end