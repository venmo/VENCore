#import "VENHTTP.h"
#import <AFNetworking/AFNetworking.h>
#import <sys/sysctl.h>
@import AdSupport;

#import "VENHTTPResponse.h"

NSString *const VENUserDefaultsKeyDeviceID = @"VenmoDeviceID";
NSString *const VENPrivateAPIPathLogin = @"oauth/access_token";
NSString *const VENPublicAPIPathPayments = @"payments";
NSString *const VENPublicAPIPathUsers = @"users";

NSString *const VENPrivateAPIPathUsers = @"api/v5/users";

@interface VENHTTP ()

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic, readwrite) NSString *clientID;
@property (strong, nonatomic, readwrite) NSString *clientSecret;

- (NSDictionary *)defaultHeaders;

@end

@implementation VENHTTP

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
                         baseURL:(NSURL *)baseURL {
    self = [self init];
    if (self) {
        self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        self.clientID = clientID;
        self.clientSecret = clientSecret;

        // set default header fields
        [self.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.operationManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return self;
}


- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
 completion:(void(^)(VENHTTPResponse *response, NSError *error))completionBlock {

    [self.operationManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        VENHTTPResponse *response = [self responseFromOperation:operation];
        if (completionBlock) {
            completionBlock(response, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}


- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
  completion:(void(^)(VENHTTPResponse *response, NSError *error))completionBlock {

    [self.operationManager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        VENHTTPResponse *response = [self responseFromOperation:operation];
        if (completionBlock) {
            completionBlock(response, nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}


- (void)setAccessToken:(NSString *)accessToken {
    NSDictionary *cookieProperties = @{ NSHTTPCookieDomain : [self.operationManager.baseURL host],
                                        NSHTTPCookiePath: @"/",
                                        NSHTTPCookieName : @"api_access_token",
                                        NSHTTPCookieValue : accessToken };
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    // add cookie to cookiestorage for webview requests
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    NSDictionary * cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]];

    // set access token header fields
    [cookieHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.operationManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}


- (NSDictionary *)defaultHeaders {
    NSMutableDictionary *defaultHeaders = [[NSMutableDictionary alloc] init];
    [defaultHeaders addEntriesFromDictionary:@{@"User-Agent" : [self userAgentString],
                                               @"Accept": [self acceptString],
                                               @"Accept-Language": [self acceptLanguageString],
                                               @"Device-ID" : [self deviceIDString]}];
    return defaultHeaders;
}


+ (NSString *)platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}


- (NSString *)userAgentString {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [bundleInfo objectForKey:(NSString *)kCFBundleNameKey];
    NSString *appVersion = [bundleInfo objectForKey:(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"%@/%@ iOS/%@ %@",
            appName, appVersion,
            [[UIDevice currentDevice] systemVersion],
            [VENHTTP platformString]];
}


- (NSString *)acceptString {
    return @"application/json";
}


- (NSString *)acceptLanguageString {
    NSLocale *locale = [NSLocale currentLocale];
    return [NSString stringWithFormat:@"%@-%@",
            [locale objectForKey:NSLocaleLanguageCode],
            [locale objectForKey:NSLocaleCountryCode]];
}


- (NSString *)deviceIDString {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uniqueIdentifier = [userDefaults stringForKey:VENUserDefaultsKeyDeviceID];
    if (!uniqueIdentifier) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        uniqueIdentifier = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
        CFRelease(uuid);
        [userDefaults setObject:uniqueIdentifier forKey:VENUserDefaultsKeyDeviceID];
        [userDefaults synchronize];
    }
    return uniqueIdentifier;
}


- (VENHTTPResponse *)responseFromOperation:(AFHTTPRequestOperation *)operation {
    return [[VENHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseObject:operation.responseObject];
}

@end
