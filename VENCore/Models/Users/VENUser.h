#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**

 @note Users are considered equal if and only if their external IDs are the same
 */

@interface VENUser : NSObject <NSCopying>

@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *displayName;
@property (copy, nonatomic, readonly) NSString *about;
@property (copy, nonatomic, readonly) NSString *phone;
@property (copy, nonatomic, readonly) NSString *profileImageUrl;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *internalId;
@property (copy, nonatomic, readonly) NSString *externalId;
@property (strong, nonatomic, readonly) NSDate *dateJoined;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary;


@end