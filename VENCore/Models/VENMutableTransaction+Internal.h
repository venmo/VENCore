#import "VENMutableTransaction.h"

@interface VENMutableTransaction (Internal)

/**
 * Initializes a mutable transaction with the given parameters
 */
- (instancetype)initWithTransactionID:(NSString *)transactionID
                                 type:(VENTransactionType)type
                               amount:(NSUInteger)amount
                                 note:(NSString *)note
                           fromUserID:(NSString *)fromUserID
                        recipientType:(VENTargetType)recipientType
                             toUserID:(NSString *)toUserID
                      recipientHandle:(NSString *)recipientHandle
                             audience:(VENTransactionAudience)audience;


/**
 * Returns a dictionary of parameters for sending a payment to the Venmo API.
 */
- (NSDictionary *)parameters;

@end
