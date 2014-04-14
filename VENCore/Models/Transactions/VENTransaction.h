#import <UIKit/UIKit.h>
@class VENMutableTransaction;

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
    VENTransactionStatusNotSent,
    VENTransactionStatusPending,
    VENTransactionStatusSettled
};

typedef NS_ENUM(NSUInteger, VENTransactionAudience) {
    VENTransactionAudiencePrivate,
    VENTransactionAudienceFriends,
    VENTransactionAudiencePublic
};

@interface VENTransaction : NSObject

@property (copy, nonatomic, readonly) NSString *transactionID;
@property (assign, nonatomic, readonly) VENTransactionType type;
@property (assign, nonatomic, readonly) NSUInteger amount;
@property (copy, nonatomic, readonly) NSString *note;
@property (copy, nonatomic, readonly) NSString *fromUserID;
@property (assign, nonatomic, readonly) VENRecipientType recipientType;
@property (copy, nonatomic, readonly) NSString *recipientHandle; // cell number, email, or Venmo user ID.
@property (copy, nonatomic, readonly) NSString *toUserID;
@property (assign, nonatomic, readonly) VENTransactionStatus status;
@property (assign, nonatomic, readonly) VENTransactionAudience audience;


/**
 * Returns a new mutable copy of the receiver.
 */
- (VENMutableTransaction *)mutableCopy;

@end
