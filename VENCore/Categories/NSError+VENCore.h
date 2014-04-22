#import <Foundation/Foundation.h>

@interface NSError (VENCore)

/**
 * Returns an NSError object with the given domain, code, description, and recovery suggestion.
 * @param code The error code
 * @param description A description of the error
 * @param recoverySuggestion A description of how to recover from the error
 */
+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                    description:(NSString *)description
             recoverySuggestion:(NSString *)recoverySuggestion;

/**
 * Returns the default error for failing VENHTTP responses.
 */
+ (instancetype)defaultResponseError;


/**
 * Returns an error indicating that no default core has been set.
 */
+ (instancetype)noDefaultCoreError;


/**
 * Returns an error indicating that the default VENCore instance
 * doesn't have an access token.
 */
+ (instancetype)noAccessTokenError;

@end
