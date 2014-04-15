#import <UIKit/UIKit.h>
@class VENMutableTransaction, VENUser, VENHTTPResponse, VENTransactionTarget;

typedef NS_ENUM(NSUInteger, VENTransactionType) {
    VENTransactionTypePay,
    VENTransactionTypeCharge
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

@property (copy, nonatomic) NSString *transactionID;
@property (copy, nonatomic, readonly) NSMutableOrderedSet *targets;
@property (copy, nonatomic) NSString *note;
@property (copy, nonatomic) VENUser *actor;
@property (assign, nonatomic) VENTransactionType type;
@property (assign, nonatomic) VENTransactionStatus status;
@property (assign, nonatomic) VENTransactionAudience audience;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Adds a target to a transaction.
 * @note If the target is invalid or a duplicate, addTarget: will return NO
 * and no target will be added to the transaction.
 * @return Returns a Boolean value indicating whether the target was successfully added.
 */
- (BOOL)addTarget:(VENTransactionTarget *)target;

/**
 * Adds multiple targets to a transaction.
 * @note If any of the targets are invalid or duplicates, addTargets: will return NO
 * and no targets will be added to the transaction.
 * @return Returns a Boolean value indicating whether the targets were successfully added.
 */
- (BOOL)addTargets:(NSSet *)targets;

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