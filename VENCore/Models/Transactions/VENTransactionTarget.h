#import <Foundation/Foundation.h>

@class VENUser;

typedef NS_ENUM(NSUInteger, VENTargetType) {
    VENTargetTypePhone,
    VENTargetTypeEmail,
    VENTargetTypeUserID
};

@interface VENTransactionTarget : NSObject

@property (assign, nonatomic) VENTargetType type;
@property (copy, nonatomic) NSString *handle; // cell number, email, or Venmo user ID.
@property (assign, nonatomic) NSUInteger amount;
@property (copy, nonatomic) VENUser *user;


/**
 * Initializes a target with the given handle.
 * @param handle A phone number, email, or Venmo external user ID.
 * @param amount The amount in pennies.
 * @return A VENTransactionTarget instance
 */
- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSUInteger)amount;

@end
