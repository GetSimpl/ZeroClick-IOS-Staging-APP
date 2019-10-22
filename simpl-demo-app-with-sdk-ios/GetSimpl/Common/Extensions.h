//
//  Extensions.h
//  GetSimpl
//
//  Created by Alok Jha on 16/09/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestObject : NSObject

@end


@interface NSString (Validity)

-(BOOL)isValidMobileNumber ;
-(BOOL)isValidEmail ;
@end


@interface NSError (Error)

+(NSError *)errorFromErrorCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message;

@end


@interface NSHTTPCookieStorage (Persistence)

- (void)save ;
- (void)load ;

@end


@interface NSMutableURLRequest (SimplHeaders)

-(void)addDebugHeaders;

@end
