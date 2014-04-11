#import "VENTransaction+Internal.h"

@interface VENMutableTransaction : VENTransaction

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

/**
 * Creates a new transaction.
 * @param type The transaction type (pay or charge)
 * @param amount The amount (in pennies)
 * @param note The payment note
 * @param audience The audience
 * @param recipientType The recipient type (phone, email, or user id)
 * @param recipientString The recipient's phone number, email, or Venmo user ID
 * @return The initialized transaction
 */
+ (instancetype)transactionWithType:(VENTransactionType)type
                             amount:(NSUInteger)amount
                               note:(NSString *)note
                           audience:(VENTransactionAudience)audience
                      recipientType:(VENRecipientType)recipientType
                    recipientString:(NSString *)recipientString;



@end
