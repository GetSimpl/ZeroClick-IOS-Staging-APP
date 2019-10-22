//
//  GSWebHandler.h
//  GetSimpl
//
//  Created by Alok Jha on 08/11/16.
//  Copyright © 2016 Simpl. All rights reserved.
//


#import <UIKit/UIKit.h>

@class GSWebViewHandler;

@protocol GSWebHandlerProtocol <NSObject>

-(void)webHandler:(GSWebViewHandler * _Nonnull)handler didRecieveResponse:(  NSDictionary * _Nullable )response withError:(NSError * _Nullable)error;

@end


@interface GSWebViewHandler : NSObject 

@property (nonatomic , weak)_Nullable id< GSWebHandlerProtocol> delegate;

-(instancetype _Nonnull)initWithFrame:(CGRect)frame;

-(void)loadRequest:(NSURLRequest *_Nonnull)request;
-(void)showWithCallback:(void(^)()) callback;

@end
