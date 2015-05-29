@import Foundation;

#import <VENCore/NSString+VENCore.h>
#import <VENCore/NSArray+VENCore.h>
#import <VENCore/NSDictionary+VENCore.h>
#import <VENCore/NSError+VENCore.h>
#import <VENCore/NSString+VENCore.h>
#import <VENCore/UIDevice+VENCore.h>
#import <VENCore/VENCreateTransactionRequest.h>
#import <VENCore/VENTransaction.h>
#import <VENCore/VENTransactionPayloadKeys.h>
#import <VENCore/VENTransactionTarget.h>
#import <VENCore/VENUser.h>
#import <VENCore/VENUserPayloadKeys.h>
#import <VENCore/VENHTTP.h>
#import <VENCore/VENHTTPResponse.h>

extern NSString *const VENErrorDomainCore;

typedef NS_ENUM(NSInteger, VENCoreErrorCode) {
    VENCoreErrorCodeNoDefaultCore,
    VENCoreErrorCodeNoAccessToken
};

@class VENTransaction, VENUser, VENHTTP;

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
