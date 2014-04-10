#import <Foundation/Foundation.h>

extern NSString *const VENErrorDomain;

@interface NSError (VENCore)

/**
 * Returns an NSError object with the given domain, code, description, and recovery suggestion.
 * @param code The error code
 * @param description A description of the error
 * @param recoverySuggestion A description of how to recover from the error
 */
+ (instancetype)errorWithCode:(NSInteger)code
                  description:(NSString *)description
           recoverySuggestion:(NSString *)recoverySuggestion;

/**
 * Returns the default error for failing VENHTTP responses.
 */
+ (instancetype)defaultResponseError;


@end
