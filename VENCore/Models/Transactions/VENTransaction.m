#import "VENTransaction.h"

#import <Foundation/Foundation.h>

#import "NSDictionary+VENCore.h"
#import "VENTransactionTarget.h"
#import "NSString+VENCore.h"
#import "VENCore.h"
#import "VENTransactionPayloadKeys.h"
#import "VENUser.h"
#import "VENTransactionTarget.h"
#import "NSDictionary+VENCore.h"
#import "VENHTTPResponse.h"

NSString *const VENErrorDomainTransaction = @"com.venmo.VENCore.ErrorDomain.VENTransaction";

NSString *const VENTransactionTypeStrings[] = {@"unknown", @"pay", @"charge"};
NSString *const VENTransactionStatusStrings[] = {@"not_sent", @"pending", @"settled"};
NSString *const VENTransactionAudienceStrings[] = {@"private", @"friends", @"public"};

@interface VENTransaction ()

@property (strong, nonatomic) NSMutableOrderedSet *mutableTargets;

@end

@implementation VENTransaction

- (id)init {
    self = [super init];
    if (self) {
        self.mutableTargets = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    self = [self init];
    
    if (self) {
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        NSDictionary *cleanDictionary = [dictionary dictionaryByCleansingResponseDictionary];
        
        // Main Transaction Body
        self.transactionID      = cleanDictionary[VENTransactionIDKey];
        self.note               = cleanDictionary[VENTransactionNoteKey];
        
        NSString *transactionType       = cleanDictionary[VENTransactionTypeKey];
        NSString *transactionStatus     = cleanDictionary[VENTransactionStatusKey];
        NSString *transactionAudience   = cleanDictionary[VENTransactionAudienceKey];
        

        // Set transaction type enumeration
        if ([transactionType isEqualToString:VENTransactionTypeStrings[VENTransactionTypeCharge]]) {
            self.transactionType = VENTransactionTypeCharge;
        }
        else if ([transactionType isEqualToString:VENTransactionTypeStrings[VENTransactionTypePay]]) {
            self.transactionType = VENTransactionTypePay;
        }
        else {
            self.transactionType = VENTransactionTypeUnknown;
        }
        
        
        // Set status enumeration
        if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusPending]]) {
            self.status = VENTransactionStatusPending;
        }
        else if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusSettled]]) {
            self.status = VENTransactionStatusSettled;
        }
        #warning make sure that dictionary representation respects this
        else if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusNotSent]]) {
            self.status = VENTransactionStatusNotSent;
        }
        
        
        // Set audience enumeration
        if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudiencePublic]]) {
            self.audience = VENTransactionAudiencePublic;
        }
        else if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudienceFriends]]) {
            self.audience = VENTransactionAudienceFriends;
        }
        else if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudiencePrivate]]) {
            self.audience = VENTransactionAudiencePrivate;
        }
        else {
            self.audience = VENTransactionAudiencePrivate;
        }
        
        
        // Set up VENUser actor
        NSDictionary *userDictionary = cleanDictionary[VENTransactionActorKey];
        if ([VENUser canInitWithDictionary:userDictionary]) {
            VENUser *user = [[VENUser alloc] initWithDictionary:userDictionary];
            self.actor = user;
        }
        
        
        // Set up VENTransactionTargets
        NSMutableDictionary *targetDictionary = [cleanDictionary[VENTransactionTargetKey] mutableCopy];
        if (cleanDictionary[VENTransactionAmountKey]) {
            targetDictionary[VENTransactionAmountKey] = cleanDictionary[VENTransactionAmountKey];
        }
        
        if ([VENTransactionTarget canInitWithDictionary:targetDictionary]) {
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithDictionary:targetDictionary];
            [self addTransactionTarget:target];
        }
    }
    
    return self;
}


- (BOOL)isEqual:(id)object {
    VENTransaction *otherObject = (VENTransaction *)object;
    
    if (![otherObject.transactionID isEqualToString:self.transactionID]
        || otherObject.transactionType != self.transactionType) {
        return NO;
    }
    
    return YES;
}


+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary {
    NSArray *requiredKeys = @[VENTransactionAmountKey, VENTransactionNoteKey, VENTransactionActorKey, VENTransactionIDKey, VENTransactionTargetKey];
    for (NSString *key in requiredKeys) {
        if (!dictionary[key] || [dictionary[key] isKindOfClass:[NSNull class]]
            || ([dictionary[key] respondsToSelector:@selector(isEqualToString:)]
                && [dictionary[key] isEqualToString:@""])) {
            return NO;
        }
    }
    return YES;
}


- (NSOrderedSet *)targets {
    return [self.mutableTargets copy];
}


#pragma mark - Private

- (BOOL)addTransactionTarget:(VENTransactionTarget *)target {

    if (![target isKindOfClass:[VENTransactionTarget class]]
        || ![target isValid]
        || [self containsDuplicateOfTarget:target]) {
        return NO;
    }

    [self.mutableTargets addObject:target];
    return YES;
}


- (NSError *)addTargets:(NSSet *)targets {
    for (VENTransactionTarget *target in targets) {
        if (![target isKindOfClass:[VENTransactionTarget class]]) {
            return [NSError errorWithDomain:VENErrorDomainTransaction
                                       code:VENErrorCodeTransactionInvalidTarget
                                description:@"One or more targets is not of class type VENTransactionTarget"
                         recoverySuggestion:nil];
        }
        else if (![target isValid]) {
            return [NSError errorWithDomain:VENErrorDomainTransaction
                                       code:VENErrorCodeTransactionInvalidTarget
                                description:@"One or more targets is not valid"
                         recoverySuggestion:nil];

        }
        else if ([self containsDuplicateOfTarget:target]) {
            return [NSError errorWithDomain:VENErrorDomainTransaction
                                       code:VENErrorCodeTransactionDuplicateTarget
                                description:@"One or more targets has a handle that already exists in current targets."
                         recoverySuggestion:nil];
        }
    }

    [self.mutableTargets addObjectsFromArray:[targets allObjects]];
    return nil;
}


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



- (BOOL)readyToSend {
#warning Unimplemented
    if (![self.mutableTargets count] ||
        ![self.note hasContent] ||
        self.transactionType == VENTransactionTypeUnknown ||
        self.status != VENTransactionStatusNotSent) {
        return NO;
    }
    return YES;
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
