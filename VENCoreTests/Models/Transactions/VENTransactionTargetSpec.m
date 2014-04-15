#import "VENTransactionTarget.h"

SpecBegin(VENTransactionTarget)

describe(@"initWithHandle:amount:", ^{
    it(@"setting the handle to an email should set the type to email", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"ben@venmo.com" amount:100];
        target.type = VENTargetTypeEmail;
    });
    it(@"setting the handle to a phone number should set the type to phone", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"2125007000" amount:100];
        target.type = VENTargetTypePhone;
    });
    it(@"setting the handle to a userID should set the type to userID", ^{
        VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"1234567" amount:100];
        target.type = VENTargetTypeUserID;
    });
});

SpecEnd