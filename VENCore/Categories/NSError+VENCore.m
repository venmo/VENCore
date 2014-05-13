#import "NSError+VENCore.h"
#import "VENHTTPResponse.h"
#import "VENCore.h"

@implementation NSError (VENCore)

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                    description:(NSString *)description
             recoverySuggestion:(NSString *)recoverySuggestion {

    NSDictionary *errorUserInfo =
    [NSDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(description, nil), NSLocalizedDescriptionKey,
     NSLocalizedString(recoverySuggestion, nil), NSLocalizedRecoverySuggestionErrorKey, nil];

    return [self errorWithDomain:domain code:code userInfo:errorUserInfo];

}


+ (instancetype)defaultResponseError {
    return [self errorWithDomain:VENErrorDomainHTTPResponse
                            code:VENErrorCodeHTTPResponseBadResponse
                     description:NSLocalizedString(@"Bad response", nil)
              recoverySuggestion:nil];
}


+ (instancetype)noDefaultCoreError {
    return [self errorWithDomain:VENErrorDomainCore
                            code:VENCoreErrorCodeNoDefaultCore
                     description:NSLocalizedString(@"No default core", nil)
              recoverySuggestion:NSLocalizedString(@"Use setDefaultCore to set the default VENCore instance.", nil)];
}


+ (instancetype)noAccessTokenError {
    return [self errorWithDomain:VENErrorDomainCore
                            code:VENCoreErrorCodeNoAccessToken
                     description:NSLocalizedString(@"No access token", nil)
              recoverySuggestion:NSLocalizedString(@"Set the default core's access token.", nil)];
}

@end
