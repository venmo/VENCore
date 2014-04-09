#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VENUser : NSObject

@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *about;
@property (copy, nonatomic, readonly) NSString *displayName;
@property (strong, nonatomic, readonly) NSDate *dateJoined;
@property (copy, nonatomic, readonly) NSString *phone;
@property (copy, nonatomic, readonly) NSString *profileImageUrl;
@property (copy, nonatomic, readonly) NSString *email;
@property (assign, nonatomic, readonly) NSInteger friendsCount;
@property (copy, nonatomic, readonly) NSString *internalId;
@property (copy, nonatomic, readonly) NSString *externalId;
@property (assign, nonatomic, readonly) BOOL isTrusted;

@end