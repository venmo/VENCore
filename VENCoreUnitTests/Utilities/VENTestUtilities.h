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
 * Returns the base URL string of the given core instance.
 */
+ (NSString *)baseURLStringForCore:(VENCore *)core;

/**
 * Stubs a GET of a URL with the contents of the file at the given path
 * @note Adds all default header parmeters
 */
+ (void)stubNetworkGET:(NSString *)path
        withStatusCode:(NSInteger)statusCode
   andResponseFilePath:(NSString *)filePath;


/**
 * Stubs a POST of a URL with the given parameters with the contents of the file at the given path
 * @note Adds all default header parmeters
 */
+ (void)stubNetworkPOST:(NSString *)path
          forParameters:(NSDictionary *)dictionary
         withStatusCode:(NSInteger)statusCode
    andResponseFilePath:(NSString *)filePath;


/**
 * Returns the value for the key "access_token" in the bundle's config.plist
 */
+ (NSString *)accessToken;


@end
