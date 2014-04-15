#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"

VENTransaction *transaction;

SpecBegin(VENTransaction)

before(^{
    NSDictionary *paymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSDictionary *paymentObject = paymentResponse[@"data"][@"payment"];
//    transaction = [VENTransaction transactionWithPaymentObject:paymentObject];
});


describe(@"addTarget", ^{
    it(@"should add a valid target to targets", ^{
        id mockTarget = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:@YES] isValid];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        BOOL added = [transaction addTarget:mockTarget];
        expect(added).to.equal(YES);
        expect([transaction.targets containsObject:mockTarget]).to.equal(YES);
    });

    it(@"should not add an invalid target to targets", ^{
        id mockTarget = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:NO] isValid];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        BOOL added = [transaction addTarget:mockTarget];
        expect(added).to.equal(NO);
        expect([transaction.targets containsObject:mockTarget]).to.equal(NO);
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
        NSSet *targets = [NSSet setWithArray:@[mockTarget1, mockTarget2, mockTarget3]];
        BOOL added = [transaction addTargets:targets];
        expect(added).to.equal(YES);
        for (id target in targets) {
            expect([transaction.targets containsObject:target]).to.equal(YES);
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
        NSSet *targets = [NSSet setWithArray:@[mockTarget1, mockTarget2, mockTarget3]];
        BOOL added = [transaction addTargets:targets];
        expect(added).to.equal(NO);
        for (id target in targets) {
            expect([transaction.targets containsObject:target]).to.equal(NO);
        }
    });

    it(@"should not allow adding an object that is not a VENTransactionTarget instance", ^{
        id object = [NSObject new];

        VENTransaction *transaction = [[VENTransaction alloc] init];
        NSSet *targets = [NSSet setWithArray:@[object]];
        BOOL added = [transaction addTargets:targets];
        expect(added).to.equal(NO);
        expect([transaction.targets containsObject:object]).to.equal(NO);
    });
});

SpecEnd