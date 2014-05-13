#import <Foundation/Foundation.h>
#import "VENUser.h"

typedef NS_ENUM(NSUInteger, VENTargetType) {
    VENTargetTypeUnknown,
    VENTargetTypePhone,
    VENTargetTypeEmail,
    VENTargetTypeUserId
};

@interface VENTransactionTarget : NSObject

@property (assign, nonatomic) VENTargetType targetType;
@property (copy, nonatomic) NSString *handle; // cell number, email, or Venmo user ID.
@property (assign, nonatomic) NSUInteger amount;
@property (copy, nonatomic) VENUser *user;

/**
 * Determines whether the passed NSDictionary can construct a valid TransactionTarget
 */
+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary;


/**
 * Initializes a target with the given handle.
 * @param handle A phone number, email, or Venmo external user ID.
 * @param amount The amount in pennies.
 * @return A VENTransactionTarget instance
 */
- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSInteger)amount;


/**
 * Initializes a target from a payload dictionary
 * @param dictionary A dictionary supplied in a payload
 * @return A VENTransactionTarget instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 * Returns YES if the target is valid.
 */
- (BOOL)isValid;


/**
 * Sets the target's user object and sets the target's handle to the user's external ID.
 */
- (void)setUser:(VENUser *)user;


/**
 * Creates a dictionary representation of the object
 * @return A dictionary representation of the object
 */
- (NSDictionary *)dictionaryRepresentation;

@end
