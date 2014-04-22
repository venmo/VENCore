#import "NSString+VENCore.h"

SpecBegin(NSStringVENCore)

describe(@"isUSPhone", ^{
    it(@"should return YES if the testPhone is all numbers and 10 digits", ^{
        NSString *testPhone = @"2234567890";
        expect([testPhone isUSPhone]).to.equal(YES);
    });

    it(@"should return YES if the testPhone is all numbers and 11 digits", ^{
        NSString *testPhone = @"12234567890";
        expect([testPhone isUSPhone]).to.equal(YES);
    });

    it(@"should return NO if the testPhone is all numbers and > 11 digits", ^{
        NSString *testPhone = @"112234567890";
        expect([testPhone isUSPhone]).to.equal(NO);
    });

    it(@"should return NO if the testPhone is all numbers and < 10 digits", ^{
        NSString *testPhone = @"234567890";
        expect([testPhone isUSPhone]).to.equal(NO);
    });

    it(@"should return YES if the testPhone is valid and has hyphens and parentheses", ^{
        NSString *testPhone = @"(223)456-7890";
        expect([testPhone isUSPhone]).to.equal(YES);
    });

    it(@"should return NO if the testPhone is 10 digits and has letters", ^{
        NSString *testPhone = @"12222T67890";
        expect([testPhone isUSPhone]).to.equal(NO);
    });
});

describe(@"isEmail", ^{
    it(@"should return YES if the email has a handle@domain.tld", ^{
        NSString *testEmail = @"test@domain.com";
        expect([testEmail isEmail]).to.equal(YES);
    });

    it(@"should return NO if the email is not handle@domain.tld", ^{
        NSString *testEmail = @"test@domaincom";
        expect([testEmail isEmail]).to.equal(NO);

        testEmail = @"testdomain.com";
        expect([testEmail isEmail]).to.equal(NO);
    });
});

describe(@"isUserId", ^{
    it(@"should return YES if the value is all numbers and not a valid phone number", ^{
        NSString *userId = @"1234";
        expect([userId isUserId]).to.equal(YES);
    });

    it(@"should return NO if the value is all numbers and is a valid phone number", ^{
        NSString *userId = @"1234567890";
        expect([userId isUserId]).to.equal(NO);
    });

    it(@"should return NO if the value is not all numbers", ^{
        NSString *userId = @"1234T";
        expect([userId isUserId]).to.equal(NO);
    });
});

describe(@"targetType", ^{
    it(@"should return VENTargetTypePhone if the value is a phone number", ^{
        NSString *testPhone = @"(223)456-7890";
        expect([testPhone targetType]).to.equal(VENTargetTypePhone);
    });

    it(@"should return VENTargetTypeUserId if the value is a userID", ^{
        NSString *userId = @"1234";
        expect([userId targetType]).to.equal(VENTargetTypeUserId);
    });

    it(@"should return VENTargetTypeEmail if the value is an email address", ^{
        NSString *testEmail = @"test@domain.com";
        expect([testEmail targetType]).to.equal(VENTargetTypeEmail);
    });

    it(@"should return VENTargetTypeUnknown if the value is an email address", ^{
        NSString *testEmail = @"1234T";
        expect([testEmail targetType]).to.equal(VENTargetTypeUnknown);
    });
});

describe(@"hasContent", ^{
    it(@"should return YES if the value contains non-whitespace characters", ^{
        NSString *string = @"*";
        expect([string hasContent]).to.equal(YES);
    });
    it(@"should return YES if the value contains non-whitespace characters", ^{
        NSString *string = @" ";
        expect([string hasContent]).to.equal(NO);
    });
});
SpecEnd