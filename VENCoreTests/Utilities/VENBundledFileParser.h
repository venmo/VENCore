#import <Foundation/Foundation.h>

@interface VENBundledFileParser : NSObject

+ (id)objectFromJSONResource:(NSString *)name;

+ (NSString *)stringFromJSONResource:(NSString *)name;

@end
