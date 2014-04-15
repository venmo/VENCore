#import "VENTransaction.h"
#import "VENTransactionTarget.h"

@class VENHTTPResponse;

@interface VENMutableTransaction : VENTransaction

@property (assign, nonatomic, readwrite) VENTransactionType type;
@property (assign, nonatomic, readwrite) NSUInteger amount;
@property (copy, nonatomic, readwrite) NSString *note;
@property (assign, nonatomic, readwrite) VENTransactionAudience audience;
@property (assign, nonatomic, readwrite) VENTargetType recipientType;
@property (copy, nonatomic, readwrite) NSString *recipientHandle; // cell number, email, or Venmo user ID.

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
                      recipientType:(VENTargetType)recipientType
                    recipientString:(NSString *)recipientString;


/**
 * Sends a transaction.
 * @param success TODO: fill out doc
 * @param failure
 */
- (void)sendWithSuccess:(void(^)(VENTransaction *transaction, VENHTTPResponse *response))success
                failure:(void(^)(VENHTTPResponse *response, NSError *error))failure;

/**
 * Indicates whether the transaction is valid and ready to post to the service
 */
- (BOOL)readyToSend;

@end
