//
//  GSUtilities.h
//  GetSimpl
//
//  Created by Alok Jha on 20/06/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface GSUtilities : NSObject
    
+(NSString *) carrierName ;
+(NSString *) upTime ;
+(NSString *) parentAppVersion ;
+(NSString *) parentAppName;
+(NSString *) deviceOSVersion ;
+(NSString *) latLon ;
+(NSString *) modelName ;
+(NSString *) wifiName ;
+(BOOL) isRooted ;
+(NSString *) batteryLife;
+(NSString *) sdkVersion;
+ (NSString *)deviceName;
+ (NSString *)deviceOSName;
+ (NSString *)identifierForVendor;
+ (NSString *)deviceLanguage;
+ (NSString *)advertisingIdentifier;
+ (NSString *)totalMemeory;
+ (NSString *)diskSpace;
+ (NSString *)internetConnectionType;
+ (void) getDeviceCheckTokenWithCallback:(void (^)(NSString*)) callback;
+ (void) getIPWithCallback:(void (^)(NSString*)) callback;

@end
