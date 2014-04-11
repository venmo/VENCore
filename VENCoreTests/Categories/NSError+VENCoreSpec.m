#import "NSError+VENCore.h"
#import "VENHTTPResponse.h"

SpecBegin(NSErrorVENCore)

describe(@"errorWithDomain:Code:description:recoverySuggestion:", ^{
    it(@"should return an NSError object with the correct domain and code", ^{
        NSError *error = [NSError errorWithDomain:VENErrorDomainHTTPResponse
                                             code:123
                                      description:@"bad error"
                               recoverySuggestion:@"deal with it"];
        expect(error.code).to.equal(123);
        expect(error.domain).to.equal(VENErrorDomainHTTPResponse);
    });

    it(@"should return an NSError object with the user info dictionary", ^{
        NSString *domain = VENErrorDomainHTTPResponse;
        NSString *description = @"fatal error";
        NSString *recoverySuggestion = @"deal with it";
        NSError *error = [NSError errorWithDomain:domain
                                             code:123
                                      description:description
                               recoverySuggestion:recoverySuggestion];
        NSDictionary *expectedUserInfo = @{NSLocalizedDescriptionKey: description,
                                           NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion};
        expect(error.userInfo).to.equal(expectedUserInfo);
    });
});


describe(@"defaultResponseError", ^{
    it(@"should return an NSError object with the correct code and user info", ^{
        NSError *error = [NSError defaultResponseError];

        NSString *expectedDescription = NSLocalizedString(@"Bad response", nil);
        expect(error.domain).to.equal(VENErrorDomainHTTPResponse);
        expect(error.code).to.equal(VENErrorCodeHTTPResponseBadResponse);
        expect(error.localizedDescription).to.equal(expectedDescription);
    });
});


SpecEnd