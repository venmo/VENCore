#import "VENCore.h"
#import "VENHTTPResponse.h"
#import "VENHTTP.h"
#import "VENTransaction.h"
#import "VENUser.h"
#import "NSError+VENCore.h"
#import "NSDictionary+VENCore.h"

NSString *const VENErrorDomainCore = @"com.venmo.VENCore.ErrorDomain.VENCore";

static VENCore *sharedInstance = nil;

static NSString *const VENAPIBaseURL = @"https://api.venmo.com/v1";

@interface VENCore ()

@property (strong, nonatomic) NSString *accessToken;

@end

@implementation VENCore

#pragma mark - Private

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret {
    self = [super init];
    if (self) {
        self.httpClient = [[VENHTTP alloc] initWithClientID:clientID
                                               clientSecret:clientSecret
                                                    baseURL:[NSURL URLWithString:VENAPIBaseURL]];
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
