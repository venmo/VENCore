#import "VENUser.h"
#import "VENCore.h"

SpecBegin(VENUserIntegration)

NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"config" ofType:@"plist"];
NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
NSString *accessToken = config[@"access_token"];

beforeAll(^{
    VENCore *core = [[VENCore alloc] init];
    [core setAccessToken:accessToken];
    [VENCore setDefaultCore:core];
});

describe(@"Fetching a user", ^{
    it(@"should retrieve a user with a correct external id", ^AsyncBlock{
        NSString *externalId = @"11063873587118083333"; // (Chris)
        [VENUser fetchUserWithExternalId:externalId success:^(VENUser *user) {
            expect(user.externalId).to.equal(externalId);
            done();
        } failure:^(NSError *error) {
            expect(YES).to.beFalsy();
            done();
        }];
    });
});

SpecEnd
