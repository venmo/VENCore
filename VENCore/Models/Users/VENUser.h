#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VENUser;

typedef void(^VENUserFetchSuccessBlock)(VENUser *user);
typedef void(^VENUserFetchFailureBlock)(NSError *error);

/**
 * @note Users are considered equal if and only if their external IDs are the same
 */
@interface VENUser : NSObject <NSCopying>

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSString *about;
@property (copy, nonatomic) NSString *profileImageUrl;
@property (copy, nonatomic) NSString *primaryPhone;
@property (copy, nonatomic) NSString *primaryEmail;
@property (copy, nonatomic) NSString *internalId;
@property (copy, nonatomic) NSString *externalId;
@property (strong, nonatomic) NSDate *dateJoined;


/**
 * Initializes a user with a dictionary of User object keys.
 * @param The dictionary to extract keys from to create a VENUser
 * @return VENUser object described in dictionary
 * @note Calling code should call canInitWithDictionary first
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 * Creates a dictionary containing all keys set on the user.
 * This dictionary can be passed to initWithDictionary to recreate the object.

 * @return NSDictionary object with all fields set on the VENUser
 */
- (NSDictionary *)dictionaryRepresentation;


/**
 * Determines whether the dictionary represents a valid user
 * @param The dictionary for evaluation of whether it can create a valid VENUser
 * @return BOOL indicating whether this dictionary can create a valid VENUser
 * @note This should be called before initWithDictionary:
 */
+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary;


/**
 * Asynchronously fetch a user with a given externalId
 * @param externalId An NSString of the desired users externalId
 * @param successBlock A block to be executed with the fetched user
 * @param failureBlock A block to be executed in case of failure / error
 * @note This may return from a cache or pull from the network
 */
+ (void)fetchUserWithExternalId:(NSString *)externalId
                        success:(VENUserFetchSuccessBlock)successBlock
                        failure:(VENUserFetchFailureBlock)failureBlock;


@end