//
//  Extensions.m
//  GetSimpl
//
//  Created by Alok Jha on 16/09/16.
//  Copyright © 2016 Simpl. All rights reserved.
//


#import "Extensions.h"
#import "GSConstants.h"
#import "GSUtilities.h"
#import "UICKeyChainStore.h"

@implementation TestObject

@end

@implementation NSString (Validity)

-(BOOL)isValidMobileNumber {
    
    NSCharacterSet *notDigits = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
    
    NSRange range = [self rangeOfCharacterFromSet:notDigits options:NSCaseInsensitiveSearch] ;
    
    if  (range.location == NSNotFound) {
        
        if (self.length != 10) {
            return NO;
        }
        else {
            return YES;
        }
        
    }
    
    return NO;
    
}

-(BOOL)isValidEmail {
    
    BOOL stricterFilter = YES;
    
    NSString *strictFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}" ;
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*" ;
    
    NSString *emailRegex = stricterFilter ? strictFilterString : laxString ;
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@" , emailRegex];
    
    return [emailTest evaluateWithObject:self];
    
}

@end


@implementation NSError (Error)

+(NSError *)errorFromErrorCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message {
    
    NSError *error = nil;
    
    NSString *errorDomain = domain != nil ? domain : GS_ERROR_DOMAIN;
    
    NSString *errorMessage = message != nil ? message : @"Verification failed." ;
    
    switch (code) {
            
        case GS_ERROR_CODE_MERCHANTID :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:@"Merchant id not set or is empty"}];
            break;
            
        case GS_ERROR_CODE_UNRESOLVED_RESPONSE :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:GS_UNRESOLVED_ERROR_RESPONSE_MESSAGE}];
            break;
            
        case GS_ERROR_CODE_INVALID_MOBILE :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:GS_INVALID_MOBILE_RESPONSE_MESSAGE}];
            break;
            
        case GS_ERROR_CODE_UIWINDOW :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:@"No UIWindow found to present OTP View"}];
            break;
            
        case GS_ERROR_CODE_CANCEL_PRESSED :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:@"OTP View Dismissed"}];
            break;
            
        case GS_ERROR_CODE_VERIFICATION_FAILED :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
            break;
            
        case GS_ERROR_CODE_EMPTY_HASHEDPHONENUMBER :
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:GS_EMPTY_HASHEDPHONENUMBER_MESSAGE}];
            break;
        case GS_ERROR_CODE_EMAIL:
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:@"Email is missing or invalid email format"}];
            break;
        default :
            
            error = [NSError errorWithDomain:errorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
            
    }
    
    return error;
    
}

@end


#define kCookiesKey  @[@"user_agent_token" , @"transaction_access_token" , @"uat" , @"tat"]

@implementation NSHTTPCookieStorage (Persistence)

- (void)save
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier]];
    
    if (self.cookies != nil && self.cookies.count > 0) {
        
        for (NSHTTPCookie *cookie in self.cookies) {
            
            if([kCookiesKey containsObject:cookie.name]) {
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookie];
                [keychain setData:data forKey:cookie.name];
            }
            
        }
        
    }
}

- (void)load
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier]];
    
    for (NSString * key in kCookiesKey) {
        
        NSData *cookieData = [keychain dataForKey:key];
        
        if (cookieData != nil) {
            NSHTTPCookie *cookie = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
            [self setCookie:cookie];
        }
        
    }
    
}

@end

@implementation NSMutableURLRequest (SimplHeaders)

-(void)addDebugHeaders {
    
    [self setValue:GS_DEVICE_MANUFACTURER_NAME forHTTPHeaderField:GS_DEVICE_MANUFACTURER_HEADER];
    [self setValue:[GSUtilities modelName] forHTTPHeaderField: GS_DEVICE_MODEL_HEADER];
    [self setValue:[GSUtilities parentAppVersion] forHTTPHeaderField:GS_PARENT_APP_VERSION_HEADER];
    [self setValue:[GSUtilities parentAppName] forHTTPHeaderField:GS_PARENT_APP_NAME_HEADER];
    [self setValue:[GSUtilities deviceOSVersion] forHTTPHeaderField:GS_DEVICE_OS_VERSION_HEADER];
    [self setValue:[GSUtilities batteryLife] forHTTPHeaderField:GS_BATTERY_LIFE_HEADER];

    NSString *wifiName = [GSUtilities wifiName] ;
    if (wifiName) {
        [self setValue:wifiName forHTTPHeaderField: GS_DEVICE_WIFI_HEADER];
    }

    NSString *carrierName = [GSUtilities carrierName] ;
    if (carrierName) {
        [self setValue:carrierName forHTTPHeaderField: GS_CARRIER_NAME_HEADER];
    }
    
    NSString *upTime = [GSUtilities upTime] ;
    if (upTime) {
        [self setValue:upTime forHTTPHeaderField: GS_UPTIME_HEADER];
    }
    
    NSString *isRooted = [GSUtilities isRooted] ? @"true" : @"false" ;
    [self setValue:isRooted forHTTPHeaderField:GS_ROOTED_HEADER];
    
    NSString *latLon = [GSUtilities latLon];
    if (latLon) {
        [self setValue:latLon forHTTPHeaderField: GS_LATLON_HEADER];
    }
    
}

@end

