#import "VENTransaction.h"
#import <Foundation/Foundation.h>
#import "NSDictionary+VENCore.h"
#import "VENMutableTransaction+Internal.h"
#import "VENTransactionPayloadKeys.h"

@interface VENTransaction ()

@property (copy, nonatomic, readwrite) NSString *transactionID;
@property (assign, nonatomic, readwrite) VENTransactionType type;
@property (assign, nonatomic, readwrite) NSUInteger amount;
@property (copy, nonatomic, readwrite) NSString *note;
@property (copy, nonatomic, readwrite) NSString *fromUserID;
@property (assign, nonatomic, readwrite) VENRecipientType recipientType;
@property (copy, nonatomic, readwrite) NSString *recipientHandle; // cell number, email, or Venmo user ID.
@property (copy, nonatomic, readwrite) NSString *toUserID;
@property (assign, nonatomic, readwrite) VENTransactionStatus status;
@property (assign, nonatomic, readwrite) VENTransactionAudience audience;

@end

@implementation VENTransaction

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
#warning Incomplete implementation
    self = [super init];
    if (self) {
        NSDictionary *cleanDictionary = [dictionary dictionaryByCleansingResponseDictionary];
        
        self.transactionID  = cleanDictionary[VENTransactionIDKey];
        self.amount         = [cleanDictionary[VENTransactionAmountKey] unsignedIntegerValue];
        self.note           = cleanDictionary[VENTransactionNoteKey];
        self.fromUserID     = cleanDictionary[VENTransactionActorKey][VENTransactionActorUserID];
        
        NSDictionary *target = cleanDictionary[VENTransactionTargetKey];
        NSString *targetTypeString = [target[VENTransactionTargetTypeKey] lowercaseString];
        
        if ([targetTypeString isEqualToString:@"email"]) {
            self.recipientType = VENRecipientTypeEmail;
            self.recipientHandle = target[VENTransactionTargetEmailKey];
        }
        else if ([targetTypeString isEqualToString:@"phone"]) {
            self.recipientType = VENRecipientTypePhone;
            self.recipientHandle = target[VENTransactionTargetPhoneKey];
        }
        else if ([targetTypeString isEqualToString:@"user"]) {
            NSDictionary *user = target[VENTransactionTargetUserKey];
            self.recipientType = VENRecipientTypeUserID;
            self.recipientHandle = user[VENTransactionTargetUserIDKey];
        }
        
#warning should we call transaction type charge?
        
        self.type = ([[cleanDictionary[VENTransactionTypeKey] lowercaseString] isEqualToString:@"charge"]) ? VENTransactionTypeCharge : VENTransactionTypePay;
        NSString *statusString = cleanDictionary[VENTransactionStatusKey];
        if ([statusString isEqualToString:@"pending"]) {
            self.status = VENTransactionStatusPending;
        }
        else if ([statusString isEqualToString:@"settled"]) {
            self.status = VENTransactionStatusSettled;
        }
        else {
            self.status = VENTransactionStatusNotSent;
        }
        NSString *audienceString = cleanDictionary[VENTransactionAudienceKey];
        if ([audienceString isEqualToString:@"public"]) {
            self.audience = VENTransactionAudiencePublic;
        }
        else if ([audienceString isEqualToString:@"friends"]) {
            self.audience = VENTransactionAudienceFriends;
        }
        else {
            self.audience = VENTransactionAudiencePrivate;
        }
    }
    
    return self;
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


- (VENMutableTransaction *)mutableCopy {
    VENMutableTransaction *mutableTransaction =
    [[VENMutableTransaction alloc] initWithTransactionID:self.transactionID
                                                    type:self.type
                                                  amount:self.amount
                                                    note:self.note
                                              fromUserID:self.fromUserID
                                           recipientType:self.recipientType
                                                toUserID:self.toUserID
                                         recipientHandle:self.recipientHandle
                                                audience:self.audience];
    return mutableTransaction;
}

#pragma mark - Private

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
        transaction.recipientType      = VENRecipientTypePhone;
    }
    if (targetEmail) {
        transaction.recipientHandle    = targetEmail;
        transaction.recipientType      = VENRecipientTypeEmail;
    }

    if (targetUser) {
        transaction.recipientType      = VENRecipientTypeUserID;
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

@end
