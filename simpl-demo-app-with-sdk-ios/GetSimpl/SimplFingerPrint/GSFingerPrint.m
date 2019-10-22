//
//  FingerPrint.m
//  FingerPrint
//
//  Created by Alok Jha on 08/09/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import "GSFingerPrint.h"
#import "NSString+AESCrypt.h"
#import "GSConstants.h"
#import "GSUtilities.h"
#import "Extensions.h"
#import "GSGuard.h"

static ConstantString EncrytionKey = @"f5460b75f7f24065";

@interface GSFingerPrint ()
{
    NSString *merchant_ID;
    GSUser *simplUser;
}

@end

@implementation GSFingerPrint

-(instancetype _Nonnull ) initWithMerchantId:(NSString * __nonnull) merchantID andUser:(GSUser * __nonnull)user  {
    self = [super init];
    
    return [GSGuard<GSFingerPrint *> guard:^GSFingerPrint *{
        if (self) {
            merchant_ID = merchantID;
            simplUser = user;
        }
        return self;
    } withDefaultValue:self];
    return self;
}

-(void) generateEncryptedPayloadWithCallback:(void(^)(NSString*)) callback {
    [GSGuard guardWithCallback:^{
        [self simplParamsWithCallback:^(NSMutableDictionary *params) {
            callback([self encryptPayload:params]);
        }];
    } errorCallback:^(NSError * error) {
        callback([error description]);
    }];
    
}

- (NSString *) encryptPayload:(NSMutableDictionary *) payload {
    if (![NSJSONSerialization isValidJSONObject:payload]) {
        return @"Error: Unable to serialize payload";
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload
                                                       options:0
                                                         error:&error];
    if(error) {
        return [error localizedDescription];
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *encryptedPayload = [jsonString AES128EncryptWithKey:EncrytionKey];
    return encryptedPayload;
}

-(void)simplParamsWithCallback:(void(^)(NSMutableDictionary*)) callback {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[@"merchant_id"] = merchant_ID;
    params[@"phone_number"] = simplUser.phoneNumber;
    
    
    if (simplUser.email != nil && simplUser.email.length > 0 && [simplUser.email isValidEmail]) {
        params[@"email"] = simplUser.email ; 
    }
    
    if (simplUser.headerParams != nil) {
        
        for (NSString *aKey in [simplUser.headerParams allKeys]) {
            
            NSString *aValue = [simplUser.headerParams valueForKey:aKey];
            params[aKey] = aValue;
        }
        
    }
    params[GS_PHONE_HEADER] = simplUser.phoneNumber;
    params[GS_SDK_VERSION_HEADER] = [GSUtilities sdkVersion];
    params[GS_DEVICE_MANUFACTURER_HEADER] = GS_DEVICE_MANUFACTURER_NAME;
    params[GS_DEVICE_MODEL_HEADER] = [GSUtilities modelName];
    params[GS_PARENT_APP_VERSION_HEADER] = [GSUtilities parentAppVersion];
    params[GS_PARENT_APP_NAME_HEADER] = [GSUtilities parentAppName];
    params[GS_DEVICE_OS_VERSION_HEADER] = [GSUtilities deviceOSVersion];
    params[GS_BATTERY_LIFE_HEADER] = [GSUtilities batteryLife];
    
    NSString *wifiName = [GSUtilities wifiName] ;
    if (wifiName) {
        params[GS_DEVICE_WIFI_HEADER] = wifiName;
    }
    
    NSString *carrierName = [GSUtilities carrierName] ;
    if (carrierName) {
        params[GS_CARRIER_NAME_HEADER] = carrierName;
    }
    
    NSString *upTime = [GSUtilities upTime] ;
    if (upTime) {
        params[GS_UPTIME_HEADER] = upTime;
    }
    
    NSString *isRooted = [GSUtilities isRooted] ? @"true" : @"false" ;
    params[GS_ROOTED_HEADER] = isRooted;
    
    NSString *latLon = [GSUtilities latLon];
    if (latLon) {
        params[GS_LATLON_HEADER] = latLon;
    }
    
    NSString *deviceName = [GSUtilities deviceName];
    if(deviceName) {
        params[GS_DEVICE_NAME_HEADER] = deviceName;
    }
    
    NSString *OSName = [GSUtilities deviceOSName];
    if(OSName) {
        params[GS_DEVICE_OS_NAME_HEADER] = OSName;
    }
    
    NSString *deviceLanguage = [GSUtilities deviceLanguage];
    if(deviceLanguage) {
        params[GS_DEVICE_LANGUAGE_HEADER] = deviceLanguage;
    }
    
    NSString *vendorId = [GSUtilities identifierForVendor];
    if(vendorId) {
        params[GS_DEVICE_IDENTIFIER_FOR_VENDOR_HEADER] = vendorId;
    }
    
    NSString *advertisingId = [GSUtilities advertisingIdentifier];
    if(advertisingId) {
        params[GS_DEVICE_ADVERTISING_IDENTIFIER_HEADER] = advertisingId;
    }
    
    NSString *totalMemeory = [GSUtilities totalMemeory];
    if(totalMemeory) {
        params[GS_DEVICE_AVAILABLE_MEMORY_HEADER] = totalMemeory;
    }
    
    NSString *diskSpace = [GSUtilities diskSpace];
    if(diskSpace) {
        params[GS_DEVICE_DISK_SPACE_HEADER] = diskSpace;
    }
    
    NSString *connectionType = [GSUtilities internetConnectionType];
    if(connectionType) {
        params[GS_DEVICE_CONNECTION_TYPE_HEADER] = connectionType;
    }
    
    [GSUtilities getDeviceCheckTokenWithCallback:^(NSString *token) {
        if(token){
            params[GS_DEVICE_CHECK_TOKEN_HEADER] = token;
        }
        
        [GSUtilities getIPWithCallback:^(NSString *ip) {
            if(ip) {
                params[GS_DEVICE_IP_ADDRESS_HEADER] = ip;
            }
            callback(params);
        }];
        
    }];    
}

@end
