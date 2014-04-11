#import "VENMutableTransaction.h"

@interface VENMutableTransaction ()

@property (assign, nonatomic, readwrite) VENTransactionStatus status;

@end

@implementation VENMutableTransaction

@synthesize type = _type,
amount           = _amount,
note             = _note,
fromUserID       = _fromUserID,
transactionID    = _transactionID,
recipientType    = _recipientType,
toUserID         = _toUserID,
status           = _status,
audience         = _audience,
recipientHandle  = _recipientHandle;

+ (instancetype)transactionWithType:(VENTransactionType)type
                             amount:(NSUInteger)amount
                               note:(NSString *)note
                           audience:(VENTransactionAudience)audience
                      recipientType:(VENRecipientType)recipientType
                    recipientString:(NSString *)recipientString {

    VENMutableTransaction *transaction = [[[self class] alloc] init];
    transaction.type                   = type;
    transaction.amount                 = amount;
    transaction.note                   = note;
    transaction.audience               = audience;
    transaction.recipientType          = recipientType;
    transaction.recipientHandle        = recipientString;
    transaction.status                 = VENTransactionStatusNotSent;

    return transaction;
}


@end
