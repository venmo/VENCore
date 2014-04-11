#import "VENTransaction.h"
#import <Foundation/Foundation.h>
#import "NSDictionary+VENCore.h"
#import "VENMutableTransaction.h"

@interface VENTransaction ()

@property (strong, nonatomic, readwrite) NSString *transactionID;
@property (assign, nonatomic, readwrite) VENTransactionType type;
@property (assign, nonatomic, readwrite) NSUInteger amount;
@property (strong, nonatomic, readwrite) NSString *note;
@property (strong, nonatomic, readwrite) NSString *fromUserID;
@property (assign, nonatomic, readwrite) VENRecipientType toUserType;
@property (strong, nonatomic, readwrite) NSString *toUserHandle; // cell number, email, or Venmo user ID.
@property (strong, nonatomic, readwrite) NSString *toUserID;
@property (assign, nonatomic, readwrite) VENTransactionStatus status;
@property (assign, nonatomic, readwrite) VENTransactionAudience audience;

@end

@implementation VENTransaction


+ (VENTransactionType)typeWithString:(NSString *)string {
    return [[string lowercaseString] isEqualToString:@"charge"] ?
    VENTransactionTypeCharge : VENTransactionTypePay;
}


+ (VENTransactionStatus)statusWithString:(NSString *)string {
    VENTransactionStatus status = VENTransactionStatusNone;
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


- (NSString *)recipientTypeString {
    switch (self.toUserType) {
        case VENRecipientTypeEmail:
            return @"email";
            break;

        case VENRecipientTypePhone:
            return @"phone";
            break;

        case VENRecipientTypeUserID:
            return @"user_id";
            break;
    }
}


- (NSString *)audienceString {
    switch (self.audience) {
        case VENTransactionAudiencePrivate:
            return @"private";
            break;

        case VENTransactionAudienceFriends:
            return @"friends";
            break;

        case VENTransactionAudiencePublic:
            return @"public";
            break;

        default:
            break;
    }
}


- (NSString *)amountString {
    if (self.amount < 1) {
        return @"";
    }
    CGFloat amount = self.amount / 100.0f;
    NSString *amountStr = [NSString stringWithFormat:@"%.2f", amount];
    return amountStr;
}


- (NSDictionary *)dictionaryRepresentation {
    NSString *recipientTypeKey = [self recipientTypeString];
    return @{recipientTypeKey : self.toUserHandle,
             @"note" : self.note,
             @"amount" : self.type == VENTransactionTypePay ? [self amountString] : [NSString stringWithFormat:@"-%@", [self amountString]],
             @"audience" : [self audienceString]};
}


- (VENMutableTransaction *)mutableCopy {
    VENMutableTransaction *mutableTransaction = [[VENMutableTransaction alloc] init];
    mutableTransaction.transactionID = self.transactionID;
    mutableTransaction.type          = self.type;
    mutableTransaction.amount        = self.amount;
    mutableTransaction.note          = self.note;
    mutableTransaction.fromUserID    = self.fromUserID;
    mutableTransaction.toUserType    = self.toUserType;
    mutableTransaction.toUserID      = self.toUserID;
    mutableTransaction.toUserHandle  = self.toUserHandle;
    mutableTransaction.audience      = self.audience;
    return mutableTransaction;
}

#pragma mark - Private

+ (instancetype)transactionWithPaymentObject:(NSDictionary *)payment {
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
        transaction.toUserHandle    = targetPhone;
        transaction.toUserType      = VENRecipientTypePhone;
    }
    if (targetEmail) {
        transaction.toUserHandle    = targetEmail;
        transaction.toUserType      = VENRecipientTypeEmail;
    }

    if (targetUser) {
        transaction.toUserType      = VENRecipientTypeUserID;
        transaction.toUserHandle    = [targetUser stringForKey:@"id"];
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

@end
