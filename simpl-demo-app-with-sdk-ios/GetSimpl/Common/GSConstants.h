//
//  GSConstants.h
//  GetSimpl
//
//  Created by Alok Jha on 15/02/16.
//  Copyright © 2016 Simpl. All rights reserved.
//


#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...) (void)0
#endif


typedef void (^ResponseBlock)(NSDictionary * _Nullable, NSError * _Nullable);

typedef NSString *_Nonnull const ConstantString ;


static ConstantString GS_SDK_VERSION = @"1.8.10" ;

static ConstantString GS_PRODUCTION_APPROVAL_URL = @"https://approvals-api.getsimpl.com/api/v2/";

#if Staging
static ConstantString GS_SANDBOX_APPROVAL_URL = @"https://staging-approvals-api.getsimpl.com/api/v2/";
#else
static ConstantString GS_SANDBOX_APPROVAL_URL = @"https://sandbox-approvals-api.getsimpl.com/api/v2/";
#endif


static ConstantString GS_PRODUCTION_AUTHORIZE_URL = @"https://getsimpl.com/api/v1/";

#if Staging
static ConstantString GS_SANDBOX_AUTHORIZE_URL = @"https://staging.getsimpl.com/api/v1/";
#else
static ConstantString GS_SANDBOX_AUTHORIZE_URL = @"https://sandbox.getsimpl.com/api/v1/";
#endif

static ConstantString GS_PRODUCTION_API_URL = @"https://api.getsimpl.com/api/v1/";

#if Staging
static ConstantString GS_SANDBOX_API_URL = @"https://staging-api.getsimpl.com/api/v1/";
#else
static ConstantString GS_SANDBOX_API_URL = @"https://sandbox-api.getsimpl.com/api/v1/";
#endif

static ConstantString GS_PRODUCTION_ZEROCLICK_URL = @"https://zero-click-api.getsimpl.com/api/v3/";

#if Staging
static ConstantString GS_SANDBOX_ZEROCLICK_URL = @"https://staging-zero-click-api.getsimpl.com/api/v3/";
#else
static ConstantString GS_SANDBOX_ZEROCLICK_URL = @"https://sandbox-zero-click-api.getsimpl.com/api/v3/";
#endif


static ConstantString GS_ERROR_DOMAIN = @"com.getsimpl.error";
static ConstantString GS_UNRESOLVED_ERROR_RESPONSE_MESSAGE = @"Could not resolve response";
static ConstantString GS_INVALID_MOBILE_RESPONSE_MESSAGE = @"Invalid mobile number";
static ConstantString GS_EMPTY_HASHEDPHONENUMBER_MESSAGE = @"Hashed phone number provided is empty.";

static ConstantString GS_DEVICE_MANUFACTURER_NAME = @"Apple";
static ConstantString GS_DEVICE_MANUFACTURER_HEADER = @"SIMPL-DEVICE-MANUFACTURER" ;
static ConstantString GS_DEVICE_MODEL_HEADER = @"SIMPL-DEVICE-MODEL" ;
static ConstantString GS_DEVICE_WIFI_HEADER = @"SIMPL-WIFI-SSID" ;
static ConstantString GS_CARRIER_NAME_HEADER = @"SIMPL-CaN" ;
static ConstantString GS_UPTIME_HEADER = @"SIMPL-Up";
static ConstantString GS_PARENT_APP_VERSION_HEADER = @"SIMPL-PAV";
static ConstantString GS_PARENT_APP_NAME_HEADER = @"SIMPL-PAN";
static ConstantString GS_SDK_VERSION_HEADER = @"sdk-version";
static ConstantString GS_PHONE_HEADER = @"SIMPL-PhN";
static ConstantString GS_LATLON_HEADER = @"SIMPL-Ltln";
static ConstantString GS_ROOTED_HEADER = @"SIMPL-isR";
static ConstantString GS_BATTERY_LIFE_HEADER = @"SIMPL-BAT";
static ConstantString GS_DEVICE_OS_VERSION_HEADER = @"SIMPL-DevOSV";
static ConstantString GS_DEVICE_NAME_HEADER = @"SIMPL-DevName";
static ConstantString GS_DEVICE_OS_NAME_HEADER = @"SIMPL-DevOSName";
static ConstantString GS_DEVICE_LANGUAGE_HEADER = @"SIMPL-DevLang";
static ConstantString GS_DEVICE_IDENTIFIER_FOR_VENDOR_HEADER = @"SIMPL-VendorID";
static ConstantString GS_DEVICE_ADVERTISING_IDENTIFIER_HEADER = @"SIMPL-AdID";
static ConstantString GS_DEVICE_AVAILABLE_MEMORY_HEADER = @"SIMPL-Amem";
static ConstantString GS_DEVICE_DISK_SPACE_HEADER = @"SIMPL-ADisk";
static ConstantString GS_DEVICE_IP_ADDRESS_HEADER = @"SIMPL-IPA";
static ConstantString GS_DEVICE_CONNECTION_TYPE_HEADER = @"SIMPL-ConnType";
static ConstantString GS_DEVICE_CHECK_TOKEN_HEADER = @"SIMPL-DevToken";




typedef const NSInteger ConstantInteger;

static ConstantInteger GS_ERROR_CODE_MERCHANTID = 100;
static ConstantInteger GS_ERROR_CODE_UIWINDOW = 101;
static ConstantInteger GS_ERROR_CODE_UNRESOLVED_RESPONSE = 102;
static ConstantInteger GS_ERROR_CODE_VERIFICATION_FAILED = 103;
static ConstantInteger GS_ERROR_CODE_CANCEL_PRESSED = 104;
static ConstantInteger GS_ERROR_CODE_INVALID_MOBILE = 105;
static ConstantInteger GS_ERROR_CODE_EMPTY_HASHEDPHONENUMBER = 106;
static ConstantInteger GS_ERROR_CODE_OTHER = 107;
static ConstantInteger GS_ERROR_CODE_EMAIL = 108;

