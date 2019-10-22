//
//  GSUser.m
//  GetSimpl
//
//  Created by Alok Jha on 15/02/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import "GSUser.h"
#import "GSManager.h"
#import "GSGuard.h"

@implementation GSUser

-(nonnull instancetype)initWithPhoneNumber:(NSString *__nonnull)phoneNumber email:(NSString *__nonnull)email {
    self = [super init];
    return [GSGuard<GSUser *> guard:^GSUser *{
        if (self) {
            self.phoneNumber = phoneNumber;
            self.email = email;
        }
        
        return self;
    } withDefaultValue:self];
}

@end
