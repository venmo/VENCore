#import "VENCore.h"

SpecBegin(PaymentSandbox)

beforeAll(^{
    VENCore *core = [[VENCore alloc] init];
    NSURL *baseURL = [NSURL URLWithString:@"https://sandbox-api.venmo.com/v1"];
    core.httpClient = [[VENHTTP alloc] initWithBaseURL:baseURL];
    [core setAccessToken:accessToken];
    [VENCore setDefaultCore:core];
});

describe(@"Settled Payment", ^{
    it(@"should make a successful payment to a user", ^{

    });
});

describe(@"Failed Payment", ^{
    it(@"should make a failed payment to a user", ^{

    });
});

describe(@"Pending Payment", ^{
    it(@"should make a pending payment to an email", ^{

    });

    it(@"should make a pending payment to a phone", ^{

    });
});

describe(@"Settled Charge", ^{
    it(@"should make a settled charge to a trusted friend", ^{

    });
});

describe(@"Pending Charge", ^{
    it(@"should make a pending charge to a non-trusted friend", ^{

    });
});


SpecEnd
