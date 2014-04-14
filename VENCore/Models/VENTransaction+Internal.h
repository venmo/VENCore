#import "VENTransaction.h"

@interface VENTransaction (Internal)

/**
 * Returns a VENTransaction instance with the given payment object from the Venmo API,
 * or nil if no transaction can be created.
 */
+ (instancetype)transactionWithPaymentObject:(NSDictionary *)payment;

@end
