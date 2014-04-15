#import "VENTransactionTarget.h"

@interface NSString (VENCore)

- (BOOL)isUSPhone;
- (BOOL)isEmail;
- (BOOL)isUserId;
- (VENTargetType)targetType;

@end
