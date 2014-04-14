#import "VENMutableTransaction.h"
#import "VENTransaction.h"

SpecBegin(VENMutableTransaction)

describe(@"mutability", ^{
    //
    xit(@"should create a mutable transaction from an immutable transaction", ^{
        VENMutableTransaction *transaction = [VENMutableTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"kishkish@venmo.com"];

        VENMutableTransaction *mutableTransaction = [transaction mutableCopy];

        expect(mutableTransaction.note).to.equal(@"Hi there");
        mutableTransaction.note = @"I am a new note";
        expect(mutableTransaction.note).to.equal(@"I am a new note");
        expect(transaction.note).to.equal(@"Hi there");
    });

    it(@"should allow mutating properties", ^{
        VENMutableTransaction *mutableTransaction = [VENMutableTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"kishkish@venmo.com"];

        expect(mutableTransaction.note).to.equal(@"Hi there");
        mutableTransaction.note = @"I am a new note";
        expect(mutableTransaction.note).to.equal(@"I am a new note");
    });
});

SpecEnd