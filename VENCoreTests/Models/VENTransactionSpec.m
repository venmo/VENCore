#import "VENTransaction+Internal.h"
#import "VENMutableTransaction.h"
#import "VENBundledFileParser.h"

VENTransaction *transaction;

SpecBegin(VENTransaction)

before(^{
    NSDictionary *paymentObject = [VENBundledFileParser objectFromJSONResource:@"paymentToEmail"];
    transaction = [VENTransaction transactionWithPaymentObject:paymentObject];
});

describe(@"transactionWithPaymentObject:", ^{
    it(@"should successfully create a transaction and apply all properties to the object", ^{
        expect(transaction.transactionID).to.equal(@"1322585332520059420");
        expect(transaction.type).to.equal(VENTransactionTypePay);
        expect(transaction.amount).to.equal(400);
        expect(transaction.note).to.equal(@"Rock Climbing!");
        expect(transaction.fromUserID).to.equal(@"1088551785594880949");
        expect(transaction.toUserType).to.equal(VENRecipientTypeEmail);
        expect(transaction.toUserHandle).to.equal(@"nonvenmouser@gmail.com");
        expect(transaction.toUserID).to.equal(nil);
        expect(transaction.audience).to.equal(VENTransactionAudiencePublic);
    });
});

describe(@"mutableCopy", ^{
    it(@"should return a VENMutableTransaction object with the same properties", ^{
        VENMutableTransaction *mutableTransaction = [transaction mutableCopy];
        expect(mutableTransaction.transactionID).to.equal(transaction.transactionID);
        expect(mutableTransaction.type).to.equal(transaction.type);
        expect(mutableTransaction.amount).to.equal(transaction.amount);
        expect(mutableTransaction.note).to.equal(transaction.note);
        expect(mutableTransaction.fromUserID).to.equal(transaction.fromUserID);
        expect(mutableTransaction.toUserType).to.equal(transaction.toUserType);
        expect(mutableTransaction.toUserHandle).to.equal(transaction.toUserHandle);
        expect(mutableTransaction.toUserID).to.equal(transaction.toUserID);
        expect(mutableTransaction.audience).to.equal(transaction.audience);
    });
});

describe(@"immutability:", ^{
    it(@"should have readonly properties", ^{
        // Couldn't figure out an elegant way to test immutability in this case
        // This shouldn't compile...
//        transaction.type = VENTransactionTypeCharge;
    });

});

SpecEnd