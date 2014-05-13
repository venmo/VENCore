#import "VENCreateTransactionRequest.h"
#import "VENCore.h"

@interface VENCreateTransactionRequest ()

@property (nonatomic, strong) NSMutableOrderedSet *mutableTargets;

@end


@implementation VENCreateTransactionRequest

- (id)init {
    self = [super init];
    if (self) {
        self.mutableTargets = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (BOOL)readyToSend {
    if (![self.mutableTargets count] ||
        ![self.note hasContent] ||
        self.transactionType == VENTransactionTypeUnknown) {
        return NO;
    }
    return YES;
}

- (void)sendWithSuccess:(void(^)(NSArray *sentTransactions,
                                 VENHTTPResponse *response))successBlock
                failure:(void(^)(NSArray *sentTransactions,
                                 VENHTTPResponse *response,
                                 NSError *error))failureBlock {
    [self sendTargets:[self.targets mutableCopy]
     sentTransactions:nil
          withSuccess:successBlock
              failure:failureBlock];
}


- (void)sendTargets:(NSMutableOrderedSet *)targets
   sentTransactions:(NSMutableArray *)sentTransactions
        withSuccess:(void (^)(NSArray *sentTransactions,
                              VENHTTPResponse *response))successBlock
            failure:(void(^)(NSArray *sentTransactions,
                             VENHTTPResponse *response,
                             NSError *error))failureBlock {
    if (!sentTransactions) {
        sentTransactions = [[NSMutableArray alloc] init];
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
        failureBlock(nil, nil, [NSError noAccessTokenError]);
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


- (BOOL)addTransactionTarget:(VENTransactionTarget *)target {

    if (![target isKindOfClass:[VENTransactionTarget class]]
        || ![target isValid]
        || [self containsDuplicateOfTarget:target]) {
        return NO;
    }

    [self.mutableTargets addObject:target];
    return YES;
}


#pragma mark - Other Methods

- (NSOrderedSet *)targets {
   return [self.mutableTargets copy];
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
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       @{recipientTypeKey: target.handle,
                                         @"note": self.note,
                                         @"amount": amountString}];

    if (self.audience != VENTransactionAudienceUserDefault) {
        [parameters addEntriesFromDictionary:@{@"audience": audienceString}];
    }

    return parameters;
}


- (BOOL)containsDuplicateOfTarget:(VENTransactionTarget *)target {
    NSString *handle = target.handle;
    for (VENTransactionTarget *currentTarget in self.targets) {
        if ([handle isEqualToString:currentTarget.handle]) {
            return YES;
        }
    }
    return NO;
}

@end
