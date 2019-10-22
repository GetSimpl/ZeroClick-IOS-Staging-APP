//
//  GSUtilities.m
//  GetSimpl
//
//  Created by Alok Jha on 20/06/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import "GSUtilities.h"
#import "GSConstants.h"
#import "GSReachability.h"
#import "UICKeyChainStore.h"
#include <sys/sysctl.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>
#import <DeviceCheck/DeviceCheck.h>

#ifdef SimplZeroClick
#import "GSZeroClickTokenHandler.h"
#import "SimplZeroClick.h"
#endif

#ifdef SimplFingerPrint
#import "SimplFingerPrint.h"
#import "GSFingerPrint.h"
#endif

#ifdef SimplOneClick
#import "VersionMarker.h"
#import "SimplOneClick.h"
#endif

@implementation GSUtilities

+(NSString *) sdkVersion {
    
    NSString *ver = GS_SDK_VERSION ;
    
#ifdef SimplOneClick
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [VersionMarker class]] infoDictionary];
    ver = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
#endif
    
#ifdef SimplZeroClick
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [GSZeroClickTokenHandler class]] infoDictionary];
    ver  = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
#endif
    
#ifdef SimplFingerPrint
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [GSFingerPrint class]] infoDictionary];
    ver  = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
#endif
    
    return ver ;

}

+(NSString *)carrierName {
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    return [carrier carrierName];
}
    
+(NSString *)upTime {
    
    struct timeval boottime;
    
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    
    size_t size = sizeof(boottime);
    
    time_t now;
    
    time_t uptime = -1;
    
    (void)time(&now);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        
        uptime = now - boottime.tv_sec;
        
    }
    
    return [[NSNumber numberWithLong:uptime] stringValue] ;
}
    
+(NSString *)parentAppVersion {
    
    return  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];;
}

+(NSString *)parentAppName {
    
    return  [[NSBundle mainBundle]
             objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}
    
+(NSString *)deviceOSVersion {
    
    return [[UIDevice currentDevice] systemVersion] ;
}
    
+(NSString *)latLon {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        CLLocation *location = [[CLLocationManager alloc] init].location;
        
        if (location) {
            
            CLLocationCoordinate2D coord = location.coordinate ;
            
            return [NSString stringWithFormat:@"%f,%f" , coord.latitude , coord.longitude];
        }
        
    }
    
    return nil ;
}
    
+(BOOL) isRooted {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"])
    {
        return YES;
    }
    
    FILE *f = NULL ;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r")))  {
        fclose(f);
        return YES;
    }
    fclose(f);
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    if(error == nil)
    {
        return YES;
    }
    
#endif
    
    return NO;
}
    
+(NSString *) batteryLife {
    
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    float batLeft = [myDevice batteryLevel]*100;
    
    return [NSString stringWithFormat:@"%0.2f" , batLeft] ;
}
    
+(NSString *)modelName {
        
        int name[] = {CTL_HW,HW_MACHINE};
        size_t size = 100;
        sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
        char *hw_machine = malloc(size);
        
        sysctl(name, 2, hw_machine, &size, NULL, 0);
        NSString *hardware = [NSString stringWithUTF8String:hw_machine];
        free(hw_machine);
        
        if ([hardware isEqualToString:@"x86_64"] || [hardware isEqualToString:@"i386"]) {
            
            NSString *model = [UIDevice currentDevice].model;
            
            if ([model rangeOfString:@"Simulator"].location != NSNotFound) {
                
                hardware = [model componentsSeparatedByString:@" "][0];
            }
            
        }
        
        return hardware;
}
    
+(NSString *)wifiName {
    
    NSString *wifiName = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
            break;
        }
    }
    return wifiName;
}

+ (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)deviceOSName {
    return [UIDevice currentDevice].systemName;
}

+ (NSString *)identifierForVendor {
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    if(uuid != nil) {
        return [uuid UUIDString];
    }
    return @"";
}

+ (NSString *)deviceLanguage {
    NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
    if(preferredLanguages != nil && preferredLanguages.count > 0) {
        return preferredLanguages.firstObject;
    }
    return @"";
}

+ (NSString *)advertisingIdentifier {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)totalMemeory {
    long long memory = [NSProcessInfo processInfo].physicalMemory;
    return [NSString stringWithFormat:@"%lld", memory];
}

+ (NSString *)diskSpace {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory()
                                                                                           error:nil];
    NSNumber *diskSpace = [fileAttributes objectForKey:NSFileSystemSize];
    return [diskSpace stringValue];
}

+ (NSString *)internetConnectionType {
    GSReachability *reachability = [GSReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWiFi) {
        return @"wifi";
    }
    else if (status == ReachableViaWWAN) {
        return @"3G";
    }
    
    return @"";
}

+ (void) getDeviceCheckTokenWithCallback:(void (^)(NSString*)) callback {
    if (@available(iOS 11.0, *)) {
        DCDevice *device = [DCDevice currentDevice];
        if ([device isSupported]) {
            [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                if(error != nil) {
                    callback(error.description);
                } else {
                    callback([token base64EncodedStringWithOptions:0]);
                }
            }];
        } else {
            callback([GSUtilities getDeviceCheckTokenFromKeyChain]);
        }
    } else {
        callback([GSUtilities getDeviceCheckTokenFromKeyChain]);
    }
}

+ (NSString*) getDeviceCheckTokenFromKeyChain {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier]];
    NSString *key = @"SimplDeviceCheckToken";
    NSString *savedUUID = [keychain stringForKey:key];
    if(savedUUID != nil) {
        return savedUUID;
    } else {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [keychain setString:uuid forKey:key];
        return uuid;
    }
}

+ (void) getIPWithCallback:(void (^)(NSString*)) callback {
    [GSUtilities getWithURL:@"https://approvals-api.getsimpl.com/my-ip" callback:callback];
}


+ (void) getWithURL:(NSString *)url callback:(void (^)(NSString*)) callback {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:.3];
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          if(error == nil) {
              NSError* error;
              NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
              if(error == nil) {
                  NSString *ip = [json objectForKey:@"ip"];
                  callback(ip);
              } else {
                  callback([error description]);
              }
          } else {
              if([error code] == NSURLErrorTimedOut) {
                  callback(@"timedout");
              } else {
                  callback([error description]);
              }
          }
          
      }] resume];
    
}
    
@end
