#import <Foundation/Foundation.h>
#import "GSGuard.h"
#import "GSConstants.h"
#import "Extensions.h"

@implementation GSGuard

+(id)guard:(id(^)())callback withDefaultValue:(id)defaultValue {
    return [self guardWithCallbackAndReturn:^id{
        return callback();
    } errorCallback:^id(NSError *error) {
        return defaultValue;
    }];
}

+(void)guard:(void(^)())callback {
    [self guard:^ id {
        callback();
        return nil;
    } withDefaultValue:nil];
}

+(id)guardWithCallbackAndReturn:(id(^)())callback errorCallback:(id(^)(NSError*))errorCallback{
    @try {
        return callback();
    } @catch(NSException *exception) {
        return errorCallback([NSError errorFromErrorCode:GS_ERROR_CODE_OTHER domain:nil message:[exception description]]);
    }
}

+(void)guardWithCallback:(void(^)())callback errorCallback:(void(^)(NSError*))errorCallback {
    [self guardWithCallbackAndReturn:^id{
        callback();
        return nil;
    } errorCallback:^id(NSError *error) {
        errorCallback(error);
        return nil;
    }];
}

@end
