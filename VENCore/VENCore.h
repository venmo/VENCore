#import <Foundation/Foundation.h>
#import "NSError+VENCore.h"
#import "VENHTTP.h"

NSString *const VENErrorDomainCore;

NS_ENUM(NSInteger, VENCoreErrorCode) {
    VENCoreErrorCodeNoDefaultCore,
    VENCoreErrorCodeNoAccessToken
};

@class VENTransaction, VENUser;

@interface VENCore : NSObject

@property (strong, nonatomic) VENHTTP *httpClient;
@property (strong, nonatomic) NSString *accessToken;

/**
 * Sets the shared core object.
 * @param core The core object to share.
 */
+ (void)setDefaultCore:(VENCore *)core;


/**
 * Returns the shared core object.
 * @return A VENCore object.
 */
+ (instancetype)defaultCore;


/**
 * Sets the core object's access token.
 */
- (void)setAccessToken:(NSString *)accessToken;

@end
