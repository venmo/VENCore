#import "VENMutableTransaction+Internal.h"
#import "VENTransaction+Internal.h"
#import "VENTestUtilities.h"
#import "VENHTTPResponse.h"
#import "NSError+VENCore.h"
#import "VENCore.h"
#import "VENHTTP.h"

VENMutableTransaction *transaction;

SpecBegin(VENMutableTransaction)

beforeAll(^{
    [[LSNocilla sharedInstance] start];
});
afterAll(^{
    [[LSNocilla sharedInstance] stop];
});
afterEach(^{
    [[LSNocilla sharedInstance] clearStubs];
});

describe(@"mutability", ^{
    it(@"should allow mutating a mutable copy of a VENTransaction", ^{
        NSDictionary *paymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
        NSDictionary *paymentObject = paymentResponse[@"data"][@"payment"];
        VENTransaction *transaction = [VENTransaction transactionWithPaymentObject:paymentObject];

        VENMutableTransaction *mutableTransaction = [transaction mutableCopy];

        expect(mutableTransaction.note).to.equal(@"Rock Climbing!");
        mutableTransaction.note = @"I am a new note";
        expect(mutableTransaction.note).to.equal(@"I am a new note");
        expect(transaction.note).to.equal(@"Rock Climbing!");
    });

    it(@"should allow mutating properties", ^{
        VENMutableTransaction *mutableTransaction = [VENMutableTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"kishkish@venmo.com"];

        expect(mutableTransaction.note).to.equal(@"Hi there");
        mutableTransaction.note = @"I am a new note";
        expect(mutableTransaction.note).to.equal(@"I am a new note");
    });
});


describe(@"parameters", ^{
    it(@"should return the correct parameters for a transaction", ^{
        VENMutableTransaction *transaction = [VENMutableTransaction transactionWithType:VENTransactionTypePay amount:1000 note:@"Here is 10 Bucks" audience:VENTransactionAudienceFriends recipientType:VENRecipientTypeEmail recipientString:@"bg@venmo.com"];
        NSDictionary *parameters = @{@"email": @"bg@venmo.com",
                                     @"note": @"Here is 10 Bucks",
                                     @"amount": @"10.00",
                                     @"audience":@"friends"};
        expect([transaction parameters]).to.equal(parameters);
    });
});

describe(@"sending a transaction", ^{
    before(^{
        [VENCore setDefaultCore:nil];
        transaction = [VENMutableTransaction transactionWithType:VENTransactionTypePay
                                                          amount:1000
                                                            note:@"Here is 10 Bucks"
                                                        audience:VENTransactionAudienceFriends
                                                   recipientType:VENRecipientTypeEmail
                                                 recipientString:@"bg@venmo.com"];
    });

    after(^{
        transaction = nil;
    });

    it(@"should not send a transaction if the default core is nil", ^AsyncBlock{
        [transaction sendWithSuccess:nil failure:^(VENHTTPResponse *response, NSError *error) {
            NSError *expectedError = [NSError noDefaultCoreError];
            expect(error).to.equal(expectedError);
            done();
        }];
    });

    it(@"should POST a payment with VENHTTP if the default core has been set", ^{
        VENCore *core = [[VENCore alloc] initWithClientID:@"123" clientSecret:@"abc"];
        id mockHTTP = [OCMockObject mockForClass:[VENHTTP class]];
        core.httpClient = mockHTTP;
        [VENCore setDefaultCore:core];

        [[mockHTTP expect] POST:VENAPIPathPayments
                     parameters:[transaction parameters]
                        success:[OCMArg any]
                        failure:[OCMArg any]];

        [transaction sendWithSuccess:nil failure:nil];
        [mockHTTP verify];
    });

    it(@"should return a VENTransaction object if the payment is successful", ^AsyncBlock{
        VENCore *core = [[VENCore alloc] initWithClientID:@"123" clientSecret:@"abc"];
        [VENCore setDefaultCore:core];

        NSString *paymentString = [VENTestUtilities stringFromJSONResource:@"paymentToEmail"];
        NSString *queryString = [VENTestUtilities queryStringFromParameters:[transaction parameters]];

        NSString *baseURLString = [VENTestUtilities baseURLStringForCore:core];
        stubRequest(@"POST", [NSString stringWithFormat:@"%@%@", baseURLString, VENAPIPathPayments]).
        withBody(queryString).
        andReturn(200).
        withHeader(@"Content-Type", @"application/json").
        withBody(paymentString);

        [transaction sendWithSuccess:^(VENTransaction *transaction, VENHTTPResponse *response) {
            expect(transaction).toNot.beNil();
            // TODO: write an isEqual
            expect(response.statusCode).to.equal(200);
            done();
        } failure:^(VENHTTPResponse *response, NSError *error) {
            done();
        }];
    });

    it(@"should return an error object if the payment failed", ^AsyncBlock{
        VENCore *core = [[VENCore alloc] initWithClientID:@"123" clientSecret:@"abc"];
        [VENCore setDefaultCore:core];

        NSString *errorString = [VENTestUtilities stringFromJSONResource:@"invalidAccessTokenError"];
        NSDictionary *objectDictionary = [VENTestUtilities objectFromJSONResource:@"invalidAccessTokenError"];
        NSDictionary *errorDictionary = objectDictionary[@"error"];
        NSString *queryString = [VENTestUtilities queryStringFromParameters:[transaction parameters]];

        NSString *baseURLString = [VENTestUtilities baseURLStringForCore:core];
        stubRequest(@"POST", [NSString stringWithFormat:@"%@%@", baseURLString, VENAPIPathPayments]).
        withBody(queryString).
        andReturn(400).
        withHeader(@"Content-Type", @"application/json").
        withBody(errorString);

        [transaction sendWithSuccess:^(VENTransaction *transaction, VENHTTPResponse *response) {
            done();
        } failure:^(VENHTTPResponse *response, NSError *error) {
            expect(response.statusCode).to.equal(400);
            expect([error localizedDescription]).to.equal(errorDictionary[@"message"]);
            expect([error code]).to.equal(errorDictionary[@"code"]);
            done();
        }];
    });

});


SpecEnd