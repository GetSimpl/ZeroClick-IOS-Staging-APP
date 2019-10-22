#ifndef GSGuard_h
#define GSGuard_h

@interface GSGuard<ObjectType>: NSObject
+(ObjectType)guard:(ObjectType(^)())callback withDefaultValue:(ObjectType) defaultValue;
+(ObjectType)guardWithCallbackAndReturn:(ObjectType(^)())callback errorCallback:(ObjectType(^)(NSError*))errorCallback;
+(void)guard:(void(^)())callback;
+(void)guardWithCallback:(void(^)())callback errorCallback:(void(^)(NSError*))errorCallback;
@end
#endif /* GSGuard_h */
