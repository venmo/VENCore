#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"
#import "VENUser.h"
#import "VENTransactionPayloadKeys.h"
#import "VENCore.h"
#import "VENHTTPResponse.h"

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
    it(@"it should add a valid target", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:@(YES)]isValid];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        BOOL addedTarget = [transaction addTransactionTarget:mockTarget];
        expect(addedTarget).to.beTruthy();
        expect([transaction.targets count]).to.equal(1);
    });

    it(@"it should not add a invalid target", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:@(NO)] isValid];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        BOOL addedTarget = [transaction addTransactionTarget:mockTarget];
        expect(addedTarget).to.beFalsy();
        expect([transaction.targets count]).to.equal(0);
    });

    it(@"it should not add duplicate targets", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturnValue:@(YES)] containsDuplicateOfTarget:OCMOCK_ANY];

        BOOL addedTarget = [mockTransaction addTransactionTarget:mockTarget];
        expect(addedTarget).to.beFalsy();
        expect(((VENTransaction *)mockTransaction).targets.count).to.equal(0);
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

    it(@"should return YES if status is not set", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transaction];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENTransaction *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENTransaction *)mockTransaction).transactionType = VENTransactionTypePay;
        expect([((VENTransaction *)mockTransaction) readyToSend]).to.equal(YES);
    });
    
});


describe(@"dictionaryWithParametersForTarget:", ^{
    it(@"should create a parameters dictionary for positive amounts", ^{
        NSString *emailAddress = @"dasmer@venmo.com";
        NSString *note = @"Here is two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENTransaction *transaction = [[VENTransaction alloc] init];
        [transaction addTransactionTarget:target];
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
        [transaction addTransactionTarget:target];
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
        [transaction addTransactionTarget:target];
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


describe(@"Sending Payments With Stubbed Responses", ^{

    __block NSDictionary *paymentResponse;
    __block NSDictionary *paymentObject;
    __block id mockVENHTTP;
    __block VENCore *core;

    void(^stubSuccessBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void(^successBlock)(VENHTTPResponse *);
        [invocation getArgument:&successBlock atIndex:4];

        VENHTTPResponse *response = [[VENHTTPResponse alloc] initWithStatusCode:200 responseObject:@{@"data":@{@"payment":paymentObject}}];
        successBlock(response);
    };

    void(^stubFailureBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void(^failureBlock)(VENHTTPResponse *, NSError *);
        [invocation getArgument:&failureBlock atIndex:5];

        VENHTTPResponse *response = [[VENHTTPResponse alloc] initWithStatusCode:400 responseObject:nil];
        id mockError = [OCMockObject mockForClass:[NSError class]];
        failureBlock(response, mockError);
    };

    beforeEach(^{
        paymentResponse   = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
        paymentObject     = paymentResponse[@"data"][@"payment"];
        mockVENHTTP = [OCMockObject mockForClass:[VENHTTP class]];
        core = [[VENCore alloc] init];
        core.httpClient = mockVENHTTP;
        [VENCore setDefaultCore:core];

    });

    describe(@"sending a transaction with one target", ^{
        it(@"should POST to the payments endpoint and call the success block when the POST succeeds", ^AsyncBlock {
            VENTransaction *transaction = [[VENTransaction alloc] init];
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transaction addTransactionTarget:target];
            transaction.note = @"hi";

            NSDictionary *expectedParameters = [transaction dictionaryWithParametersForTarget:target];
            [[[mockVENHTTP expect] andDo:stubSuccessBlock] POST:@"payments"
             parameters:expectedParameters
             success:OCMOCK_ANY
             failure:OCMOCK_ANY];

            [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
                expect([sentTransactions count]).to.equal(1);
                done();
            } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
                // The failure block shouldn't be called
                XCTAssertFalse(YES);
            }];
        });

        it(@"should POST to the payments endpoint and call the failure block when the POST fails", ^AsyncBlock {
            VENTransaction *transaction = [[VENTransaction alloc] init];
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transaction addTransactionTarget:target];
            transaction.note = @"hi";

            NSDictionary *expectedParameters = [transaction dictionaryWithParametersForTarget:target];
            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
             parameters:expectedParameters
             success:OCMOCK_ANY
             failure:OCMOCK_ANY];

            [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
                // The success block shouldn't be called
                XCTAssertFalse(YES);
            } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
                expect([sentTransactions count]).to.equal(0);
                expect(response).toNot.beNil();
                expect(error).toNot.beNil();
                done();
            }];

        });
    });

    describe(@"sending a transaction with two targets",  ^{
        it(@"should POST twice to the payments endpoint and call the success block twice when both transactions succeed", ^AsyncBlock {
            VENTransaction *transaction = [[VENTransaction alloc] init];
            transaction.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transaction addTransactionTarget:target1];

            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:420];
            [transaction addTransactionTarget:target2];

            NSDictionary *expectedParameters1 = [transaction dictionaryWithParametersForTarget:target1];
            NSDictionary *expectedParameters2 = [transaction dictionaryWithParametersForTarget:target2];


            [[[mockVENHTTP expect] andDo:stubSuccessBlock] POST:@"payments"
                                              parameters:expectedParameters1
                                                 success:OCMOCK_ANY
                                                 failure:OCMOCK_ANY];
            [[[mockVENHTTP expect] andDo:stubSuccessBlock] POST:@"payments"
                                              parameters:expectedParameters2
                                                 success:OCMOCK_ANY
                                                 failure:OCMOCK_ANY];

            [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
                expect([sentTransactions count]).to.equal(2);
                done();
            } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
                // The failure block shouldn't be called
                XCTAssertFalse(YES);
            }];
        });

        it(@"should call successBlock for successful payment and failureBlock for second payment which fails", ^AsyncBlock {
            VENTransaction *transaction = [[VENTransaction alloc] init];
            transaction.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transaction addTransactionTarget:target1];

            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:420];
            [transaction addTransactionTarget:target2];

            NSDictionary *expectedParameters1 = [transaction dictionaryWithParametersForTarget:target1];
            NSDictionary *expectedParameters2 = [transaction dictionaryWithParametersForTarget:target2];


            [[[mockVENHTTP expect] andDo:stubSuccessBlock] POST:@"payments"
                                                     parameters:expectedParameters1
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];

            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
                                                     parameters:expectedParameters2
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];

            [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
                XCTAssertFalse(YES);
            } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
                // The failure block shouldn't be called
                expect([sentTransactions count]).to.equal(1);
                done();
            }];
        });

        it(@"should not initiate second payment if the first payment fails", ^AsyncBlock {

            VENTransaction *transaction = [[VENTransaction alloc] init];
            transaction.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transaction addTransactionTarget:target1];
            NSDictionary *expectedParameters1 = [transaction dictionaryWithParametersForTarget:target1];

            //payment to target 2 should not be sent since the first payment fails
            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"das@venmo.com" amount:125];
            [transaction addTransactionTarget:target2];

            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
                                                     parameters:expectedParameters1
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];

            [transaction sendWithSuccess:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response) {
                // The success block shouldn't be called
                XCTAssertFalse(YES);
            } failure:^(NSOrderedSet *sentTransactions, VENHTTPResponse *response, NSError *error) {
                expect([sentTransactions count]).to.equal(0);
                expect(response).toNot.beNil();
                expect(error).toNot.beNil();
                // Make sure no POSTs are made after the first one.
                dispatch_after(3, dispatch_get_main_queue(), ^{
                    done();
                });
            }];
        });
    });

});

SpecEnd