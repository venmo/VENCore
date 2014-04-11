#import "VENTransaction.h"

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

@end
