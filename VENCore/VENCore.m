#import "VENCore.h"

NSString *const VENErrorDomainCore = @"com.venmo.VENCore.ErrorDomain.VENCore";

static VENCore *sharedInstance = nil;

static NSString *const VENAPIBaseURL = @"https://api.venmo.com/v1";

@implementation VENCore

#pragma mark - Private

- (instancetype)initWithDeviceID:(NSString *)deviceID {
    return [self initWithBaseURL:VENAPIBaseURL deviceID:deviceID];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL deviceID:(NSString *)deviceID {
    self = [super init];
    if (self) {
        self.httpClient = [[VENHTTP alloc] initWithBaseURL:baseURL deviceID:deviceID];
    }
    return self;
}


- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self.httpClient setAccessToken:accessToken];
}


+ (void)setDefaultCore:(VENCore *)core {
    sharedInstance = core;
}


+ (instancetype)defaultCore {
    return sharedInstance;
}

@end
