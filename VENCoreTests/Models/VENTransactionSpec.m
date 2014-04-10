#import "VENTransaction.h"
#import "VENMutableTransaction.h"
#import <objc/runtime.h>

VENTransaction *transaction;

SpecBegin(VENTransaction)

before(^{
    transaction = [VENTransaction transactionWithType:VENTransactionTypePay amount:100 note:@"Hi there" audience:VENTransactionAudiencePublic recipientType:VENRecipientTypeEmail recipientString:@"kishkish@venmo.com"];
});

describe(@"transactionWithType:", ^{

    it(@"should successfully create a transaction and apply all properties to the object", ^{
        expect(transaction.type).to.equal(VENTransactionTypePay);
        expect(transaction.amount).to.equal(100);
        expect(transaction.note).to.equal(@"Hi there");
        expect(transaction.audience).to.equal(VENTransactionAudiencePublic);
        expect(transaction.toUserType).to.equal(VENRecipientTypeEmail);
        expect(transaction.toUserHandle).to.equal(@"kishkish@venmo.com");
    });
});

describe(@"immutability:", ^{
    it(@"should have readonly properties", ^{
        // Couldn't figure out a way to test immutability in this case, even with runtime.h
        // This shouldn't compile...
//        transaction.type = VENTransactionTypeCharge;
    });

});

SpecEnd