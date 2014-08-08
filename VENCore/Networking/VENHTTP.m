#import "VENHTTP.h"

#import "NSError+VENCore.h"
#import "VENHTTPResponse.h"
#import "UIDevice+VENCore.h"
#import "NSError+VENCore.h"
#import "NSDictionary+VENCore.h"
#import "NSArray+VENCore.h"
#import <CMDQueryStringSerialization/CMDQueryStringSerialization.h>

NSString *const VENAPIPathPayments  = @"payments";
NSString *const VENAPIPathUsers     = @"users";

@interface VENHTTP ()<NSURLSessionDelegate>

@property (strong, nonatomic) NSString *accessToken;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong, readwrite) NSURL *baseURL;

@end

@implementation VENHTTP

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [self init];
    if (self) {
        self.baseURL = baseURL;
        [self initializeSessionWithHeaders:self.defaultHeaders];
    }
    return self;
}


- (void)initializeSessionWithHeaders:(NSDictionary *)headers;
{
    void(^createSessionBlock)() = ^() {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = self.defaultHeaders;

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;

        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
    };

    if (self.session) {
        [self.session resetWithCompletionHandler:createSessionBlock];
    }
    else {
        createSessionBlock();
    }
}


- (void)setProtocolClasses:(NSArray *)protocolClasses {
    NSURLSessionConfiguration *configuration = self.session.configuration;
    configuration.protocolClasses = protocolClasses;
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.session.delegateQueue];
}


- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
    failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
{
    [self sendRequestWithMethod:@"GET" path:path parameters:parameters success:successBlock failure:failureBlock];
}


- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
     success:(void(^)(VENHTTPResponse *response))successBlock
     failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
{
    
    [self sendRequestWithMethod:@"POST" path:path parameters:parameters success:successBlock failure:failureBlock];
}


- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void (^)(VENHTTPResponse *))successBlock
    failure:(void (^)(VENHTTPResponse *, NSError *))failureBlock
{
    [self sendRequestWithMethod:@"PUT" path:path parameters:parameters success:successBlock failure:failureBlock];
}


- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters
       success:(void(^)(VENHTTPResponse *response))successBlock
       failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
{
    [self sendRequestWithMethod:@"DELETE" path:path parameters:parameters success:successBlock failure:failureBlock];
}


#pragma mark - Underlying HTTP

// Modified from BTHTTP
- (void)sendRequestWithMethod:(NSString *)method
                         path:(NSString *)aPath
                   parameters:(NSDictionary *)parameters
                      success:(void(^)(VENHTTPResponse *response))successBlock
                      failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
{
    NSURL *fullPathURL = [self.baseURL URLByAppendingPathComponent:aPath];
    NSURLComponents *components = [NSURLComponents componentsWithString:fullPathURL.absoluteString];

    NSMutableURLRequest *request;

    NSString *encodedParametersString = [CMDQueryStringSerialization queryStringWithDictionary:parameters];
    NSString *percentEncodedQuery = [encodedParametersString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) {
        components.percentEncodedQuery = percentEncodedQuery;
        request = [NSMutableURLRequest requestWithURL:components.URL];
    } else {
        request = [NSMutableURLRequest requestWithURL:components.URL];
        NSData *body = [encodedParametersString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
        NSDictionary *headers = @{@"Content-Type": @"application/x-www-form-urlencoded; charset=utf-8"};
        [request setAllHTTPHeaderFields:headers];
    }
    // Add headers
    NSMutableDictionary *currentHeaders = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [currentHeaders addEntriesFromDictionary:[self headersWithAccessToken:self.accessToken]];
    [request setAllHTTPHeaderFields:currentHeaders];

    [request setHTTPMethod:method];

    // Perform the actual request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[self class] handleRequestCompletion:data response:response error:error success:successBlock failure:failureBlock];
    }];
    [task resume];
}

+ (void)handleRequestCompletion:(NSData *)data
                       response:(NSURLResponse *)response
                          error:(NSError *)error
                        success:(void(^)(VENHTTPResponse *response))successBlock
                        failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
{
    // Handle nil or non-HTTP requests, which are an unknown type of error
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *userInfo = error ? @{NSUnderlyingErrorKey: error} : nil;
        NSError *error = [NSError errorWithDomain:VENErrorDomainHTTPResponse
                                             code:VENErrorCodeHTTPResponseBadResponse
                                         userInfo:userInfo];
        [self callFailureBlock:failureBlock response:nil error:error];
        return;
    }

    // Attempt to parse, and return an error if parsing fails
    NSError *jsonParseError;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
    
    if (jsonParseError != nil) {
        [self callFailureBlock:failureBlock response:nil error:jsonParseError];
        return;
    }

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSDictionary *cleansedDictionary = [responseDictionary dictionaryByCleansingResponseDictionary];

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        VENHTTPResponse *venHTTPResponse = [[VENHTTPResponse alloc] initWithStatusCode:httpResponse.statusCode responseObject:cleansedDictionary];
        if ([venHTTPResponse didError]) {
            [self callFailureBlock:failureBlock
                          response:venHTTPResponse
                             error:[venHTTPResponse error]];
        }
        else {
            [self callSuccessBlock:successBlock response:venHTTPResponse];
        }
    }
    else if ([responseObject isKindOfClass:[NSArray class]]) {
        NSArray *responseArray = (NSArray *)responseObject;
        NSArray *cleansedArray = [responseArray arrayByCleansingResponseArray];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        VENHTTPResponse *venHTTPResponse = [[VENHTTPResponse alloc] initWithStatusCode:httpResponse.statusCode responseObject:cleansedArray];
        if ([venHTTPResponse didError]) {
            [self callFailureBlock:failureBlock
                          response:venHTTPResponse
                             error:[venHTTPResponse error]];
        }
        else {
            [self callSuccessBlock:successBlock response:venHTTPResponse];
        }
    }
    else {
        NSDictionary *userInfo = error ? @{NSUnderlyingErrorKey: error} : nil;
        NSError *error = [NSError errorWithDomain:VENErrorDomainHTTPResponse
                                             code:VENErrorCodeHTTPResponseInvalidObjectType
                                         userInfo:userInfo];
        [self callFailureBlock:failureBlock response:nil error:error];
    }
}

+ (void)callSuccessBlock:(void(^)(VENHTTPResponse *response))successBlock
                response:(VENHTTPResponse *)response
{
    if (!successBlock) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        successBlock(response);
    });
}

+ (void)callFailureBlock:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock
                response:(VENHTTPResponse *)response
                   error:(NSError *)error {
    if (!failureBlock) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        failureBlock(response, error);
    });
}

- (NSDictionary *)headersWithAccessToken:(NSString *)accessToken
{
    if (!accessToken) {
        return [self defaultHeaders];
    }

    NSDictionary *cookieProperties = @{ NSHTTPCookieDomain : [self.baseURL host],
                                        NSHTTPCookiePath: @"/",
                                        NSHTTPCookieName: @"api_access_token",
                                        NSHTTPCookieValue: accessToken };
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    // Add cookie to shared cookie storage for webview requests
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]]];
    [headers addEntriesFromDictionary:[self defaultHeaders]];
    return headers;
}

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    NSDictionary *headers = [self headersWithAccessToken:accessToken];
    [self initializeSessionWithHeaders:headers];
}


- (NSDictionary *)defaultHeaders
{
    NSMutableDictionary *defaultHeaders = [[NSMutableDictionary alloc] init];
    [defaultHeaders addEntriesFromDictionary:@{@"User-Agent" : [self userAgentString],
                                               @"Accept": [self acceptString],
                                               @"Accept-Language": [self acceptLanguageString],
                                               @"Device-ID" : [[UIDevice currentDevice] VEN_deviceIDString]}];
    return defaultHeaders;
}


- (NSString *)userAgentString {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [bundleInfo objectForKey:(NSString *)kCFBundleNameKey];
    NSString *appVersion = [bundleInfo objectForKey:(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"%@/%@ iOS/%@ %@",
            appName, appVersion,
            [[UIDevice currentDevice] systemVersion],
            [[UIDevice currentDevice] VEN_platformString]];
}


- (NSString *)acceptString
{
    return @"application/json";
}


- (NSString *)acceptLanguageString
{
    NSLocale *locale = [NSLocale currentLocale];
    return [NSString stringWithFormat:@"%@-%@",
            [locale objectForKey:NSLocaleLanguageCode],
            [locale objectForKey:NSLocaleCountryCode]];
}

@end
