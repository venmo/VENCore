@import Foundation;

#import <VENCore/VENCreateTransactionRequest.h>
#import <VENCore/VENHTTP.h>
#import <VENCore/VENHTTPResponse.h>
#import <VENCore/VENTransaction.h>
#import <VENCore/VENTransactionTarget.h>
#import <VENCore/VENUser.h>

extern NSString *const VENErrorDomainCore;

typedef NS_ENUM(NSInteger, VENCoreErrorCode) {
    VENCoreErrorCodeNoDefaultCore,
    VENCoreErrorCodeNoAccessToken
};

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
