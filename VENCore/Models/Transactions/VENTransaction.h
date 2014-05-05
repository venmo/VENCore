#import <UIKit/UIKit.h>
#import "VENTransactionTarget.h"

@class VENMutableTransaction, VENUser, VENHTTPResponse;

typedef NS_ENUM(NSUInteger, VENTransactionType) {
    VENTransactionTypeUnknown,
    VENTransactionTypePay,
    VENTransactionTypeCharge
};
extern NSString *const VENTransactionTypeStrings[];

typedef NS_ENUM(NSUInteger, VENTransactionStatus) {
    VENTransactionStatusUnknown,
    VENTransactionStatusPending,
    VENTransactionStatusSettled,
    VENTransactionStatusFailed
};
extern NSString *const VENTransactionStatusStrings[];

typedef NS_ENUM(NSUInteger, VENTransactionAudience) {
    // Indicates that the transaction uses/should use the user's default sharing setting
    VENTransactionAudienceUserDefault,
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

@property (copy, nonatomic, readonly) NSString *transactionID;
@property (strong, nonatomic, readonly) VENTransactionTarget *target;
@property (copy, nonatomic, readonly) NSString *note;
@property (copy, nonatomic, readonly) VENUser *actor;
@property (assign, nonatomic, readonly) VENTransactionType transactionType;
@property (assign, nonatomic, readonly) VENTransactionStatus status;
@property (assign, nonatomic, readonly) VENTransactionAudience audience;

+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary;

/**
 * Creates a VENTransaction from a dictionary representation
 * @note should call canInitWithDictionary first
 * @return Returns an instance of VENTransaction
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
