#import "VENTransactionTarget.h"
#import "VENUser.h"

@interface VENUser (Internal)

@property (strong, nonatomic, readwrite) NSString *externalId;

@end


SpecBegin(VENTransactionTarget)

describe(@"initWithHandle:amount:", ^{
    it(@"setting the handle to an email should set the type to email", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:100];
        expect(target.targetType).to.equal(VENTargetTypeEmail);
    });

    it(@"setting the handle to a phone number should set the type to phone", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"2125007000" amount:100];
        expect(target.targetType).to.equal(VENTargetTypePhone);
    });

    it(@"setting the handle to a userID should set the type to userID", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"1234567" amount:100];
        expect(target.targetType).to.equal(VENTargetTypeUserId);
    });
});


describe(@"isValid", ^{
    it(@"should return YES if the target has a valid type and nonzero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:100];
        expect([target isValid]).to.equal(YES);
    });

    it(@"should return NO if the target has type VENTargetTypeUnknown and nonzero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"b2124" amount:100];
        expect([target isValid]).to.equal(NO);
    });

    it(@"should return NO if the target has type VENTargetTypeUnknown and zero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"b2124" amount:0];
        expect([target isValid]).to.equal(NO);
    });

    it(@"should return NO if the target has a valid type and zero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"4104444444" amount:0];
        expect([target isValid]).to.equal(NO);
    });
});


describe(@"setUser", ^{
    it(@"should set the target's user", ^{
        id mockUser = [OCMockObject niceMockForClass:[VENUser class]];
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:100];
        target.user = mockUser;
        expect(target.user).to.equal(mockUser);
    });

    it(@"should set the target's handle to the user's user id", ^{
        id mockUser = [OCMockObject mockForClass:[VENUser class]];
        NSString *userId = @"12345";
        [[[mockUser stub] andReturn:userId] externalId];

        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:100];
        target.user = mockUser;

        expect(target.handle).to.equal(userId);
        expect(target.targetType).to.equal(VENTargetTypeUserId);
    });
});

SpecEnd