#import <Foundation/Foundation.h>
#import "VENTransaction.h"

@interface VENTransactionService : NSObject

@property (strong, nonatomic, readonly) NSOrderedSet *targets;
@property (strong, nonatomic) NSString *note;
@property (assign, nonatomic) VENTransactionType transactionType;
@property (assign, nonatomic) VENTransactionAudience audience;

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
 * Adds a target to a transaction.
 * @note If the target is invalid or a duplicate, addTarget: will return NO
 * and no target will be added to the transaction.
 * @return Returns a Boolean value indicating whether the target was successfully added.
 */
- (BOOL)addTransactionTarget:(VENTransactionTarget *)target;

/**
 * Indicates whether the transaction is valid and ready to post to the service
 */
- (BOOL)readyToSend;

@end
