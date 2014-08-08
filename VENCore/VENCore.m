#import "VENCore.h"

NSString *const VENErrorDomainCore = @"com.venmo.VENCore.ErrorDomain.VENCore";

static VENCore *sharedInstance = nil;

static NSString *const VENAPIBaseURL = @"https://api.venmo.com/v1";

@implementation VENCore

#pragma mark - Private

- (instancetype)init {
    return [self initWithBaseURL:[NSURL URLWithString:VENAPIBaseURL]];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        self.httpClient = [[VENHTTP alloc] initWithBaseURL:baseURL];
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
