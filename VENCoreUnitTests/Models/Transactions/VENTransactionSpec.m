#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"
#import "VENUser.h"
#import "VENTransactionPayloadKeys.h"
#import "VENCore.h"
#import "VENHTTPResponse.h"

@interface VENTransaction (Private)

@property (strong, nonatomic) NSMutableOrderedSet *mutableTargets;

- (BOOL)containsDuplicateOfTarget:(VENTransactionTarget *)target;

@end

SpecBegin(VENTransaction)

void(^assertTransactionsAreFieldwiseEqual)(VENTransaction *, VENTransaction *) = ^(VENTransaction *tx1, VENTransaction *tx2) {
    expect(tx1.transactionID).to.equal(tx2.transactionID);
    expect(tx1.targets).to.equal(tx2.targets);
    expect(tx1.note).to.equal(tx2.note);
    expect(tx1.actor).to.equal(tx2.actor);
    expect(tx1.transactionType).to.equal(tx2.transactionType);
    expect(tx1.status).to.equal(tx2.status);
    expect(tx1.audience).to.equal(tx2.audience);
};


describe(@"Initialization", ^{

    NSDictionary *paymentResponse   = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSDictionary *paymentObject     = paymentResponse[@"data"][@"payment"];
    
    it(@"should return YES to canInitWithDictionary for a valid transaction dictionary", ^{
        NSDictionary *validTransactionDictionary = paymentObject;
        
        expect([VENTransaction canInitWithDictionary:validTransactionDictionary]).to.beTruthy();
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without an ID", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        [invalidTransactionDictionary removeObjectForKey:VENTransactionIDKey];
        
        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without any transaction targets", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        [invalidTransactionDictionary removeObjectForKey:VENTransactionTargetKey];
        
        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without a note", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        [invalidTransactionDictionary removeObjectForKey:VENTransactionNoteKey];
        
        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without an actor", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        [invalidTransactionDictionary removeObjectForKey:VENTransactionActorKey];
        
        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without an amount", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        [invalidTransactionDictionary removeObjectForKey:VENTransactionAmountKey];
        
        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary when the note is NSNull", ^{
        NSMutableDictionary *invalidTransactionDictionary = [paymentObject mutableCopy];
        invalidTransactionDictionary[VENTransactionNoteKey] = [NSNull null];

        expect([VENTransaction canInitWithDictionary:invalidTransactionDictionary]).to.beFalsy();
    });
    
    it(@"should successfully initialize a transaction from a valid transaction dictionary", ^{
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:paymentObject];
        
        expect(transaction.transactionID).to.equal(@"1322585332520059421");
        expect(transaction.note).to.equal(@"Rock Climbing!");
        expect(transaction.actor.externalId).to.equal(@"1088551785594880949");
        expect(transaction.transactionType).to.equal(VENTransactionTypePay);
        expect(transaction.status).to.equal(VENTransactionStatusPending);
        expect(transaction.audience).to.equal(VENTransactionAudiencePublic);
        
        expect([transaction.targets count]).to.equal(1);
        expect(((VENTransactionTarget *)transaction.targets[0]).handle).to.equal(@"nonvenmouser@gmail.com");
    });
});


describe(@"Equality", ^{
    
    NSDictionary *paymentResponse   = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSDictionary *paymentObject     = paymentResponse[@"data"][@"payment"];
    
    it(@"should consider two identical transactions equal", ^{
        VENTransaction *transaction1 = [[VENTransaction alloc] initWithDictionary:paymentObject];
        VENTransaction *transaction2 = [[VENTransaction alloc] initWithDictionary:paymentObject];
        
        expect(transaction1).to.equal(transaction2);
        expect(transaction2).to.equal(transaction1);
    });

    it(@"should consider two transactions with different transaction targets different", ^{
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:paymentObject];
        
        NSMutableDictionary *transactionDictionary = [paymentObject mutableCopy];
        [transactionDictionary removeObjectForKey:VENTransactionTargetKey];

        VENTransactionTarget *newTarget = [[VENTransactionTarget alloc] initWithHandle:@"Ben Guo" amount:14];
        transactionDictionary[VENTransactionTargetKey] = [newTarget dictionaryRepresentation];
        VENTransaction *otherTransaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        
        expect(transaction).to.equal(otherTransaction);
    });
    
    it(@"should consider two identical transactions with empty targets equal", ^{
        NSMutableDictionary *transactionDictionary = [paymentObject mutableCopy];
        [transactionDictionary removeObjectForKey:VENTransactionTargetKey];
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        VENTransaction *otherTransaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        
        expect(transaction).to.equal(otherTransaction);
    });
    
    it(@"should consider two identical transactions but with different types inequal", ^{
        NSMutableDictionary *transactionDictionary = [paymentObject mutableCopy];
        NSMutableDictionary *otherTransactionDictionary = [transactionDictionary mutableCopy];
        otherTransactionDictionary[VENTransactionTypeKey] = VENTransactionTypeStrings[VENTransactionTypeCharge];
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        VENTransaction *otherTransaction = [[VENTransaction alloc] initWithDictionary:otherTransactionDictionary];
        
        expect(transaction).toNot.equal(otherTransaction);
    });
    
    it(@"should consider transactions with different ids inequal", ^{
        NSMutableDictionary *transactionDictionary = [paymentObject mutableCopy];
        transactionDictionary[VENTransactionIDKey] = @"frack";
        
        NSMutableDictionary *otherTransactionDictionary = [transactionDictionary mutableCopy];
        otherTransactionDictionary[VENTransactionIDKey] = @"frick";
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        VENTransaction *otherTransaction = [[VENTransaction alloc] initWithDictionary:otherTransactionDictionary];
        
        expect(transaction).toNot.equal(otherTransaction);
    });
    
    it(@"should consider transactions with different statuses EQUAL", ^{
        NSMutableDictionary *transactionDictionary = [paymentObject mutableCopy];
        transactionDictionary[VENTransactionStatusKey] = VENTransactionStatusStrings[VENTransactionStatusNotSent];
        
        NSMutableDictionary *otherTransactionDictionary = [transactionDictionary mutableCopy];
        otherTransactionDictionary[VENTransactionStatusKey] = VENTransactionStatusStrings[VENTransactionStatusPending];
        
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:transactionDictionary];
        VENTransaction *otherTransaction = [[VENTransaction alloc] initWithDictionary:otherTransactionDictionary];
        
        expect(transaction).to.equal(otherTransaction);
    });
    
});

SpecEnd