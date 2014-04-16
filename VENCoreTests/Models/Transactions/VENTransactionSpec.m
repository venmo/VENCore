#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"
#import "VENUser.h"

@interface VENTransaction ()

@property (strong, nonatomic) NSMutableOrderedSet *mutableTargets;

- (BOOL)containsDuplicateOfTarget:(VENTransactionTarget *)target;

- (NSDictionary *)dictionaryWithParametersForTarget:(VENTransactionTarget *)target;

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
        
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without an ID", ^{
        
    });
    
    it(@"should return NO to canInitWithDictionary for a transaction dictionary without any transaction targets", ^{
        
    });
    
    it(@"should successfully initialize a transaction from a valid transaction dictionary", ^{
        VENTransaction *transaction = [[VENTransaction alloc] initWithDictionary:paymentObject];
        
        expect(transaction.transactionID).to.equal(@"1322585332520059420");
        expect(transaction.note).to.equal(@"Rock Climbing!");
        expect(transaction.actor.externalId).to.equal(@"1088551785594880949");
        expect(transaction.transactionType).to.equal(VENTransactionTypePay);
        expect(transaction.status).to.equal(VENTransactionStatusPending);
        expect(transaction.audience).to.equal(VENTransactionAudiencePublic);
        
        expect([transaction.targets count]).to.equal(1);
        expect(((VENTransactionTarget *)transaction.targets[0]).handle).to.equal(@"nonvenmouser@gmail.com");
        
    });
    
    
});


describe(@"addTarget", ^{
    it(@"should call addTargets with a set containing the target.", ^{
        id mockTarget = [OCMockObject mockForClass:[VENTransactionTarget class]];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        NSSet *targetsSet = [NSSet setWithObject:mockTarget];
        [[mockTransaction expect] addTargets:targetsSet];
        [mockTransaction addTarget:mockTarget];
        [mockTransaction verify];
    });

    it(@"should return any error returned by addTargets", ^{
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        id mockError = [OCMockObject mockForClass:[NSError class]];
        [[[mockTransaction stub] andReturn:mockError] addTargets:OCMOCK_ANY];
        NSError *error = [mockTransaction addTarget:[OCMockObject mockForClass:[VENTransactionTarget class]]];
        expect(error).to.equal(mockError);
    });
});

describe(@"addTargets", ^{
    it(@"should add a set of three valid targets to the transaction", ^{
        id mockTarget1 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget1 stub] andReturnValue:@YES] isValid];
        id mockTarget2 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget2 stub] andReturnValue:@YES] isValid];
        id mockTarget3 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget3 stub] andReturnValue:@YES] isValid];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturnValue:@NO] containsDuplicateOfTarget:OCMOCK_ANY];

        NSSet *targets = [NSSet setWithArray:@[mockTarget1, mockTarget2, mockTarget3]];
        NSError *error = [mockTransaction addTargets:targets];
        expect(error).to.beNil();
        for (id target in targets) {
            expect([((VENTransaction *)mockTransaction).targets containsObject:target]).to.equal(YES);
        }
    });

    it(@"should not add a set of two valid targets and an invalid target to the transaction", ^{
        id mockTarget1 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget1 stub] andReturnValue:@YES] isValid];
        id mockTarget2 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget2 stub] andReturnValue:@YES] isValid];
        id mockTarget3 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget3 stub] andReturnValue:@NO] isValid];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturnValue:@NO] containsDuplicateOfTarget:OCMOCK_ANY];

        NSSet *targets = [NSSet setWithArray:@[mockTarget1, mockTarget2, mockTarget3]];
        NSError *error = [transaction addTargets:targets];
        expect(error).toNot.beNil();
        for (id target in targets) {
            expect([transaction.targets containsObject:target]).to.equal(NO);
        }
    });

    xit(@"should not allow adding an object that is not a VENTransactionTarget instance", ^{
        id object = [NSObject new];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        NSSet *targets = [NSSet setWithArray:@[object]];
        BOOL added = [transaction addTargets:targets];
        expect(added).to.equal(NO);
        expect([transaction.targets containsObject:object]).to.equal(NO);
    });
});

describe(@"containsDuplicateOfTarget", ^{
    it(@"should return YES if the transaction already has a target with the same handle", ^{
        NSString *handle = @"handle";
        id mockTarget1 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget1 stub] andReturn:handle] handle];

        id mockTarget2 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget2 stub] andReturn:@"bla"] handle];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        NSMutableOrderedSet *targetSet = [[NSMutableOrderedSet alloc] initWithArray:@[mockTarget2, mockTarget1]];
        [[[mockTransaction stub] andReturn:targetSet] targets];

        id mockTargetParameter = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTargetParameter stub] andReturn:handle] handle];
        BOOL containsDuplicate = [mockTransaction containsDuplicateOfTarget:mockTargetParameter];
        expect(containsDuplicate).to.beTruthy();
    });

    it(@"should return NO if the transaction doesn't have any targets with the same handle", ^{
        id mockTarget1 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget1 stub] andReturn:@"foo"] handle];

        id mockTarget2 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget2 stub] andReturn:@"bar"] handle];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        NSMutableOrderedSet *targetSet = [[NSMutableOrderedSet alloc] initWithArray:@[mockTarget2, mockTarget1]];
        [[[mockTransaction stub] andReturn:targetSet] targets];

        id mockTargetParameter = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTargetParameter stub] andReturn:@"baz"] handle];
        BOOL containsDuplicate = [mockTransaction containsDuplicateOfTarget:mockTargetParameter];
        expect(containsDuplicate).to.beFalsy();
    });
});

describe(@"readyToSend", ^{
    it(@"should return YES if transaction has at least one target, has a note, transactionType and status is not sent.", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypePay;
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusNotSent;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(YES);
    });
    
    it(@"should return NO if there are 0 targets", ^{
        VENTransaction *transaction = [[VENTransaction alloc] init];
        transaction.note = @"Here is 10 Bucks";
        transaction.transactionType = VENTransactionTypePay;
        transaction.status = VENTransactionStatusNotSent;
        expect([transaction readyToSend]).to.equal(NO);
    });
    
    it(@"should return NO if transaction has no note", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypePay;
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusNotSent;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(NO);
    });
    
    it(@"should return NO if transactionType has not been set", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusNotSent;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(NO);
    });
    
    it(@"should return NO if status is settled", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypePay;
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusSettled;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(NO);
    });
    
    it(@"should return NO if status is pending", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypePay;
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusPending;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(NO);
    });
    
});

describe(@"dictionaryWithParametersForTarget:", ^{
    it(@"should create a parameters dictionary for positive amounts", ^{
        NSString *emailAddress = @"dasmer@venmo.com";
        NSString *note = @"Here is two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        [transaction addTarget:target];
        transaction.note = note;
        transaction.transactionType = VENTransactionTypePay;
        transaction.audience = VENTransactionAudienceFriends;
        transaction.status = VENTransactionStatusNotSent;
        NSDictionary *expectedPostParameters = @{@"email": emailAddress,
                                                 @"note": note,
                                                 @"amount" : amount,
                                                 @"audience" : @"friends"};
        NSDictionary *postParameters = [transaction dictionaryWithParametersForTarget:target];
        expect(postParameters).to.equal(expectedPostParameters);
        
    });
    
    it(@"should create a parameters dictionary for negative amounts", ^{
        NSString *emailAddress = @"dasmer@venmo.com";
        NSString *note = @"I want your two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        [transaction addTarget:target];
        transaction.note = note;
        transaction.transactionType = VENTransactionTypeCharge;
        transaction.audience = VENTransactionAudiencePrivate;
        transaction.status = VENTransactionStatusNotSent;
        NSDictionary *expectedPostParameters = @{@"email": emailAddress,
                                                 @"note": note,
                                                 @"amount" : @"-200",
                                                 @"audience" : @"private"};
        NSDictionary *postParameters = [transaction dictionaryWithParametersForTarget:target];
        expect(postParameters).to.equal(expectedPostParameters);
        
    });
    
    
    it(@"should return nil if target type is unknown", ^{
        NSString *emailAddress = @"dasmer";
        NSString *note = @"I want your two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:target];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        [transaction addTarget:target];
        ((VENTransaction *)mockTransaction).note = note;
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypeCharge;
        ((VENTransaction *)mockTransaction).audience = VENTransactionAudiencePrivate;
        ((VENTransaction *)mockTransaction).status = VENTransactionStatusNotSent;
        NSDictionary *postParameters = [((VENTransaction *)mockTransaction) dictionaryWithParametersForTarget:target];
        expect(target.targetType).equal(VENTargetTypeUnknown);
        expect(postParameters).to.beNil();
    });
});

describe(@"Equality", ^{
    it(@"should consider two identical transactions equal", ^{
        
    });

    it(@"should consider two transactions with different transaction targets different", ^{
        
    });
    
    it(@"should consider two identical transactions with empty targets equal", ^{
        
    });
    
    it(@"should consider two identical transactions but with different types inequal", ^{
        
    });
    
    it(@"should consider transactions with different ids inequal", ^{
        
    });
    
    it(@"should consider transactions with different statusses EQUAL", ^{
        
    });
    
});

SpecEnd