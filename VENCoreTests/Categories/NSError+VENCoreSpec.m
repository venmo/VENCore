#import "NSError+VENCore.h"
#import "VENHTTPResponse.h"

SpecBegin(NSErrorVENCore)

describe(@"errorWithCode:description:recoverySuggestion:", ^{
    it(@"should return an NSError object with the correct domain and code", ^{
        NSError *error = [NSError errorWithCode:123 description:@"bad error" recoverySuggestion:@"deal with it"];
        expect(error.code).to.equal(123);
        expect(error.domain).to.equal(VENErrorDomain);
    });

    it(@"should return an NSError object with the user info dictionary", ^{
        NSString *description = @"fatal error";
        NSString *recoverySuggestion = @"deal with it";
        NSError *error = [NSError errorWithCode:123 description:description recoverySuggestion:recoverySuggestion];
        NSDictionary *expectedUserInfo = @{NSLocalizedDescriptionKey: description,
                                           NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion};
        expect(error.userInfo).to.equal(expectedUserInfo);
    });
});


describe(@"defaultResponseError", ^{
    it(@"should return an NSError object with the correct code and user info", ^{
        NSError *error = [NSError defaultResponseError];

        NSString *expectedDescription = NSLocalizedString(@"Bad response", nil);
        expect(error.domain).to.equal(VENErrorDomain);
        expect(error.code).to.equal(VENErrorCodeBadRequest);
        expect(error.localizedDescription).to.equal(expectedDescription);
    });
});


SpecEnd