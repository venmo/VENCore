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

@end
