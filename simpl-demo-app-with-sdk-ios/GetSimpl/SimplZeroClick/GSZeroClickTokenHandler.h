//
//  GSZeroClickTokenHandler.h
//  GetSimpl
//
//  Created by Alok Jha on 23/03/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSConstants.h"

@interface GSZeroClickTokenHandler : NSObject

-(instancetype) initWithURLRequest:(NSURLRequest *) request onCompletion :(ResponseBlock) block ;

-(void)generateToken ;


@end
