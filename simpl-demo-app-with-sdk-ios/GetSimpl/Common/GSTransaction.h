//
//  GSTransaction.h
//  GetSimpl
//
//  Created by Alok Jha on 15/02/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSUser.h"

@interface GSTransaction : NSObject

@property (nonatomic, readonly, strong) GSUser * __nonnull user;
@property (nonatomic, readonly) NSInteger amountInPaise;

/// Designated initializer of GSTransaction
///
/// \param user A GSUser object
///
/// \param amountInPaise Transaction amount in paise
- (nonnull instancetype)initWithUser:(GSUser * __nonnull)user amountInPaise:(NSInteger)amountInPaise;
@end
