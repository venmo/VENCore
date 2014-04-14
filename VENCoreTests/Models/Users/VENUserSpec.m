#import "VENUser.h"
#import "VENMutableUser.h"
#import "VENUserPayloadKeys.h"

SpecBegin(VENUser)

NSDictionary *validUserDictionary1 = @{VENUserKeyUsername: @"PeterIsAZakin",
                                       VENUserKeyInternalId: @"234234",
                                       VENUserKeyExternalId: @"JLHDSJFIOHh23ioHLH",
                                       VENUserKeyFirstName: @"Peter",
                                       VENUserKeyLastName: @"Maddern",
                                       VENUserKeyAbout: @"Happily married!"};

NSDictionary *validUserDictionary2 = @{VENUserKeyUsername: @"PetefadsrIsAZakin",
                                       VENUserKeyInternalId: @"234223434",
                                       VENUserKeyExternalId: @"JLHDSfadJfsdFIOHh23ioHLH",
                                       VENUserKeyFirstName: @"Pefadster",
                                       VENUserKeyLastName: @"Mafadsddern",
                                       VENUserKeyAbout: @"Happifasdly married!"};

NSDictionary *invalidUserDictionary1 = @{VENUserKeyInternalId: @"234234",
                                         VENUserKeyExternalId: @"JLHDSJFIOHh23ioHLH",
                                         VENUserKeyFirstName: @"Peter",
                                         VENUserKeyLastName: @"Maddern",
                                         VENUserKeyAbout: @"Happily married!"};

// This does not contain the external ID
NSDictionary *invalidUserDictionary2 = @{VENUserKeyUsername: @"PeterIsAZakin",
                                         VENUserKeyFirstName: @"Peter",
                                         VENUserKeyLastName: @"Maddern",
                                         VENUserKeyAbout: @"Happily married!"};


void(^assertUsersAreFieldwiseEqual)(VENUser *, VENUser *) = ^(VENUser *user1, VENUser *user2) {
    expect(user1.username).to.equal(user2.username);
    expect(user1.firstName).to.equal(user2.firstName);
    expect(user1.lastName).to.equal(user2.lastName);
    expect(user1.displayName).to.equal(user2.displayName);
    expect(user1.about).to.equal(user2.about);
    expect(user1.phone).to.equal(user2.phone);
    expect(user1.email).to.equal(user2.email);
    expect(user1.internalId).to.equal(user2.internalId);
    expect(user1.externalId).to.equal(user2.externalId);
    expect(user1.dateJoined).to.equal(user2.dateJoined);
    expect(user1.profileImageUrl).to.equal(user2.profileImageUrl);
};


describe(@"Initialization", ^{

    it(@"should succesfully create an empty object from init", ^{
        VENUser *usr = [[VENUser alloc] init];
        expect(usr).toNot.beNil();

        expect(usr.username).to.beNil();
        expect(usr.firstName).to.beNil();
        expect(usr.lastName).to.beNil();
        expect(usr.profileImageUrl).to.beNil();

    });

    it(@"should return NO to canInitWithDictionary for an invalid dictionary", ^{
        BOOL canInit = [VENUser canInitWithDictionary:invalidUserDictionary1];
        expect(canInit).to.beFalsy();

        canInit = [VENUser canInitWithDictionary:invalidUserDictionary2];
        expect(canInit).to.beFalsy();
    });

    it(@"should return YES to canInitWithDictionary for a valid dictionary", ^{
        BOOL canInit = [VENUser canInitWithDictionary:validUserDictionary1];
        expect(canInit).to.beTruthy();
    });
});


describe(@"Copying", ^{

    it(@"should create a valid copy of any empty object", ^{
        VENUser *usr = [[VENUser alloc] init];

        VENUser *myOtherUser = [usr copy];

        expect(myOtherUser).notTo.beNil();
        expect(myOtherUser).to.beKindOf([usr class]);

    });

    it(@"should create a valid copy of a valid user", ^{
        VENUser *user = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENUser *newUser = [user copy];

        expect(user).to.equal(newUser);
    });


    it(@"should create a mutable copy of a valid user", ^{
        VENUser *user = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENMutableUser *mutableUser = [user mutableCopy];

        assertUsersAreFieldwiseEqual(user, mutableUser);
    });

    it (@"should create a mutable copy of an invalid user", ^{
        VENUser *user = [[VENUser alloc] initWithDictionary:invalidUserDictionary1];
        VENMutableUser *mutableUser = [user mutableCopy];

        assertUsersAreFieldwiseEqual(user, mutableUser);
    });

});


describe(@"Equality", ^{

    it(@"should correctly validate two equal objects", ^{

        VENUser *user1 = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENUser *user2 = [user1 copy];

        expect([user1 isEqual:user2]).to.beTruthy();

    });

    it(@"should not indicate that two different users are the same", ^{
        VENUser *user1 = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENUser *user2 = [[VENUser alloc] initWithDictionary:validUserDictionary2];

        expect([user1 isEqual:user2]).to.beFalsy();
    });

    it(@"should behave transitively", ^{
        VENUser *user1 = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENUser *user2 = [[VENUser alloc] initWithDictionary:validUserDictionary2];

        expect([user1 isEqual:user2]).to.beFalsy();
        expect([user2 isEqual:user1]).to.beFalsy();

        user1 = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        user2 = [user1 copy];

        expect([user1 isEqual:user2]).to.beTruthy();
        expect([user2 isEqual:user1]).to.beTruthy();

    });

    it(@"should follow the rule that two users are equal ONLY if their external Ids are the same", ^{
        VENUser *user = [[VENUser alloc] init];
        VENUser *myOtherUser = [user copy];

        expect(user).toNot.equal(myOtherUser);

        VENUser *invalidUser = [[VENUser alloc] initWithDictionary:invalidUserDictionary2];
        VENUser *copiedInvalidUser = [invalidUser copy];
        
        expect(invalidUser).toNot.equal(copiedInvalidUser);
        
    });

    it(@"should not consider mutable and immutable objects with the same external id to be the same", ^{
        VENUser *user = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        VENMutableUser *mutableUser = [user mutableCopy];

        expect([user isEqual:mutableUser]).to.beFalsy();
        expect([mutableUser isEqual:user]).to.beFalsy();
    });
});

describe(@"Dictionary Representation", ^{
    it(@"should consider dictionary representations of equal users to be equal", ^{
        VENUser *user1 = [[VENUser alloc] initWithDictionary:validUserDictionary1];
        NSDictionary *user1Dictionary = [user1 dictionaryRepresentation];

        VENUser *user2 = [[VENUser alloc] initWithDictionary:user1Dictionary];
        expect([user1 isEqual:user2]).to.beTruthy();
        assertUsersAreFieldwiseEqual(user1, user2);

    });

});



SpecEnd