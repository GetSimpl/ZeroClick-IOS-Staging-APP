//
//  GSApprovalHandler.h
//  GetSimpl
//
//  Created by Alok Jha on 23/03/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSConstants.h"

@interface GSApprovalHandler : NSObject

-(instancetype) initWithURLRequest:(NSURLRequest *) request onCompletion :(ResponseBlock) block ;

-(void)start ;

@end
