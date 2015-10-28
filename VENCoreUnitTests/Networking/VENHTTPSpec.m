#import "VENHTTP.h"
#import "VENHTTPResponse.h"
#import "VENCore.h"
#import "NSString+VENCore.h"

@import CMDQueryStringSerialization;

#define kVENHTTPTestProtocolScheme @"ven-http-test"
#define kVENHTTPTestProtocolHost @"base.example.com"
#define kVENHTTPTestProtocolBasePath @"/base/path/"
#define kVENHTTPTestProtocolPort @1234

@interface VENHTTPTestProtocol : NSURLProtocol
@end

@implementation VENHTTPTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL hasCorrectScheme = [request.URL.scheme isEqualToString:kVENHTTPTestProtocolScheme];
    BOOL hasCorrectHost = [request.URL.host isEqualToString:kVENHTTPTestProtocolHost];
    BOOL hasCorrectPort = [request.URL.port isEqual:kVENHTTPTestProtocolPort];
    BOOL hasCorrectBasePath = [request.URL.path rangeOfString:kVENHTTPTestProtocolBasePath].location != NSNotFound;
    
    return hasCorrectScheme && hasCorrectHost && hasCorrectPort && hasCorrectBasePath;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type": @"application/json"}];
    
    NSData *archivedRequest = [NSKeyedArchiver archivedDataWithRootObject:self.request];
    NSString *base64ArchivedRequest = [archivedRequest base64EncodedStringWithOptions:0];
    
    NSData *requestBodyData;
    if (self.request.HTTPBodyStream) {
        NSInputStream *inputStream = self.request.HTTPBodyStream;
        [inputStream open];
        NSMutableData *mutableBodyData = [NSMutableData data];
        
        while ([inputStream hasBytesAvailable]) {
            uint8_t buffer[128];
            NSUInteger bytesRead = [inputStream read:buffer maxLength:128];
            [mutableBodyData appendBytes:buffer length:bytesRead];
        }
        [inputStream close];
        requestBodyData = [mutableBodyData copy];
    } else {
        requestBodyData = self.request.HTTPBody;
    }
    
    NSDictionary *responseBody = @{ @"request": base64ArchivedRequest,
                                    @"requestBody": [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding] };
    
    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    [client URLProtocol:self didLoadData:[NSJSONSerialization dataWithJSONObject:responseBody options:NSJSONWritingPrettyPrinted error:NULL]];
    
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

+ (NSURL *)testBaseURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kVENHTTPTestProtocolScheme;
    components.host = kVENHTTPTestProtocolHost;
    components.path = kVENHTTPTestProtocolBasePath;
    components.port = kVENHTTPTestProtocolPort;
    return components.URL;
}

+ (NSURLRequest *)parseRequestFromTestResponse:(VENHTTPResponse *)response {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:response.object[@"request"] options:0]];
}

+ (NSString *)parseRequestBodyFromTestResponse:(VENHTTPResponse *)response {
    return response.object[@"requestBody"];
}

@end


SpecBegin(VENHTTP)

describe(@"performing a request", ^{
    __block VENHTTP *http;
    
    beforeEach(^{
        http = [[VENHTTP alloc] initWithBaseURL:[VENHTTPTestProtocol testBaseURL]];
        [http setProtocolClasses:@[[VENHTTPTestProtocol class]]];
    });
    
    describe(@"base URL", ^{
        it(@"sends requests using the specified URL scheme", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    
                    expect(httpRequest.URL.scheme).to.equal(@"ven-http-test");
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        
        it(@"sends requests to the host at the base URL", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.host).to.equal(@"base.example.com");
                    
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"appends the path to the base URL", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    
                    expect(httpRequest.URL.path).to.equal(@"/base/path/200.json");
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
    });
    
    describe(@"HTTP methods", ^{
        it(@"sends a GET request", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"/200.json$");
                    expect(httpRequest.HTTPMethod).to.equal(@"GET");
                    expect(httpRequest.HTTPBody).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a GET request with parameters", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"/200.json$");
                    expect(httpRequest.URL.query).to.equal(@"param=value");
                    expect(httpRequest.HTTPMethod).to.equal(@"GET");
                    expect(httpRequest.HTTPBody).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a POST request", ^{
            waitUntil(^(DoneCallback done) {
                [http POST:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"/200.json$");
                    expect(httpRequest.HTTPBody).to.beNil();
                    expect(httpRequest.HTTPMethod).to.equal(@"POST");
                    expect(httpRequest.URL.query).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a POST request with parameters", ^{
            waitUntil(^(DoneCallback done) {
                [http POST:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"/200.json$");
                    expect(httpRequestBody).to.equal(@"param=value");
                    expect(httpRequest.HTTPMethod).to.equal(@"POST");
                    expect(httpRequest.URL.query).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a PUT request", ^{
            waitUntil(^(DoneCallback done) {
                [http PUT:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"200.json$");
                    expect(httpRequest.HTTPBody).to.beNil();
                    expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                    expect(httpRequest.URL.query).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a PUT request with parameters", ^{
            waitUntil(^(DoneCallback done) {
                [http PUT:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"200.json$");
                    expect(httpRequestBody).to.equal(@"param=value");
                    expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                    expect(httpRequest.URL.query).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        
        it(@"sends a DELETE request", ^{
            waitUntil(^(DoneCallback done) {
                [http DELETE:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.path).to.match(@"200.json$");
                    expect(httpRequest.HTTPBody).to.beNil();
                    expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                    expect(httpRequest.URL.query).to.equal(nil);
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"sends a DELETE request with parameters", ^{
            waitUntil(^(DoneCallback done) {
                [http DELETE:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    
                    expect(httpRequest.URL.path).to.match(@"/200.json$");
                    expect(httpRequest.URL.query).to.equal(@"param=value");
                    expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                    expect(httpRequest.HTTPBody).to.beNil();
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
    });
    
    describe(@"default headers", ^{
        it(@"include Accept", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                    expect(requestHeaders[@"Accept"]).to.equal(@"application/json");
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"include User-Agent", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                    expect(requestHeaders[@"User-Agent"]).to.contain(@"iOS");
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
        
        it(@"include Accept-Language", ^{
            waitUntil(^(DoneCallback done) {
                [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                    expect(requestHeaders[@"Accept-Language"]).to.equal(@"en-US");
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    VENFail();
                }];
            });
        });
    });
    
    describe(@"parameters", ^{
        __block NSDictionary *parameterDictionary;
        
        beforeEach(^{
            parameterDictionary = @{@"stringParam": @"a value",
                                    @"numericParam": @42,
                                    @"trueBoolParam": @YES,
                                    @"falseBoolParam": @NO
                                    };
        });
        
        describe(@"in GET requests", ^{
            it(@"transmits the parameters as URL encoded query parameters", ^{
                waitUntil(^(DoneCallback done) {
                    [http GET:@"200.json" parameters:parameterDictionary success:^(VENHTTPResponse *response) {
                        NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                        expect(httpRequest.URL.query).to.equal([CMDQueryStringSerialization queryStringWithDictionary:parameterDictionary]);
                        done();
                    } failure:^(VENHTTPResponse *response, NSError *error) {
                        VENFail();
                    }];
                });
            });
        });
        
        describe(@"in non-GET requests", ^{
            it(@"transmits the parameters as JSON", ^{
                waitUntil(^(DoneCallback done) {
                    [http POST:@"200.json" parameters:parameterDictionary success:^(VENHTTPResponse *response) {
                        NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                        NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                        NSString *encodedParameters = [CMDQueryStringSerialization queryStringWithDictionary:parameterDictionary];
                        
                        expect([httpRequest valueForHTTPHeaderField:@"Content-type"]).to.equal(@"application/x-www-form-urlencoded; charset=utf-8");
                        expect(httpRequestBody).to.equal(encodedParameters);
                        
                        done();
                    } failure:^(VENHTTPResponse *response, NSError *error) {
                        VENFail();
                    }];
                });
            });
        });
    });
});

SpecEnd