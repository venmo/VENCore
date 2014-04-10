#import "VENTransaction.h"
#import "VENMutableTransaction.h"


SpecBegin(Transactions)

describe(@"Transactions", ^{

    VENTransaction *transaction = [VENTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"benjy@venmo.com"];

    it(@"should successfully create a transaction and apply all properties to the object", ^{
        VENTransaction *transaction = [VENTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"benjy@venmo.com"];
        expect(transaction.type).to.equal(VENTransactionTypePay);
        expect(transaction.amount).to.equal(100);
        expect(transaction.note).to.equal(@"Hi there");
        expect(transaction.audience).to.equal(VENTransactionAudiencePublic);
        expect(transaction.toUserType).to.equal(VENRecipientTypeEmail);
        expect(transaction.toUserHandle).to.equal(@"benjy@venmo.com");
    });

    it(@"should consider regular transactions as immutable", ^{
        // The following code does not compile :p
        // transaction.note = @"";
    });

    it(@"should allow mutating properties on mutable transactions", ^{

    });

    it(@"should do crazy mutable things", ^{

        VENMutableTransaction *mutableTransaction = [transaction mutableCopy];

        expect(mutableTransaction.note).to.equal(@"Hi there");

        mutableTransaction.note = @"I am a new note";

        expect(mutableTransaction.note).to.equal(@"I am a new note");
        expect(transaction.note).to.equal(@"Hi there");

    });
});

SpecEnd