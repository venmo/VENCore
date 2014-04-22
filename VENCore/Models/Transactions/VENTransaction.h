#import <UIKit/UIKit.h>
#import "VENTransactionTarget.h"

@class VENMutableTransaction, VENUser, VENHTTPResponse;

typedef NS_ENUM(NSUInteger, VENTransactionType) {
    VENTransactionTypeUnknown,
    VENTransactionTypePay,
    VENTransactionTypeCharge
};
extern NSString *const VENTransactionTypeStrings[];

// TODO: what are the possible transaction statuses?
// TODO: VENMutableTransaction should not have transactionID, status, fromUserID, or toUserID.
typedef NS_ENUM(NSUInteger, VENTransactionStatus) {
    VENTransactionStatusNotSent,
    VENTransactionStatusPending,
    VENTransactionStatusSettled,
    VENTransactionStatusFailed
};
extern NSString *const VENTransactionStatusStrings[];

typedef NS_ENUM(NSUInteger, VENTransactionAudience) {
    VENTransactionAudiencePrivate,
    VENTransactionAudienceFriends,
    VENTransactionAudiencePublic
};
extern NSString *const VENTransactionAudienceStrings[];

extern NSString *const VENErrorDomainTransaction;

typedef NS_ENUM(NSUInteger, VENErrorCodeTransaction) {
    VENErrorCodeTransactionDuplicateTarget,
    VENErrorCodeTransactionInvalidTarget
};

@interface VENTransaction : NSObject

@property (copy, nonatomic) NSString *transactionID;
@property (strong, nonatomic, readonly) NSOrderedSet *targets;
@property (copy, nonatomic) NSString *note;
@property (copy, nonatomic) VENUser *actor;
@property (assign, nonatomic) VENTransactionType transactionType;
@property (assign, nonatomic) VENTransactionStatus status;
@property (assign, nonatomic) VENTransactionAudience audience;

/**
 * Creates a VENTransaction from a dictionary representation
 * @note should call canInitWithDictionary first
 * @return Returns an instance of VENTransaction
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary;

/**
 * Adds a target to a transaction.
 * @note If the target is invalid or a duplicate, addTarget: will return NO
 * and no target will be added to the transaction.
 * @return Returns a Boolean value indicating whether the target was successfully added.
 */
- (BOOL)addTransactionTarget:(VENTransactionTarget *)target;


/**
 * Sends a transaction.
 * @param successBlock The block called after all targets are successfully sent.
 * @param failureBlock The block called after a target is unable to be sent.
 */
- (void)sendWithSuccess:(void(^)(NSOrderedSet *sentTransactions,
                                 VENHTTPResponse *response))successBlock
                failure:(void(^)(NSOrderedSet *sentTransactions,
                                 VENHTTPResponse *response,
                                 NSError *error))failureBlock;


/**
 * Indicates whether the transaction is valid and ready to post to the service
 */
- (BOOL)readyToSend;

@end
