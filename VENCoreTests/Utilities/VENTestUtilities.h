#import <Foundation/Foundation.h>

@class VENCore;

@interface VENTestUtilities : NSObject

/**
 * Returns the Foundation object value of the given json file.
 */
+ (id)objectFromJSONResource:(NSString *)name;


/**
 * Returns the string value of the given json file.
 */
+ (NSString *)stringFromJSONResource:(NSString *)name;


/**
 * Returns the AFNetworking-generating query string with the given parameters
 */
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;


/**
 * Returns the base URL string of the given core instance.
 */
+ (NSString *)baseURLStringForCore:(VENCore *)core;

@end
