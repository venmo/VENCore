#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VENTransactionType) {
    VENTransactionTypePay,
    VENTransactionTypeCharge
};

typedef NS_ENUM(NSUInteger, VENRecipientType) {
    VENRecipientTypePhone,
    VENRecipientTypeEmail,
    VENRecipientTypeUserID
};

// TODO: what are the possible transaction statuses?
// TODO: VENMutableTransaction should not have transactionID, status, fromUserID, or toUserID.
typedef NS_ENUM(NSUInteger, VENTransactionStatus) {
    VENTransactionStatusNone,
    VENTransactionStatusPending,
    VENTransactionStatusSettled
};

typedef NS_ENUM(NSUInteger, VENTransactionAudience) {
    VENTransactionAudiencePrivate,
    VENTransactionAudienceFriends,
    VENTransactionAudiencePublic
};

@interface VENTransaction : NSObject

@property (strong, nonatomic, readonly) NSString *transactionID;
@property (assign, nonatomic, readonly) VENTransactionType type;
@property (assign, nonatomic, readonly) NSUInteger amount;
@property (strong, nonatomic, readonly) NSString *note;
@property (strong, nonatomic, readonly) NSString *fromUserID;
@property (assign, nonatomic, readonly) VENRecipientType toUserType;
@property (strong, nonatomic, readonly) NSString *toUserHandle; // cell number, email, or Venmo user ID.
@property (strong, nonatomic, readonly) NSString *toUserID;
@property (assign, nonatomic, readonly) VENTransactionStatus status;
@property (assign, nonatomic, readonly) VENTransactionAudience audience;

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
