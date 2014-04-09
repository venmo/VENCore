#import <Foundation/Foundation.h>

extern NSString *const VENErrorDomain;

enum {
    VENErrorLoginFailed = 1,
    VENErrorTransactionFailed,
    VENErrorNoAccessToken,
    VENErrorUserRequestFailed
};
