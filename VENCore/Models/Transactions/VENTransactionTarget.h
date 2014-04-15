#import <Foundation/Foundation.h>

@class VENUser;

typedef NS_ENUM(NSUInteger, VENRecipientType) {
    VENRecipientTypePhone,
    VENRecipientTypeEmail,
    VENRecipientTypeUserID
};

@interface VENTransactionTarget : NSObject

@property (assign, nonatomic) VENRecipientType type;
@property (copy, nonatomic) NSString *handle; // cell number, email, or Venmo user ID.
@property (assign, nonatomic) NSUInteger amount;
@property (copy, nonatomic) VENUser *user;


/**
 * Initializes a target with the given handle.
 * @param handle A phone number, email, or Venmo external user ID.
 * @return A VENTransactionTarget instance
 */
- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSUInteger)amount;

@end
