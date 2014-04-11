#import "VENMutableTransaction.h"

@interface VENMutableTransaction ()

@end

@implementation VENMutableTransaction

@synthesize type                   = _type,
amount                             = _amount,
note                               = _note,
fromUserID                         = _fromUserID,
transactionID                      = _transactionID,
toUserType                         = _toUserType,
toUserID                           = _toUserID,
status                             = _status,
audience                           = _audience,
toUserHandle                       = _toUserHandle;

+ (instancetype)transactionWithType:(VENTransactionType)type
                             amount:(NSUInteger)amount
                               note:(NSString *)note
                           audience:(VENTransactionAudience)audience
                      recipientType:(VENRecipientType)recipientType
                    recipientString:(NSString *)recipientString {

    VENMutableTransaction *transaction = [[[self class] alloc] init];
    transaction.type                   = type;
    transaction.amount                 = amount;
    transaction.note                   = [note copy];
    transaction.audience               = audience;
    transaction.toUserType             = recipientType;
    transaction.toUserHandle           = [recipientString copy];
    transaction.status                 = VENTransactionStatusNone;

    return transaction;
}


@end
