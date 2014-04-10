#import <Foundation/Foundation.h>
#import "NSError+VENCore.h"

@class VENTransaction, VENUser, VENHTTP;

@interface VENCore : NSObject

@property (strong, nonatomic) VENHTTP *httpClient;

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
 * Initializes a VENCore instance with the given client id and client secret.
 * @param clientID Your client ID
 * @param clientSecret Your client secret
 * @return A VENCore object.
 */
- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret;


/**
 * Sets the core object's access token.
 */
- (void)setAccessToken:(NSString *)accessToken;

@end
