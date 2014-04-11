#import "NSError+VENCore.h"
#import "VENHTTPResponse.h"
#import "VENCore.h"
#import "VENCoreError.h"

@implementation NSError (VENCore)

+ (instancetype)errorWithCode:(NSInteger)code
                  description:(NSString *)description
           recoverySuggestion:(NSString *)recoverySuggestion {

    NSDictionary *errorUserInfo =
    [NSDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(description, nil), NSLocalizedDescriptionKey,
     NSLocalizedString(recoverySuggestion, nil), NSLocalizedRecoverySuggestionErrorKey, nil];

    return [self errorWithDomain:VENErrorDomain code:code userInfo:errorUserInfo];
}


+ (instancetype)defaultResponseError {
    return [self errorWithCode:VENCoreErrorCodeBadResponse
                   description:NSLocalizedString(@"Bad response", nil)
            recoverySuggestion:nil];
}


+ (instancetype)noDefaultCoreError {
    return [self errorWithCode:VENCoreErrorCodeNoDefaultCore
                   description:NSLocalizedString(@"No default core", nil)
            recoverySuggestion:NSLocalizedString(@"Use setDefaultCore to set the default VENCore instance.", nil)];
}

@end
