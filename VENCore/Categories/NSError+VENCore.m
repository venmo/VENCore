#import "NSError+VENCore.h"
#import "VENErrors.h"

NSString *const VENErrorDomain = @"com.venmo.VENCore.ErrorDomain";

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
    return [self errorWithCode: description:NSLocalizedString(@"Bad response", nil) recoverySuggestion:@"Deal with it."];
}

@end
