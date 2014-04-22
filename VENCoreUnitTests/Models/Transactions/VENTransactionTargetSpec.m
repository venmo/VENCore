#import "VENTransactionTarget.h"
#import "VENUser.h"
#import "VENTestUtilities.h"
#import "VENTransactionPayloadKeys.h"

@interface VENUser (Internal)

@property (strong, nonatomic, readwrite) NSString *externalId;

@end


SpecBegin(VENTransactionTarget)

void(^assertTargetsAreFieldWiseEqual)(VENTransactionTarget *, VENTransactionTarget *) = ^(VENTransactionTarget *target1, VENTransactionTarget *target2) {
    expect(target1.amount).to.equal(target2.amount);
    expect(target1.handle).to.equal(target2.handle);
    expect(target1.targetType).to.equal(target2.targetType);
};

describe(@"Initialization", ^{
    
    NSDictionary *transactionJSON           = (NSDictionary *)[VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSMutableDictionary *targetDictionary   = [NSMutableDictionary dictionaryWithDictionary:transactionJSON[@"data"][@"payment"][VENTransactionTargetKey]];
    [targetDictionary setValue:@(4.12) forKey:VENTransactionAmountKey];
    
    it(@"should return NO to canInitWithDictionary for a dictionary without an amount", ^{
        NSMutableDictionary *currentPayload = [targetDictionary mutableCopy];
        [currentPayload removeObjectForKey:VENTransactionAmountKey];
        
        expect([VENTransactionTarget canInitWithDictionary:currentPayload]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a dictionary with an empty string amount", ^{
        NSMutableDictionary *currentPayload = [targetDictionary mutableCopy];
        currentPayload[VENTransactionAmountKey] = @"";
        
        expect([VENTransactionTarget canInitWithDictionary:currentPayload]).to.beFalsy();
    });
    
    it(@"should return NO to canInitWithDictionary for a dictionary without a type-field pair", ^{
        NSMutableDictionary *currentPayload = [targetDictionary mutableCopy];
        [currentPayload removeObjectForKey:VENTransactionTargetTypeKey];
        
        expect([VENTransactionTarget canInitWithDictionary:currentPayload]).to.beFalsy();
    });
    
    it(@"should return YES to canInitWithDictionary for a valid target payload", ^{
        expect([VENTransactionTarget canInitWithDictionary:targetDictionary]).to.beTruthy();
    });
    
    it(@"should correctly initialize a VENTransactionTarget from a valid dictionary", ^{
        VENTransactionTarget *target   = [[VENTransactionTarget alloc] initWithDictionary:targetDictionary];

        expect(target).to.beKindOf([VENTransactionTarget class]);
        expect(target.amount).to.equal(412);
        expect(target.handle).to.equal(@"nonvenmouser@gmail.com");
        expect(target.targetType).to.equal(VENTargetTypeEmail);
        expect([target isValid]).to.equal(YES);
    });
});


describe(@"initWithHandle:amount:", ^{
    it(@"setting the handle to an email should set the type to email", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:128];
        
        expect(target.amount).to.equal(128);
        expect(target.handle).to.equal(@"ben@venmo.com");
        expect(target.targetType).to.equal(VENTargetTypeEmail);
    });

    it(@"setting the handle to a phone number should set the type to phone", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"2125007000" amount:10123150];
        
        expect(target.amount).to.equal(10123150);
        expect(target.handle).to.equal(@"2125007000");
        expect(target.targetType).to.equal(VENTargetTypePhone);
    });

    it(@"setting the handle to a userID should set the type to userID", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"1234567" amount:12];
        
        expect(target.amount).to.equal(12);
        expect(target.handle).to.equal(@"1234567");
        expect(target.targetType).to.equal(VENTargetTypeUserId);
    });
});


fdescribe(@"isValid", ^{
    it(@"should return YES if the target has a valid type and nonzero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:653445];
        expect([target isValid]).to.equal(YES);
    });

    it(@"should return NO if the target has type VENTargetTypeUnknown and nonzero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"b2124" amount:8765];
        expect([target isValid]).to.equal(NO);
    });

    it(@"should return NO if the target has type VENTargetTypeUnknown and zero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"b2124" amount:0];
        expect([target isValid]).to.equal(NO);
    });

    it(@"should return NO if the target has a valid type but zero amount", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"4104444444" amount:0];
        expect([target isValid]).to.equal(NO);
    });

    it(@"should return NO if the target has a negative amount" , ^{
        VENTransactionTarget *target =[[VENTransactionTarget alloc] initWithHandle:@"9177436332" amount:-20];
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


describe(@"Equality", ^{
    it(@"should consider two VENTransactionTargets with the same handle and amount equal", ^{
        VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter" amount:100];
        VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"peter" amount:100];

        expect(target1).to.equal(target2);
    });
    
    it(@"should be transitive", ^{
        VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"peter" amount:100];
        VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"peter" amount:100];
        
        expect(target1).to.equal(target2);
        expect(target2).to.equal(target1);
    });
    
    it(@"should consider a VENTransactionTarget equal to itself", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter" amount:1000];
        
        expect(target).to.equal(target);
    });
    
    it(@"should consider a VENTransactionTarget not to be equal to something that is not a VENTransactionTarget", ^{
        NSString *notATarget = @"peter";
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"Peter" amount:100];
        
        expect(notATarget).notTo.equal(target);
        expect(target).notTo.equal(notATarget);
    });
    
    it(@"should consider two VENTransactionTargets with the same handle but different amounts different", ^{
        VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"Peter" amount:50];
        VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"Peter" amount:100];
        
        expect(target1).toNot.equal(target2);
    });
    
    it(@"should consider two VENTransactionTargets with different handles and the same amount different", ^{
        VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"Peter" amount:100];
        VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithHandle:@"Piotr" amount:100];
        
        expect(target1).toNot.equal(target2);
    });
    
    it(@"should consider two empty VENTransactionTargets equal", ^{
        VENTransactionTarget *target1 = [VENTransactionTarget new];
        VENTransactionTarget *target2 = [VENTransactionTarget new];
        
        expect(target2).to.equal(target1);
    });
    
    it(@"should consider two VENTransactionTargets with the same handle and no amount equal", ^{
        VENTransactionTarget *target1 = [VENTransactionTarget new];
        VENTransactionTarget *target2 = [VENTransactionTarget new];
        target1.handle = @"Peter";
        target2.handle = @"Peter";
        
        expect(target2).to.equal(target1);
    });
    
    it(@"should consider two VENTransactionTargets with the same amount and no handle equal", ^{
        VENTransactionTarget *target1 = [VENTransactionTarget new];
        VENTransactionTarget *target2 = [VENTransactionTarget new];
        target1.amount = 100;
        target2.amount = 100;

        expect(target1).to.equal(target2);
    });
    
});

describe(@"dictionaryRepresentation", ^{
    it(@"should correctly represent a VENTransactionTarget in dictionary form with target type phone", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"9177436332" amount:10];
        NSDictionary *dictionaryRepresentation = [target dictionaryRepresentation];
        NSString *targetType = dictionaryRepresentation[VENTransactionTargetTypeKey];
        
        expect(dictionaryRepresentation[VENTransactionAmountKey]).to.equal((float)target.amount/100);
        expect(targetType).to.equal(@"phone");
        expect(target.handle).to.equal(@"9177436332");
    });
    
    it(@"should correctly represent a VENTransactionTarget in dictionary form with target type email", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"peter.zakin@gmail.com" amount:10];
        NSDictionary *dictionaryRepresentation = [target dictionaryRepresentation];
        NSString *targetType = dictionaryRepresentation[VENTransactionTargetTypeKey];
        
        expect(dictionaryRepresentation[VENTransactionAmountKey]).to.equal((float)target.amount/100);
        expect(targetType).to.equal(@"email");
        expect(target.handle).to.equal(@"peter.zakin@gmail.com");
    });
    
    it(@"should correctly represent a VENTransactionTarget in dictionary form with target type userId", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"1271231231239" amount:10];
        NSDictionary *dictionaryRepresentation = [target dictionaryRepresentation];
        NSString *targetType = dictionaryRepresentation[VENTransactionTargetTypeKey];
        
        expect(dictionaryRepresentation[VENTransactionAmountKey]).to.equal((float)target.amount/100);
        expect(targetType).to.equal(VENTransactionTargetUserKey);
        expect(target.handle).to.equal(@"1271231231239");
    });
    
    it(@"should correctly initiate an identical VENTransactionTarget from its dictionary representation", ^{
        VENTransactionTarget *target1 = [[VENTransactionTarget alloc] initWithHandle:@"1231231231233" amount:12635];
        NSDictionary *dictionaryRepresentation = [target1 dictionaryRepresentation];

        VENTransactionTarget *target2 = [[VENTransactionTarget alloc] initWithDictionary:dictionaryRepresentation];
    
        expect(target1).to.equal(target2);
        assertTargetsAreFieldWiseEqual(target1, target2);
    });
});

SpecEnd