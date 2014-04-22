#import "VENCore.h"
#import "VENTransaction.h"

SpecBegin(PaymentSandbox)

beforeAll(^{
    VENCore *core = [[VENCore alloc] init];
    NSURL *baseURL = [NSURL URLWithString:@"https://sandbox-api.venmo.com/v1"];
    core.httpClient = [[VENHTTP alloc] initWithBaseURL:baseURL];
    [core setAccessToken:[VENTestUtilities accessToken]];
    [VENCore setDefaultCore:core];
});

describe(@"Settled Payment", ^{
    fit(@"should make a successful payment to a user", ^AsyncBlock{
        VENTransaction *transaction = [[VENTransaction alloc] init];
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"145434160922624933" amount:10];
        transaction.note = @"A message to accompany the payment.";
        [transaction addTransactionTarget:target];

        [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            done();
        } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
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
