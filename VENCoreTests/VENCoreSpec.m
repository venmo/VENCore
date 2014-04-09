#import "VENCore.h"
#import "VENErrors.h"
#import "VENHTTP.h"
#import "VENUser.h"

NSString *accessToken;
NSDictionary *responseDictionary;
NSString *responseString;
NSURL *baseURL;
VENCore *core;
NSString *path;

SpecBegin(VENCore)

beforeAll(^{
    [[LSNocilla sharedInstance] start];
    accessToken = @"12345678";
    baseURL = [NSURL URLWithString:@"https://venmo.com"];
    path = [NSString stringWithFormat:@"%@/%@", baseURL, VENPrivateAPIPathLogin];
    responseDictionary = @{@"access_token" : accessToken,
                           @"id" : @"4"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDictionary
                                                       options:0
                                                         error:nil];
    responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
});
afterAll(^{
    [[LSNocilla sharedInstance] stop];
    accessToken = nil;
    baseURL = nil;
    path = nil;
    responseDictionary = nil;
    responseString = nil;
});
afterEach(^{
    [[LSNocilla sharedInstance] clearStubs];
});

before(^{
    core = [[VENCore alloc] initWithClientID:@"id" clientSecret:@"secret" baseURL:baseURL];
});

after(^{
    core = nil;
});

SpecEnd