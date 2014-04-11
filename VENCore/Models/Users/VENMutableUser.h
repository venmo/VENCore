#import "VENUser.h"

@interface VENMutableUser : VENUser

@property (copy, nonatomic, readwrite) NSString *username;
@property (copy, nonatomic, readwrite) NSString *firstName;
@property (copy, nonatomic, readwrite) NSString *lastName;
@property (copy, nonatomic, readwrite) NSString *displayName;
@property (copy, nonatomic, readwrite) NSString *about;
@property (copy, nonatomic, readwrite) NSString *phone;
@property (copy, nonatomic, readwrite) NSString *profileImageUrl;
@property (copy, nonatomic, readwrite) NSString *email;
@property (copy, nonatomic, readwrite) NSString *internalId;
@property (copy, nonatomic, readwrite) NSString *externalId;
@property (strong, nonatomic, readwrite) NSDate *dateJoined;

@end
