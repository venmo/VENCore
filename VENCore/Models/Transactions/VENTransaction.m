#import "VENTransaction.h"
#import <Foundation/Foundation.h>
#import "NSDictionary+VENCore.h"
#import "VENMutableTransaction+Internal.h"
#import "VENTransactionTarget.h"

NSString *const VENErrorDomainTransaction = @"com.venmo.VENCore.ErrorDomain.VENTransaction";

@interface VENTransaction ()

@property (copy, nonatomic, readwrite) NSMutableOrderedSet *targets;

@end

@implementation VENTransaction

- (id)init {
    self = [super init];
    if (self) {
        self.targets = [[NSMutableOrderedSet alloc] init];
    }
    return self;
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

    [self.targets addObjectsFromArray:[targets allObjects]];
    return nil;
}

- (void)sendWithSuccess:(void(^)(VENTransaction *transaction, VENHTTPResponse *response))success
                failure:(void(^)(VENHTTPResponse *reponse, NSError *error))failure {
#warning Unimplemented
}


- (BOOL)readyToSend {
#warning Unimplemented
    return NO;
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
