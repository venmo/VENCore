#import "VENTransactionService.h"
#import "VENCore.h"
#import "VENHTTPResponse.h"
#import "NSDictionary+VENCore.h"

@implementation VENTransactionService

- (void)sendWithSuccess:(void(^)(NSOrderedSet *sentTransactions,
                                 VENHTTPResponse *response))successBlock
                failure:(void(^)(NSOrderedSet *sentTransactions,
                                 VENHTTPResponse *response,
                                 NSError *error))failureBlock {
    [self sendTargets:[self.targets mutableCopy]
     sentTransactions:nil
          withSuccess:successBlock
              failure:failureBlock];
}


- (void)sendTargets:(NSMutableOrderedSet *)targets
   sentTransactions:(NSMutableOrderedSet *)sentTransactions
        withSuccess:(void (^)(NSOrderedSet *sentTransactions,
                              VENHTTPResponse *response))successBlock
            failure:(void(^)(NSOrderedSet *sentTransactions,
                             VENHTTPResponse *response,
                             NSError *error))failureBlock {
    if (!sentTransactions) {
        sentTransactions = [[NSMutableOrderedSet alloc] init];
    }

    if ([targets count] == 0) {
        if (successBlock) {
            successBlock(sentTransactions, nil);
        }
        return;
    }

    VENTransactionTarget *target = [targets firstObject];
    [targets removeObjectAtIndex:0];
    NSString *accessToken = [VENCore defaultCore].accessToken;
    if (!accessToken) {
        failureBlock([NSOrderedSet new], nil, [NSError noAccessTokenError]);
        return;
    }
    NSMutableDictionary *postParameters = [NSMutableDictionary dictionaryWithDictionary:@{@"access_token" : accessToken}];
    [postParameters addEntriesFromDictionary:[self dictionaryWithParametersForTarget:target]];
    [[VENCore defaultCore].httpClient POST:VENAPIPathPayments
                                parameters:postParameters
                                   success:^(VENHTTPResponse *response) {
                                       NSDictionary *data = [response.object objectOrNilForKey:@"data"];
                                       NSDictionary *payment = [data objectOrNilForKey:@"payment"];
                                       VENTransaction *newTransaction;
                                       if (payment) {
                                           newTransaction = [[VENTransaction alloc] initWithDictionary:payment];
                                       }
                                       [sentTransactions addObject:newTransaction];

                                       [self sendTargets:targets
                                        sentTransactions:sentTransactions
                                             withSuccess:successBlock
                                                 failure:failureBlock];
                                   }
                                   failure:^(VENHTTPResponse *response, NSError *error) {
                                       if (failureBlock) {
                                           failureBlock(sentTransactions, response, error);
                                       }
                                   }];
}

- (NSDictionary *)dictionaryWithParametersForTarget:(VENTransactionTarget *)target {
    NSString *recipientTypeKey;
    NSString *audienceString;
    NSString*amountString;
    switch (target.targetType) {
        case VENTargetTypeEmail:
            recipientTypeKey = @"email";
            break;
        case VENTargetTypePhone:
            recipientTypeKey = @"phone";
            break;
        case VENTargetTypeUserId:
            recipientTypeKey = @"user_id";
            break;
        default:
            return nil;
            break;
    }

    switch (self.audience) {
        case VENTransactionAudienceFriends:
            audienceString = @"friends";
            break;
        case VENTransactionAudiencePublic:
            audienceString = @"public";
            break;
        default:
            audienceString = @"private";
            break;
    }
    CGFloat dollarAmount = (CGFloat)target.amount/100.;
    amountString = [NSString stringWithFormat:@"%.2f", dollarAmount];
    if (self.transactionType == VENTransactionTypeCharge) {
        amountString = [@"-" stringByAppendingString:amountString];
    }
    NSDictionary *parameters = @{recipientTypeKey: target.handle,
                                 @"note"        : self.note,
                                 @"amount"      : amountString,
                                 @"audience"    : audienceString};
    return parameters;
}


@end
