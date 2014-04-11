#import "VENBundledFileParser.h"

@implementation VENBundledFileParser

+ (id)objectFromJSONResource:(NSString *)name {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"json"];
    NSString *fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding
                                                        error:NULL];
    return [NSJSONSerialization JSONObjectWithData:[fileString dataUsingEncoding:
                                             NSUTF8StringEncoding] options:0 error:nil];
}

@end
