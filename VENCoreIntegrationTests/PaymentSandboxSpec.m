#import "VENCore.h"
#import "VENTransactionService.h"

SpecBegin(PaymentSandbox)

beforeAll(^{
    VENCore *core = [[VENCore alloc] init];
    NSURL *baseURL = [NSURL URLWithString:@"https://sandbox-api.venmo.com/v1"];
    core.httpClient = [[VENHTTP alloc] initWithBaseURL:baseURL];
    [core setAccessToken:[VENTestUtilities accessToken]];
    [VENCore setDefaultCore:core];
});

describe(@"Settled Payment", ^{

    NSUInteger amount = 10;
    NSString *note = @"A message to accompany the payment.";
    __block VENTransactionService *transactionService;

    beforeEach(^{
        transactionService = [[VENTransactionService alloc] init];
    });

    it(@"should make a successful payment to a user id", ^AsyncBlock{
        NSString *handle = @"145434160922624933";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusSettled);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
    });

    it(@"should make a successful payment to an email", ^AsyncBlock{
        NSString *handle = @"venmo@venmo.com";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusSettled);           
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
    });


    it(@"should make a successful payment to a phone number", ^AsyncBlock{
        NSString *handle = @"15555555555";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusSettled);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
    });
});

describe(@"Failed Payment", ^{

    NSUInteger amount = 20;
    NSString *note = @"A message to accompany the payment.";
    __block VENTransactionService *transactionService;

    beforeEach(^{
        transactionService = [[VENTransactionService alloc] init];
    });

    it(@"should make a failed payment to an email", ^AsyncBlock{
        NSString *handle = @"venmo@venmo.com";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusFailed);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
    });
});

describe(@"Pending Payment", ^{

    NSUInteger amount = 30;
    NSString *note = @"A message to accompany the payment.";
    __block VENTransactionService *transactionService;

    beforeEach(^{
        transactionService = [[VENTransactionService alloc] init];
    });

    it(@"should make a pending payment to an email", ^AsyncBlock{
        NSString *handle = @"foo@venmo.com";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusPending);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];

    });

    it(@"should make a pending payment to a new phone", ^AsyncBlock{
        NSString *handle = @"5555555556";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusPending);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];       
    });
});

describe(@"Settled Charge", ^{

    NSUInteger amount = 10;
    NSString *note = @"A message to accompany the payment.";
    __block VENTransactionService *transactionService;

    beforeEach(^{
        transactionService = [[VENTransaction alloc] init];
        transactionService.transactionType = VENTransactionTypeCharge;
    });

    it(@"should make a settled charge to a trusted email", ^AsyncBlock{
        NSString *handle = @"venmo@venmo.com";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusSettled);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];
    });
});

describe(@"Pending Charge", ^{

    NSUInteger amount = 20;
    NSString *note = @"A message to accompany the payment.";
    __block VENTransactionService *transactionService;

    beforeEach(^{
        transactionService = [[VENTransactionService alloc] init];
        transactionService.transactionType = VENTransactionTypeCharge;
    });

    it(@"should make a pending charge to a non-trusted friend", ^AsyncBlock{
        NSString *handle = @"venmo@venmo.com";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:handle amount:amount];
        transactionService.note = note;
        [transactionService addTransactionTarget:target];

        [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
            expect(sentTransactions.count).to.equal(1);
            VENTransaction *sentTransaction = [sentTransactions firstObject];
            expect(sentTransaction.status).to.equal(VENTransactionStatusPending);
            done();
        } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
            XCTFail();
            done();
        }];       
    });
});


SpecEnd
