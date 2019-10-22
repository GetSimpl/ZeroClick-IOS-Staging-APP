//
//  GSApprovalHandler.m
//  GetSimpl
//
//  Created by Alok Jha on 23/03/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import "GSApprovalHandler.h"
#import "Extensions.h"

@interface GSApprovalHandler () <NSURLSessionDelegate>

@property (nonatomic) NSURLRequest *urlRequest;
@property (nonatomic, copy) ResponseBlock completionBlock;

@end



@implementation GSApprovalHandler


-(instancetype) initWithURLRequest:(NSURLRequest *)request onCompletion:(ResponseBlock)block {
    
    if (self = [super init]) {
        
        self.urlRequest = request ;
        self.completionBlock = block ;
        
    }
    
    return self;
}

-(void) start {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:self.urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error != nil || data == nil)
        {
            if(error != nil){
                self.completionBlock(nil,error) ;
            }
            else if(data == nil) {
                self.completionBlock(nil,[NSError errorFromErrorCode:GS_ERROR_CODE_UNRESOLVED_RESPONSE domain:nil message:nil]) ;
            }
            return;
        }
        
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonResponse[@"success"] == nil) {
            
            self.completionBlock(nil,[NSError errorFromErrorCode:GS_ERROR_CODE_UNRESOLVED_RESPONSE domain:nil message:nil]) ;
            return ;
        }
        
        BOOL success =  ((NSNumber *)jsonResponse[@"success"]).boolValue;
        
        if (success) {
            
            if (jsonResponse[@"data"] == nil) {
                
                self.completionBlock(nil,[NSError errorFromErrorCode:GS_ERROR_CODE_UNRESOLVED_RESPONSE domain:nil message:nil]) ;
                return ;
            }
            
            NSDictionary *dataDict = jsonResponse[@"data"];
            
            self.completionBlock(dataDict,nil);
            
        }
        else {
            
            BOOL errorsKey = jsonResponse[@"errors"] != nil;
            
            BOOL errorsArray = NO ;
            
            if(errorsKey) {
                errorsArray = [jsonResponse[@"errors"] isKindOfClass:[NSArray class]];
            }
            
            BOOL errorCount = NO;
            
            if (errorsArray) {
                
                NSArray *errors = jsonResponse[@"errors"];
                
                errorCount = errors.count > 0 ;
            }
            
            if(errorsKey && errorsArray && errorCount) {
                
                NSArray *errors = jsonResponse[@"errors"];
                
                NSString *message = errors[0];
                
                self.completionBlock(nil,[NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:message]);
            }
            else {
                
                self.completionBlock(nil,[NSError errorFromErrorCode:GS_ERROR_CODE_UNRESOLVED_RESPONSE domain:nil message:nil]) ;
            }
            
        }
        
        
    }] resume];

    
    
}
@end
