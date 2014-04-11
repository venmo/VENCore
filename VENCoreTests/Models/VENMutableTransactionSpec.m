#import "VENMutableTransaction.h"
#import "VENTransaction.h"
#import "VENBundledFileParser.h"


SpecBegin(VENMutableTransaction)

describe(@"mutability", ^{
    it(@"should create a mutable transaction from an immutable transaction", ^{
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

SpecEnd