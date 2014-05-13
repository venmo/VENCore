#import <Foundation/Foundation.h>
#import "VENTransaction.h"

@interface VENCreateTransactionRequest : NSObject

@property (strong, nonatomic, readonly) NSOrderedSet *targets;
@property (strong, nonatomic) NSString *note;
@property (assign, nonatomic) VENTransactionType transactionType;
@property (assign, nonatomic) VENTransactionAudience audience;

/**
 * Sends transactions from the current user to all added targets.
 * @param successBlock The block to be executed after transactions are successfully sent to all targets. This block has no return value and takes two arguments: an array of the VENTransaction objects returned by the sent transactions, and the response from the last transaction.
 * @param failureBlock The block to be executed after a transaction fails. This block has no return value and takes three arguments: an array of the VENTransaction objects returned by the sent transactions, the response from the transaction that failed to send, and an error object.
 */
- (void)sendWithSuccess:(void(^)(NSArray *sentTransactions,
                                 VENHTTPResponse *response))successBlock
                failure:(void(^)(NSArray *sentTransactions,
                                 VENHTTPResponse *response,
                                 NSError *error))failureBlock;
/**
 * Adds a transaction target
 * @note If the target is invalid or a duplicate, addTarget: will return NO
 * and no target will be added to the transaction.
 * @return Returns a Boolean value indicating whether the target was successfully added.
 */
- (BOOL)addTransactionTarget:(VENTransactionTarget *)target;

/**
 * Indicates whether the transaction service is valid and ready to send transactions to its current targets
 */
- (BOOL)readyToSend;

@end
