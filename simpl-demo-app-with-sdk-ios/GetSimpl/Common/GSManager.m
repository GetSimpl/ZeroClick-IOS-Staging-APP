//
//  GSManager.m
//  GetSimpl
//
//  Created by Alok Jha on 15/02/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import "GSManager.h"
#import "GSUtilities.h"
#import "GSConstants.h"
#import "Extensions.h"
#import "GSWebViewHandler.h"
#import "GSApprovalHandler.h"
#import "GSTransaction.h"
#import "GSFingerPrint.h"
#import "NSString+AESCrypt.h"
#import "GSGuard.h"

#ifdef SimplZeroClick
#import "GSZeroClickTokenHandler.h"
#import "SimplZeroClick.h"
#endif

static BOOL isSandBoxEnabled  = NO;

@interface GSManager ()<NSURLSessionDelegate,GSWebHandlerProtocol>
{
    UIActivityIndicatorView *actView;
    NSDictionary *cDictionary;
    BOOL isFirstTransaction;
    GSWebViewHandler *webHandler;
}

@property (nonatomic, readwrite, copy) NSString * __nullable merchantID;
@property (nonatomic, copy) void (^completionHandler)(NSDictionary * __nullable, NSError * __nullable);

@end

@implementation GSManager

+(GSManager * __nonnull)sharedManager {
    static GSManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    
        [[TestObject alloc] init];
    });
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    return sharedInstance;
}

+(void)initializeWithMerchantID:(NSString *)merchantID {
    [GSGuard guard:^{
        [self sharedManager].merchantID = merchantID;
    }];
}

+(void)enableSandBoxEnvironment:(BOOL)enable {
    [GSGuard guard:^{
        isSandBoxEnabled = enable;
    }];
}

-(BOOL)isSandBoxEnvironmentEnabled {
    return [[GSGuard guard:^NSNumber*{
        return @(isSandBoxEnabled);
    } withDefaultValue:@(false)] boolValue];
    
}

-(NSString *)approvalURL {
    
    NSString *val = isSandBoxEnabled ? GS_SANDBOX_APPROVAL_URL : GS_PRODUCTION_APPROVAL_URL;
    return val;
}

-(NSString *)authorizeURL {
    NSString *val = isSandBoxEnabled ? GS_SANDBOX_AUTHORIZE_URL : GS_PRODUCTION_AUTHORIZE_URL;
    return val;
}

-(NSString *)apiURL {
    NSString *val = isSandBoxEnabled ? GS_SANDBOX_API_URL : GS_PRODUCTION_API_URL;
    return val;
}

-(NSString *)subscriptionURL {
    NSString *val = isSandBoxEnabled ? GS_SANDBOX_ZEROCLICK_URL : GS_PRODUCTION_ZEROCLICK_URL;
    return val;
}

#pragma mark - Approval call

-(void)checkApprovalForUser:(GSUser *)user onCompletion:(void (^)(BOOL, BOOL, NSString * _Nullable, NSError * _Nullable))completion {
    [GSGuard guardWithCallback:^{
        [self isApproved:user onCompletion:completion];
    } errorCallback:^(NSError * error) {
        completion(NO, NO, nil, error);
    }];
}

-(void)isApproved:(GSUser *)user onCompletion:(void (^)(BOOL, BOOL, NSString * _Nullable, NSError * _Nullable))completion {
    
    if (self.merchantID == nil || self.merchantID.length == 0) {
        
        completion(NO , NO , nil, [NSError errorFromErrorCode:GS_ERROR_CODE_MERCHANTID domain:nil message:nil]) ;
        
        return ;
    }
    
    NSString *queryString  = [@"simpl_buy/approved?merchant_id=" stringByAppendingString:self.merchantID];
    
    if (user.phoneNumber != nil){
        
        if (user.phoneNumber.length == 0 || ![user.phoneNumber isValidMobileNumber]) {
            
            completion(NO , NO , nil, [NSError errorFromErrorCode:GS_ERROR_CODE_INVALID_MOBILE domain:nil message:nil]);
            
            return ;
        }
        
        queryString =  [queryString stringByAppendingString:[NSString stringWithFormat:@"&phone_number=%@",user.phoneNumber]];

    }
    
    if ([queryString rangeOfString:@"phone_number"].location == NSNotFound) {
        
        completion(NO , NO , nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Insufficient parameters. phoneNumber is required."]);
        
        return;

    }
    
    queryString = [queryString stringByAppendingString:@"&src=ios"];
    
    queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (queryString == nil) {
        
        completion(NO , NO , nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Parameters provided are not in valid format for URL."]);
        
        return;
    }
    
    NSString *urlString = [[self approvalURL] stringByAppendingString:queryString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
   
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    GSFingerPrint *fp = [[GSFingerPrint alloc] initWithMerchantId:self.merchantID andUser:user];
    
    [fp generateEncryptedPayloadWithCallback:^(NSString * payload) {
        if (!payload) {
            completion(NO , NO , nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Parameters provided are not in valid format for Json."]);
            
            return;
            
        }
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:payload , @"payload", nil];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:postData];
        
        GSApprovalHandler *handler = [[GSApprovalHandler alloc] initWithURLRequest:urlRequest onCompletion:^(NSDictionary * _Nullable jsonResponse, NSError * _Nullable error) {
            
            if (error != nil) {
                isFirstTransaction = NO;
                completion(NO , NO , nil, error);
                return ;
            }
            
            BOOL approved = ((NSNumber *)jsonResponse[@"approved"]).boolValue;
            BOOL firstTransaction = ((NSNumber *)jsonResponse[@"first_transaction"]).boolValue;
            isFirstTransaction = firstTransaction ;
            NSString *buttonText = jsonResponse[@"button_text"] ;
            
            completion(approved,firstTransaction,buttonText,nil);
            
            
        }] ;
        
        [handler start];
    }];
    
}

#pragma mark - Transaction Flow

-(void)authorizeTransaction:(GSTransaction *)transaction onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion{
    [GSGuard guardWithCallback:^{
        [self authorize:transaction withOrderId:nil onCompletion:completion];
    } errorCallback:^(NSError * error) {
        completion(nil, error);
    }];
}

-(void)authorizeTransaction:(GSTransaction *)transaction withOrderId:(NSString *)orderID onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    [GSGuard guardWithCallback:^{
        [self authorize:transaction withOrderId:orderID onCompletion:completion];
    } errorCallback:^(NSError * error) {
        completion(nil, error);
    }];
}

-(void)authorize:(GSTransaction *)transaction withOrderId:(NSString *)orderID onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    
    if (self.merchantID == nil || self.merchantID.length == 0) {
        
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_MERCHANTID domain:nil message:nil]);
        
        return ;
    }

    
    GSUser *user = transaction.user;
    
    NSString *queryString = [@"authorize?merchant_id=" stringByAppendingString:self.merchantID];
    
    if (user.phoneNumber != nil){
        
        if (user.phoneNumber.length == 0 || ![user.phoneNumber isValidMobileNumber]) {
            
            completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_INVALID_MOBILE domain:nil message:nil]);
            
            return ;
        }
        
        queryString =  [queryString stringByAppendingString:[NSString stringWithFormat:@"&phone_number=%@",user.phoneNumber]];
        
    }
    else {
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Missing parameter phoneNumber"]);
        return ;
    }
    
    if (user.email != nil && user.email.length > 0 && [user.email isValidEmail]) {
        
        queryString =  [queryString stringByAppendingString:[NSString stringWithFormat:@"&email=%@",user.email]];
    }
    
    if (orderID != nil && orderID.length > 0) {
        
        queryString =  [queryString stringByAppendingString:[NSString stringWithFormat:@"&order_id=%@",orderID]];
    }
    
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&transaction_amount=%ld&src=ios",(long)transaction.amountInPaise]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&first_transaction=%@" , isFirstTransaction ? @"true" : @"false"]];
    
    queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (queryString == nil) {
        
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Parameters provided are not in valid format for URL."]);
        
        return;
    }
    
    
    if ([UIApplication sharedApplication].keyWindow == nil) {
        
        NSError *error  = [NSError errorFromErrorCode:GS_ERROR_CODE_UIWINDOW domain:nil message:nil];
        completion(nil,error);
        
        return;
    }
    
    self.completionHandler = completion;
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] load];
    
    NSDictionary* headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    
    NSString *urlString = [[self authorizeURL] stringByAppendingString:queryString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [urlRequest setAllHTTPHeaderFields:headers];
    
    [urlRequest setValue:[GSUtilities sdkVersion] forHTTPHeaderField:GS_SDK_VERSION_HEADER];
    [urlRequest setValue:user.phoneNumber forHTTPHeaderField:GS_PHONE_HEADER];
    [urlRequest addDebugHeaders];
    
    if (user.headerParams != nil) {
        
        for (NSString *aKey in [user.headerParams allKeys]) {
            
            NSString *aValue = [user.headerParams valueForKey:aKey];
            [urlRequest setValue:aValue forHTTPHeaderField: aKey];
        }
        
    }
    
    webHandler = [self initializeWebViewHandlerWithDelegate:self];
    [webHandler showWithCallback:^(NSError *error){
        if(error != nil){
            completion(nil, error);
            return;
        }
        [webHandler loadRequest:urlRequest];
    }];
}

#pragma mark - Token Flow

#ifdef SimplZeroClick

-(void)generateTokenForUser:(GSUser *)user onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    [GSGuard guardWithCallback:^{
        [self generateZeroClickTokenForUser:user onCompletion:completion];
    } errorCallback:^(NSError * error) {
        completion(nil, error);
    }];
}

-(void)generateZeroClickTokenForUser:(GSUser *)user onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    
    if (self.merchantID == nil || self.merchantID.length == 0) {
        
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_MERCHANTID domain:nil message:nil]);
        
        return ;
    }
    
    
    if (user.phoneNumber != nil){
        
        if (user.phoneNumber.length == 0 || ![user.phoneNumber isValidMobileNumber]) {
            
            completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_INVALID_MOBILE domain:nil message:nil]);
            
            return ;
        }
        
    }
    else {
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Missing parameter phoneNumber"]);
        return ;
    }

    
    NSString *urlString = [[self subscriptionURL] stringByAppendingString:@"zero_click_tokens/initiate?src=ios"];
    
    NSDictionary *params = @{@"phone_number" : user.phoneNumber};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = postData;
    [urlRequest setValue:self.merchantID forHTTPHeaderField:@"CLIENT-ID"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[GSUtilities sdkVersion] forHTTPHeaderField:GS_SDK_VERSION_HEADER];
    [urlRequest setValue:user.phoneNumber forHTTPHeaderField:GS_PHONE_HEADER];
    [urlRequest addDebugHeaders];
    
    if (user.headerParams != nil) {
        for (NSString *aKey in [user.headerParams allKeys]) {
            NSObject * value = [user.headerParams valueForKey:aKey];
            if([value isKindOfClass:[NSNumber class]]) {
                NSString *aValue = [((NSNumber *)value) stringValue];
                [urlRequest setValue:aValue forHTTPHeaderField: aKey];
            } else if([value isKindOfClass:[NSString class]]){
                [urlRequest setValue:((NSString *)value) forHTTPHeaderField: aKey];
            } else {
                NSLog(@"Warning: invalid type for %@. headerParams only supports int, float and string values", aKey);
            }
        }
    }
    
    webHandler = [self initializeWebViewHandlerWithDelegate:self];
    [webHandler showWithCallback:^(NSError *error){
        if(error != nil){
            completion(nil, error);
            return;
        }
        GSZeroClickTokenHandler *handler = [[GSZeroClickTokenHandler alloc] initWithURLRequest:urlRequest onCompletion:^(NSDictionary * _Nullable jsonResponse, NSError * _Nullable error) {
            
            if (error != nil) {
                
                completion(jsonResponse,error);
                
                return ;
            }
            
            self.completionHandler = completion;
            
            NSDictionary *dataDict = jsonResponse[@"data"];
            
            NSString *urlStr = dataDict[@"verification_url"];
            
            if (![urlStr containsString:@"src=ios"]) {
                
                urlStr  = [urlStr stringByAppendingString:@"&src=ios"];
            }
            
            [self openURL:urlStr onCompletion:completion];
            
        }];
        
        [handler generateToken];
    }];
    
   
}


-(void)openRedirectionURL:(NSString *)urlString onCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    [GSGuard guardWithCallback:^{
        webHandler = [self initializeWebViewHandlerWithDelegate:self];
        [webHandler showWithCallback:^(NSError *error){
            if(error != nil){
                completion(nil, error);
                return;
            }
            [self openURL:urlString onCompletion:completion];
        }];
    } errorCallback:^(NSError * error) {
        completion(nil, error);
    }];
}

-(void)generateFingerprintForUser:(GSUser * __nonnull)user onCompletion:(void (^)(NSString * _Nullable))completion {
    [GSGuard guardWithCallback:^{
        NSString *merchantID = self.merchantID == nil ? @"" : self.merchantID;
        GSFingerPrint *fp = [[GSFingerPrint alloc] initWithMerchantId:merchantID andUser:user];
        [fp generateEncryptedPayloadWithCallback:^(NSString * payload) {
            completion(payload);
        }];
    } errorCallback:^(NSError * error) {
        completion([error description]);
    }];
}

#endif

-(void)openURL:(NSString *)urlString onCompletion:(void (^)(NSDictionary * _Nullable jsonResponse, NSError * _Nullable error))completion{
    
    if (![urlString containsString:@"src=ios"]) {
        
        urlString  = [urlString stringByAppendingString:@"&src=ios"];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (!url) {
        
        completion(nil, [NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:@"Malformed urlString"]);
    }
    
    self.completionHandler = completion;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [urlRequest setValue:[GSUtilities sdkVersion] forHTTPHeaderField:GS_SDK_VERSION_HEADER];
    [urlRequest addDebugHeaders];
    
    
    [webHandler loadRequest:urlRequest];   
}


#pragma mark - GSWebViewHandlerProtocol method

-(void)webHandler:(GSWebViewHandler *)handler didRecieveResponse:(NSDictionary *)response withError:(NSError *)error {
    NSMutableDictionary *jsonResponse = nil;
    
    if (response != nil) {
        
        cDictionary = response[@"cdata"] ;
        
        jsonResponse = [response mutableCopy];
        [jsonResponse removeObjectForKey:@"cdata"];
    }
    
    [self requestFinishedWithResponse:jsonResponse error:error];
}


#pragma mark - Request Finished methods

-(void)requestFinishedWithResponse:(NSDictionary *)jsonResponse error:(NSError *)error {
    self.completionHandler(jsonResponse,error);
    
    if (cDictionary != nil){
        [self sendTransactionConfirmationEvent];
    }
    if (jsonResponse != nil && jsonResponse[@"transaction_token"] != nil) {
        NSString *token = jsonResponse[@"transaction_token"];
        [self sendTransactionTokenHandoverEventWithToken:token];
    }
    
    webHandler = nil;
}


#pragma mark - Token Handover and Confirmation calls

-(void)sendTransactionConfirmationEvent {
    
    NSString *urlString = [[self apiURL] stringByAppendingString:@"_c"];
    
    NSDictionary *params = [cDictionary copy];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = postData ;
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[GSUtilities sdkVersion] forHTTPHeaderField:GS_SDK_VERSION_HEADER];
    [urlRequest addDebugHeaders];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        cDictionary = nil;
        
        if(error != nil || data == nil)
        {
            return;
        }
        
    }] resume];
    
}

-(void)sendTransactionTokenHandoverEventWithToken:(NSString *)token {
    
    NSString *urlString = [[self apiURL] stringByAppendingString:@"_h"];
    
    NSDictionary *params = @{@"t" : token , @"h" : @"true"};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = postData ;
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[GSUtilities sdkVersion] forHTTPHeaderField:GS_SDK_VERSION_HEADER];
    [urlRequest addDebugHeaders];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error != nil || data == nil)
        {
            return;
        }
        
        
    }] resume];
    
    
}

-(GSWebViewHandler *) initializeWebViewHandlerWithDelegate:(id <GSWebHandlerProtocol>) delegate {
    UIWindow *window = [UIApplication sharedApplication].keyWindow ;
    CGFloat windowWidth = window.bounds.size.width;
    CGFloat windowHeight = window.bounds.size.height;
    CGFloat bottomSafeAreaInset = 0.0;
    
    if (@available(iOS 11, *)) {
        bottomSafeAreaInset = window.safeAreaInsets.bottom;
    }
    
    webHandler = [[GSWebViewHandler alloc] initWithFrame:CGRectMake(0, windowHeight - bottomSafeAreaInset, windowWidth, windowHeight - bottomSafeAreaInset)];
    webHandler.delegate = delegate;
    return webHandler;
}

@end
