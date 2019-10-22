//
//  GSManager+Transaction.h
//  GetSimpl
//
//  Created by Alok Jha on 03/04/17.
//  Copyright © 2017 Simpl. All rights reserved.
//

#import "GSManager.h"
#import "GSTransaction.h"

@interface GSManager (Transaction)

/**
 Authorizes and returns appropriate response for a transaction.
 
 On successful transaction jsonResponse in Completion block will contain transaction_token key which is to be sent to Merchant server with cart details within 1 Hr of doing the transaction.
 
 @param transaction A GSTransaction object encapsulating GSUser and transaction amount
 @param completion  Completion block for the response with following arguments  : NSDictionary jsonResponse , NSError error
 */
- (void)authorizeTransaction:(GSTransaction * __nonnull)transaction onCompletion:(void (^ __nonnull)(NSDictionary * __nullable jsonResponse, NSError * __nullable error))completion;

/**
 Authorizes and returns appropriate response for a transaction
 
 On successful transaction jsonResponse in Completion block will contain transaction_token key which is to be sent to Merchant server with
 cart details within 1 Hr of doing the transaction.
 
 @param transaction A GSTransaction object encapsulating GSUser and transaction amount
 @param orderID     The order id of the transaction
 @param completion  Completion block for the response
 */
- (void)authorizeTransaction:(GSTransaction * __nonnull)transaction withOrderId:(NSString * __nullable)orderID onCompletion:(void (^ __nonnull)(NSDictionary * __nullable jsonResponse, NSError * __nullable error))completion;



@end
