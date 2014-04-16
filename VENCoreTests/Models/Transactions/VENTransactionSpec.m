#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"

@interface VENTransaction ()

@property (strong, nonatomic) NSMutableOrderedSet *mutableTargets;

- (BOOL)containsDuplicateOfTarget:(VENTransactionTarget *)target;

@end

SpecBegin(VENTransaction)

before(^{
    NSDictionary *paymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSDictionary *paymentObject = paymentResponse[@"data"][@"payment"];
//    transaction = [VENTransaction transactionWithPaymentObject:paymentObject];
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
    it(@"should return NO if there are 0 targets", ^{
        VENTransaction *transaction = [[VENTransaction alloc] init];
        transaction.note = @"Here is 10 Bucks";
        transaction.transactionType = VENTransactionTypePay;
        transaction.status = VENTransactionStatusNotSent;
        expect([transaction readyToSend]).to.equal(NO);
    });
});

SpecEnd