#import "VENTransaction.h"
#import <Foundation/Foundation.h>
#import "NSDictionary+VENCore.h"
#import "VENTransactionTarget.h"
#import "NSString+VENCore.h"
#import "VENCore.h"

NSString *const VENErrorDomainTransaction = @"com.venmo.VENCore.ErrorDomain.VENTransaction";

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


- (NSOrderedSet *)targets {
    return [self.mutableTargets copy];
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
#warning Incomplete implementation
    if (!dictionary) {
        return nil;
    }
    
    return nil;
}

+ (VENTransactionType)typeWithString:(NSString *)string {
#warning Let's inline these in initWithDictionary
    return [[string lowercaseString] isEqualToString:@"charge"] ?
    VENTransactionTypeCharge : VENTransactionTypePay;
}


+ (VENTransactionStatus)statusWithString:(NSString *)string {
#warning Let's inline these in initWithDictionary
    VENTransactionStatus status = VENTransactionStatusNotSent;
    NSString *lowercaseString = [string lowercaseString];
    if ([lowercaseString isEqualToString:@"settled"]) {
        status = VENTransactionStatusSettled;
    }
    else if ([lowercaseString isEqualToString:@"pending"]) {
        status = VENTransactionStatusPending;
    }
    return status;
}


+ (VENTransactionAudience)audienceWithString:(NSString *)string {
#warning Let's inline these in initWithDictionary
    VENTransactionAudience audience = VENTransactionAudiencePrivate;
    NSString *lowercaseString = [string lowercaseString];
    if ([lowercaseString isEqualToString:@"friends"]) {
        audience = VENTransactionAudienceFriends;
    }
    else if ([lowercaseString isEqualToString:@"public"]) {
        audience = VENTransactionAudiencePublic;
    }
    return audience;
}


#pragma mark - Private

/*
 + (instancetype)transactionWithPaymentObject:(NSDictionary *)payment {
 #warning This should be initWithDictionary
 if (!payment) {
 return nil;
 }
 
 VENTransaction *transaction = [[VENTransaction alloc] init];
 transaction.transactionID   = [payment stringForKey:@"id"];
 transaction.type            = [VENTransaction typeWithString:payment[@"action"]];
 
 NSDictionary *actor         = [payment objectOrNilForKey:@"actor"];
 transaction.fromUserID      = [actor stringForKey:@"id"];
 
 NSDictionary *target        = [payment objectOrNilForKey:@"target"];
 NSString *targetPhone       = [target stringForKey:@"phone"];
 NSString *targetEmail       = [target stringForKey:@"email"];
 NSDictionary *targetUser    = [target objectOrNilForKey:@"user"];
 
 if (targetPhone) {
 transaction.recipientHandle    = targetPhone;
 transaction.recipientType      = VENTargetTypePhone;
 }
 if (targetEmail) {
 transaction.recipientHandle    = targetEmail;
 transaction.recipientType      = VENTargetTypeEmail;
 }
 
 if (targetUser) {
 transaction.recipientType      = VENTargetTypeUserId;
 transaction.recipientHandle    = [targetUser stringForKey:@"id"];
 transaction.toUserID        = [targetUser stringForKey:@"id"];
 }
 
 NSString *audienceString        = [payment stringForKey:@"audience"];
 transaction.audience            = [VENTransaction audienceWithString:audienceString];
 
 
 transaction.amount              = [[payment stringForKey:@"amount"] floatValue] * 100;
 transaction.note                = [payment stringForKey:@"note"];
 NSString *statusString          = [payment stringForKey:@"status"];
 transaction.status              = [VENTransaction statusWithString:statusString];
 return transaction;
 }
 */

- (NSError *)addTarget:(VENTransactionTarget *)target {
    NSSet *targetSet = [NSSet setWithObject:target];
    return [self addTargets:targetSet];
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

- (void)sendWithSuccess:(void(^)(VENTransaction *transaction, VENHTTPResponse *response))success
                failure:(void(^)(VENHTTPResponse *reponse, NSError *error))failure {
#warning Unimplemented
    
    for (VENTransactionTarget *target in self.targets) {
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
                break;
        }
        
        switch (self.audience) {
            case VENTransactionAudiencePrivate:
                audienceString = @"private";
                break;
            case VENTransactionAudienceFriends:
                audienceString = @"friends";
                break;
            case VENTransactionAudiencePublic:
                audienceString = @"public";
                break;
            default:
                break;
        }
                amountString = [NSString stringWithFormat:@"%d", target.amount];
        if (self.transactionType == VENTransactionTypeCharge) {
            amountString = [@"-" stringByAppendingString:amountString];
        }
        NSDictionary *parameters = @{recipientTypeKey: target.handle,
                                     @"note"        : self.note,
                                     @"amount"      : amountString,
                                     @"audience"    : audienceString};
        [[VENCore defaultCore].httpClient POST:@"payments"
                                    parameters:parameters
                                       success:^(VENHTTPResponse *response) {
                                           
                                       }
                                       failure:^(VENHTTPResponse *response, NSError *error) {
                                           
                                       }];
        
    }
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

@end
