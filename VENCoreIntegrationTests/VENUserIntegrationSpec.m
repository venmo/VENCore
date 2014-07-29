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
        NSString *externalId = @"1062502213353472181"; // (Ben)
        [VENUser fetchUserWithExternalId:externalId success:^(VENUser *user) {
            expect(user.externalId).to.equal(externalId);
            done();
        } failure:^(NSError *error) {
            XCTFail();
            done();
        }];
    });
});

describe(@"Searching for a user", ^{
    it(@"should retrieve an arary of users with a search query", ^AsyncBlock{
    NSString *query = @"Leah";
        [VENUser searchUsersWithQuery:query success:^(NSArray *users) {
            if ([users count]) {
                for (VENUser *user in users){
                    expect(user.displayName).notTo.beNil();
                    expect(user.externalId).notTo.beNil();
                    expect(user.firstName).notTo.beNil();
                    expect(user.lastName).notTo.beNil();
                }
            }
            done();
        } failure:^(NSError *error) {
            XCTFail();
            done();
        }];
    });
});

SpecEnd
