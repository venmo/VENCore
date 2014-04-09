#import "VENUser.h"
#import "VENHTTP.h"
#import "NSDictionary+VENCore.h"

@interface VENUser ()

@property (copy, nonatomic, readwrite) NSString *username;
@property (copy, nonatomic, readwrite) NSString *firstName;
@property (copy, nonatomic, readwrite) NSString *lastName;
@property (copy, nonatomic, readwrite) NSString *about;
@property (copy, nonatomic, readwrite) NSString *displayName;
@property (strong, nonatomic, readwrite) NSDate *dateJoined;
@property (copy, nonatomic, readwrite) NSString *profileImageUrl;
@property (copy, nonatomic, readwrite) NSString *phone;
@property (copy, nonatomic, readwrite) NSString *email;
@property (assign, nonatomic, readwrite) NSInteger friendsCount;
@property (copy, nonatomic, readwrite) NSString *userId;
@property (assign, nonatomic, readwrite) BOOL isTrusted;

@end

@implementation VENUser


@end
