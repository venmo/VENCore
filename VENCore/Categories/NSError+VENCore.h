#import <Foundation/Foundation.h>

@interface NSError (VENCore)

/**
 * Returns an NSError object with the given domain, code, description, and recovery suggestion.
 * @param domain The error domain
 * @param code The error code
 * @param description A description of the error
 * @param recoverySuggestion A description of how to recover from the error
 */
+ (id)errorWithDomain:(NSString *)domain
                 code:(NSInteger)code
          description:(NSString *)description
   recoverySuggestion:(NSString *)recoverySuggestion;

@end
