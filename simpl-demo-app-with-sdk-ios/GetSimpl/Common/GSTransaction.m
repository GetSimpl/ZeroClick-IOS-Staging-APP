//
//  GSTransaction.m
//  GetSimpl
//
//  Created by Alok Jha on 15/02/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import "GSTransaction.h"
#import "GSGuard.h"

@interface GSTransaction ()

@property (nonatomic, readwrite, strong) GSUser * __nonnull user;
@property (nonatomic, readwrite) NSInteger amountInPaise;

@end

@implementation GSTransaction

-(nonnull instancetype)initWithUser:(GSUser *)user amountInPaise:(NSInteger)amountInPaise {
    self = [super init];    
    return [GSGuard guard:^id{
        if (self) {
            self.user = user;
            self.amountInPaise = amountInPaise;
        }
        return self;
    } withDefaultValue:self];
}

@end
