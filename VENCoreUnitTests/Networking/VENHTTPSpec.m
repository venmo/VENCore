#import "VENHTTP.h"
#import "VENHTTPResponse.h"

#define kVENHTTPTestProtocolScheme @"ven-http-test"
#define kVENHTTPTestProtocolHost @"base.example.com"
#define kVENHTTPTestProtocolBasePath @"/base/path/"
#define kVENHTTPTestProtocolPort @1234

@interface VENHTTPTestProtocol : NSURLProtocol
@end

@implementation VENHTTPTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

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
        it(@"sends requests using the specified URL scheme", ^AsyncBlock{
            [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.scheme).to.equal(@"ven-http-test");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends requests to the host at the base URL", ^AsyncBlock{
            [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.host).to.equal(@"base.example.com");

                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"appends the path to the base URL", ^AsyncBlock{
            [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.path).to.equal(@"/base/path/200.json");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });
    });

    describe(@"HTTP methods", ^{
        it(@"sends a GET request", ^AsyncBlock{
            [http GET:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.HTTPMethod).to.equal(@"GET");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a GET request with parameters", ^AsyncBlock{
            [http GET:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.URL.query).to.equal(@"param=value");
                expect(httpRequest.HTTPMethod).to.equal(@"GET");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a POST request", ^AsyncBlock{
            [http POST:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"POST");
                expect(httpRequest.URL.query).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a POST request with parameters", ^AsyncBlock{
            [http POST:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
                expect(httpRequest.HTTPMethod).to.equal(@"POST");
                expect(httpRequest.URL.query).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a PUT request", ^AsyncBlock{
            [http PUT:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                expect(httpRequest.URL.query).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a PUT request with parameters", ^AsyncBlock{
            [http PUT:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
                expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                expect(httpRequest.URL.query).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });


        it(@"sends a DELETE request", ^AsyncBlock{
            [http DELETE:@"200.json" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                expect(httpRequest.URL.query).to.equal(@"");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"sends a DELETE request with parameters", ^AsyncBlock{
            [http DELETE:@"200.json" parameters:@{@"param": @"value"} success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.URL.query).to.equal(@"param=value");
                expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });
    });

    describe(@"default headers", ^{
        __block id<OHHTTPStubsDescriptor>stubDescriptor;

        beforeEach(^{
            stubDescriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *jsonResponse = [NSJSONSerialization dataWithJSONObject:@{@"requestHeaders": [request allHTTPHeaderFields]} options:NSJSONWritingPrettyPrinted error:nil];
                return [OHHTTPStubsResponse responseWithData:jsonResponse statusCode:200 headers:@{@"Content-type": @"application/json"}];
            }];
        });

        afterEach(^{
            [OHHTTPStubs removeStub:stubDescriptor];
        });

        it(@"include Accept", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept"]).to.equal(@"application/json");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"include User-Agent", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"User-Agent"]).to.contain(@"iOS");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });

        it(@"include Accept-Language", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil success:^(VENHTTPResponse *response) {
                NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept-Language"]).to.equal(@"en-US");
                done();
            } failure:^(VENHTTPResponse *response, NSError *error) {
                XCTFail();
            }];
        });
    });

    describe(@"parameters", ^{
        __block NSDictionary *parameterDictionary;

        beforeEach(^{
            parameterDictionary = @{@"stringParameter": @"value",
                                    @"crazyStringParameter[]": @"crazy%20and&value",
                                    @"numericParameter": @42,
                                    @"trueBooleanParameter": @YES,
                                    @"falseBooleanParameter": @NO,
                                    @"dictionaryParameter":  @{ @"dictionaryKey": @"dictionaryValue" },
                                    @"arrayParameter": @[@"arrayItem1", @"arrayItem2"]
                                    };
        });

        describe(@"in GET requests", ^{
            it(@"transmits the parameters as URL encoded query parameters", ^AsyncBlock{
                NSString *encodedParameters = @"numericParameter=42&falseBooleanParameter=0&dictionaryParameter%5BdictionaryKey%5D=dictionaryValue&trueBooleanParameter=1&stringParameter=value&crazyStringParameter%5B%5D=crazy%2520and%26value&arrayParameter%5B%5D=arrayItem1&arrayParameter%5B%5D=arrayItem2";

                [http GET:@"200.json" parameters:parameterDictionary success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.query).to.equal(encodedParameters);
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    XCTFail();
                }];
            });
        });

        describe(@"in non-GET requests", ^{
            it(@"transmits the parameters as JSON", ^AsyncBlock{
                NSString *encodedParameters = @"{\n  \"numericParameter\" : 42,\n  \"falseBooleanParameter\" : false,\n  \"dictionaryParameter\" : {\n    \"dictionaryKey\" : \"dictionaryValue\"\n  },\n  \"trueBooleanParameter\" : true,\n  \"stringParameter\" : \"value\",\n  \"crazyStringParameter[]\" : \"crazy%20and&value\",\n  \"arrayParameter\" : [\n    \"arrayItem1\",\n    \"arrayItem2\"\n  ]\n}";

                [http POST:@"200.json" parameters:parameterDictionary success:^(VENHTTPResponse *response) {
                    NSURLRequest *httpRequest = [VENHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSString *httpRequestBody = [VENHTTPTestProtocol parseRequestBodyFromTestResponse:response];

                    expect([httpRequest valueForHTTPHeaderField:@"Content-type"]).to.equal(@"application/json; charset=utf-8");
                    expect(httpRequestBody).to.equal(encodedParameters);
                    
                    done();
                } failure:^(VENHTTPResponse *response, NSError *error) {
                    XCTFail();
                }];
            });
        });
    });
});

SpecEnd