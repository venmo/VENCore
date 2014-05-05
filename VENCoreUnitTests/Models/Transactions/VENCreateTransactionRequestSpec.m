#import "VENTransaction.h"
#import "VENTestUtilities.h"
#import "VENTransactionTarget.h"
#import "VENUser.h"
#import "VENTransactionPayloadKeys.h"
#import "VENCore.h"
#import "VENHTTPResponse.h"
#import "VENCreateTransactionRequest.h"

@interface VENCreateTransactionRequest (Private)

@property (strong, nonatomic) NSMutableOrderedSet *mutableTargets;

- (NSDictionary *)dictionaryWithParametersForTarget:(VENTransactionTarget *)target;

- (BOOL)containsDuplicateOfTarget:(VENTransactionTarget *)target;

@end

SpecBegin(VENCreateTransactionRequest)

describe(@"Sending Payments With Stubbed Responses", ^{

    __block NSDictionary *emailPaymentObject;
    __block NSDictionary *userPaymentObject;
    __block id mockVENHTTP;
    __block VENCore *core;

    void(^stubSuccessBlockEmail)(NSInvocation *) = ^(NSInvocation *invocation) {
        void(^successBlock)(VENHTTPResponse *);
        [invocation getArgument:&successBlock atIndex:4];

        VENHTTPResponse *response = [[VENHTTPResponse alloc] initWithStatusCode:200 responseObject:@{@"data":@{@"payment":emailPaymentObject}}];
        successBlock(response);
    };

    void(^stubSuccessBlockPhone)(NSInvocation *) = ^(NSInvocation *invocation) {
        void(^successBlock)(VENHTTPResponse *);
        [invocation getArgument:&successBlock atIndex:4];

        VENHTTPResponse *response = [[VENHTTPResponse alloc] initWithStatusCode:200 responseObject:@{@"data":@{@"payment":userPaymentObject}}];
        successBlock(response);
    };

    void(^stubFailureBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void(^failureBlock)(VENHTTPResponse *, NSError *);
        [invocation getArgument:&failureBlock atIndex:5];

        VENHTTPResponse *response = [[VENHTTPResponse alloc] initWithStatusCode:400 responseObject:nil];
        id mockError = [OCMockObject mockForClass:[NSError class]];
        failureBlock(response, mockError);
    };

    NSDictionary *(^expectedParameters)(VENCreateTransactionRequest *transactionService, VENTransactionTarget *target) =
    ^(VENCreateTransactionRequest *transactionService, VENTransactionTarget *target) {
        NSMutableDictionary *expectedParams = [[transactionService dictionaryWithParametersForTarget:target] mutableCopy];
        NSDictionary *accessTokenParams = @{@"access_token" : core.accessToken};
        [expectedParams addEntriesFromDictionary:accessTokenParams];
        return expectedParams;
    };

    beforeEach(^{
        NSDictionary *emailPaymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
        emailPaymentObject = emailPaymentResponse[@"data"][@"payment"];
        NSDictionary *userPaymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToUser"];
        userPaymentObject = userPaymentResponse[@"data"][@"payment"];
        mockVENHTTP = [OCMockObject niceMockForClass:[VENHTTP class]];
        core = [[VENCore alloc] init];
        core.httpClient = mockVENHTTP;
        [core setAccessToken:@"123"];
        [VENCore setDefaultCore:core];

    });

    describe(@"sending a transaction with one target", ^{
        it(@"should POST to the payments endpoint and call the success block when the POST succeeds", ^AsyncBlock {
            VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transactionService addTransactionTarget:target];
            transactionService.note = @"hi";

            NSDictionary *expectedParams = expectedParameters(transactionService, target);
            [[[mockVENHTTP expect] andDo:stubSuccessBlockEmail] POST:@"payments"
                                                          parameters:expectedParams
                                                             success:OCMOCK_ANY
                                                             failure:OCMOCK_ANY];

            [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
                expect([sentTransactions count]).to.equal(1);
                done();
            } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
                XCTFail();
                done();
            }];
        });

        it(@"should POST to the payments endpoint and call the failure block when the POST fails", ^AsyncBlock {
            VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transactionService addTransactionTarget:target];
            transactionService.note = @"hi";

            NSDictionary *expectedParams = expectedParameters(transactionService, target);
            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
                                                     parameters:expectedParams
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];

            [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
                XCTFail();
                done();
            } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
                expect([sentTransactions count]).to.equal(0);
                expect(response).toNot.beNil();
                expect(error).toNot.beNil();
                done();
            }];

        });
    });

    describe(@"sending a transaction with two targets",  ^{
        it(@"should POST twice to the payments endpoint and call the success block twice when both transactions succeed", ^AsyncBlock {
            VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
            transactionService.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transactionService addTransactionTarget:target1];

            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:420];
            [transactionService addTransactionTarget:target2];

            NSDictionary *expectedParameters1 = expectedParameters(transactionService, target1);
            NSDictionary *expectedParameters2 = expectedParameters(transactionService, target2);

            [[[mockVENHTTP expect] andDo:stubSuccessBlockEmail] POST:@"payments"
                                                          parameters:expectedParameters1
                                                             success:OCMOCK_ANY
                                                             failure:OCMOCK_ANY];
            [[[mockVENHTTP expect] andDo:stubSuccessBlockPhone] POST:@"payments"
                                                          parameters:expectedParameters2
                                                             success:OCMOCK_ANY
                                                             failure:OCMOCK_ANY];

            [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
                expect([sentTransactions count]).to.equal(2);
                done();
            } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
                XCTFail();
                done();
            }];
        });

        it(@"should call successBlock for successful payment and failureBlock for second payment which fails", ^AsyncBlock {
            VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
            transactionService.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transactionService addTransactionTarget:target1];

            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:420];
            [transactionService addTransactionTarget:target2];

            NSDictionary *expectedParameters1 = expectedParameters(transactionService, target1);
            NSDictionary *expectedParameters2 = expectedParameters(transactionService, target2);

            [[[mockVENHTTP expect] andDo:stubSuccessBlockEmail] POST:@"payments"
                                                          parameters:expectedParameters1
                                                             success:OCMOCK_ANY
                                                             failure:OCMOCK_ANY];

            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
                                                     parameters:expectedParameters2
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];

            [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
                XCTFail();
                done();
            } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
                // The failure block shouldn't be called
                expect([sentTransactions count]).to.equal(1);
                done();
            }];
        });

        it(@"should not initiate second payment if the first payment fails", ^AsyncBlock {

            VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
            transactionService.note = @"hi";

            VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter@venmo.com" amount:30];
            [transactionService addTransactionTarget:target1];
            NSDictionary *expectedParameters1 = expectedParameters(transactionService, target1);

            //payment to target 2 should not be sent since the first payment fails
            VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"das@venmo.com" amount:125];
            [transactionService addTransactionTarget:target2];

            [[[mockVENHTTP expect] andDo:stubFailureBlock] POST:@"payments"
                                                     parameters:expectedParameters1
                                                        success:OCMOCK_ANY
                                                        failure:OCMOCK_ANY];
            
            [transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
                XCTFail();
                done();
            } failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
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


describe(@"addTarget", ^{
    it(@"it should add a valid target", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:@(YES)]isValid];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        BOOL addedTarget = [transactionService addTransactionTarget:mockTarget];
        expect(addedTarget).to.beTruthy();
        expect([transactionService.targets count]).to.equal(1);
    });

    it(@"it should not add a invalid target", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        [[[mockTarget stub] andReturnValue:@(NO)] isValid];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        BOOL addedTarget = [transactionService addTransactionTarget:mockTarget];
        expect(addedTarget).to.beFalsy();
        expect([transactionService.targets count]).to.equal(0);
    });

    it(@"it should not add duplicate targets", ^{
        id mockTarget = [OCMockObject niceMockForClass:[VENTransactionTarget class]];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        [[[mockTransaction stub] andReturnValue:@(YES)] containsDuplicateOfTarget:OCMOCK_ANY];

        BOOL addedTarget = [mockTransaction addTransactionTarget:mockTarget];
        expect(addedTarget).to.beFalsy();
        expect(((VENCreateTransactionRequest *)mockTransaction).targets.count).to.equal(0);
    });
});


describe(@"readyToSend", ^{
    it(@"should return YES if transaction has at least one target, has a note, transactionType and status is not sent.", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENCreateTransactionRequest *)mockTransaction).note = @"Here is 10 Bucks";
        ((VENCreateTransactionRequest *)mockTransaction).transactionType = VENTransactionTypePay;
        expect([((VENCreateTransactionRequest *)mockTransaction) readyToSend]).to.equal(YES);
    });

    it(@"should return NO if there are 0 targets", ^{
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        transactionService.note = @"Here is 10 Bucks";
        transactionService.transactionType = VENTransactionTypePay;
        expect([transactionService readyToSend]).to.equal(NO);
    });

    it(@"should return NO if transaction has no note", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENCreateTransactionRequest *)mockTransaction).transactionType = VENTransactionTypePay;
        expect([((VENCreateTransactionRequest *)mockTransaction) readyToSend]).to.equal(NO);
    });

    it(@"should return NO if transactionType has not been set", ^{
        id object = [NSObject new];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:object];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        ((VENCreateTransactionRequest *)mockTransaction).note = @"Here is 10 Bucks";
        expect([((VENCreateTransactionRequest *)mockTransaction) readyToSend]).to.equal(NO);
    });

});


describe(@"dictionaryWithParametersForTarget:", ^{
    it(@"should create a parameters dictionary for positive amounts", ^{
        NSString *emailAddress = @"dasmer@venmo.com";
        NSString *note = @"Here is two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        [transactionService addTransactionTarget:target];
        transactionService.note = note;
        transactionService.transactionType = VENTransactionTypePay;
        transactionService.audience = VENTransactionAudienceFriends;
        NSDictionary *expectedPostParameters = @{@"email": emailAddress,
                                                 @"note": note,
                                                 @"amount" : @"2.00",
                                                 @"audience" : @"friends"};
        NSDictionary *postParameters = [transactionService dictionaryWithParametersForTarget:target];
        expect(postParameters).to.equal(expectedPostParameters);

    });

    it(@"should create a parameters dictionary for negative amounts", ^{
        NSString *emailAddress = @"dasmer@venmo.com";
        NSString *note = @"I want your two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        [transactionService addTransactionTarget:target];
        transactionService.note = note;
        transactionService.transactionType = VENTransactionTypeCharge;
        transactionService.audience = VENTransactionAudiencePrivate;
        NSDictionary *expectedPostParameters = @{@"email": emailAddress,
                                                 @"note": note,
                                                 @"amount" : @"-2.00",
                                                 @"audience" : @"private"};
        NSDictionary *postParameters = [transactionService dictionaryWithParametersForTarget:target];
        expect(postParameters).to.equal(expectedPostParameters);

    });


    it(@"should return nil if target type is unknown", ^{
        NSString *emailAddress = @"dasmer";
        NSString *note = @"I want your two bucks";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithObject:target];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        [[[mockTransaction stub] andReturn:orderedSet] mutableTargets];
        [transactionService addTransactionTarget:target];
        ((VENCreateTransactionRequest *)mockTransaction).note = note;
        ((VENCreateTransactionRequest *)mockTransaction).transactionType = VENTransactionTypeCharge;
        ((VENCreateTransactionRequest *)mockTransaction).audience = VENTransactionAudiencePrivate;
        NSDictionary *postParameters = [((VENCreateTransactionRequest *)mockTransaction) dictionaryWithParametersForTarget:target];
        expect(target.targetType).equal(VENTargetTypeUnknown);
        expect(postParameters).to.beNil();
    });


    it(@"should not include audience if audience is set to UserDefault", ^{
        NSString *emailAddress = @"btest@example.com";
        NSString *note = @"bla";
        NSString *amount = @"200";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:emailAddress amount:[amount integerValue]];
        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        [transactionService addTransactionTarget:target];
        transactionService.note = note;
        transactionService.transactionType = VENTransactionTypePay;
        transactionService.audience = VENTransactionAudienceUserDefault;
        NSDictionary *expectedPostParameters = @{@"email": emailAddress,
                                                 @"note": note,
                                                 @"amount" : @"2.00"};
        NSDictionary *postParameters = [transactionService dictionaryWithParametersForTarget:target];
        expect(postParameters).to.equal(expectedPostParameters);
    });


});

describe(@"containsDuplicateOfTarget", ^{
    it(@"should return YES if the transaction already has a target with the same handle", ^{
        NSString *handle = @"handle";
        id mockTarget1 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget1 stub] andReturn:handle] handle];

        id mockTarget2 = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTarget2 stub] andReturn:@"bla"] handle];

        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
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

        VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];
        id mockTransaction = [OCMockObject partialMockForObject:transactionService];
        NSMutableOrderedSet *targetSet = [[NSMutableOrderedSet alloc] initWithArray:@[mockTarget2, mockTarget1]];
        [[[mockTransaction stub] andReturn:targetSet] targets];

        id mockTargetParameter = [OCMockObject mockForClass:[VENTransactionTarget class]];
        [[[mockTargetParameter stub] andReturn:@"baz"] handle];
        BOOL containsDuplicate = [mockTransaction containsDuplicateOfTarget:mockTargetParameter];
        expect(containsDuplicate).to.beFalsy();
    });
});

SpecEnd
