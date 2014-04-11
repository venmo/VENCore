#import "VENMutableTransaction+Internal.h"
#import "VENTransaction+Internal.h"
#import "VENBundledFileParser.h"
#import "VENHTTPResponse.h"

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
        NSDictionary *paymentObject = [VENBundledFileParser objectFromJSONResource:@"paymentToEmail"];
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
    it(@"should send a valid transaction if the default core has been set", ^{

    });

    it(@"should not send a transaction if the default core is nil", ^{

    });
});

SpecEnd