#import "VENUser.h"
#import "VENMutableUser.h"
#import "VENHTTP.h"
#import "NSDictionary+VENCore.h"
#import "VENUserPayloadKeys.h"

@interface VENUser ()

@property (copy, nonatomic, readwrite) NSString *username;
@property (copy, nonatomic, readwrite) NSString *firstName;
@property (copy, nonatomic, readwrite) NSString *lastName;
@property (copy, nonatomic, readwrite) NSString *displayName;
@property (copy, nonatomic, readwrite) NSString *about;
@property (copy, nonatomic, readwrite) NSString *phone;
@property (copy, nonatomic, readwrite) NSString *profileImageUrl;
@property (copy, nonatomic, readwrite) NSString *email;
@property (copy, nonatomic, readwrite) NSString *internalId;
@property (copy, nonatomic, readwrite) NSString *externalId;
@property (strong, nonatomic, readwrite) NSDate *dateJoined;

@end

@implementation VENUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        NSDictionary *cleanDictionary = [dictionary dictionaryByRemovingAllNullObjects];

        self.username       = cleanDictionary[VENUserKeyUsername];
        self.firstName      = cleanDictionary[VENUserKeyFirstName];
        self.lastName       = cleanDictionary[VENUserKeyLastName];
        self.displayName    = cleanDictionary[VENUserKeyDisplayName];
        self.about          = cleanDictionary[VENUserKeyAbout];
        self.phone          = cleanDictionary[VENUserKeyPhone];
        self.internalId     = cleanDictionary[VENUserKeyInternalId];
        self.externalId     = cleanDictionary[VENUserKeyExternalId];
        self.dateJoined     = cleanDictionary[VENUserKeyDateJoined];
        self.email          = cleanDictionary[VENUserKeyEmail];
        self.profileImageUrl = cleanDictionary[VENUserKeyProfileImageUrl];
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone {

    VENUser *newUser    = [[VENUser alloc] init];

    newUser.username    = self.username;
    newUser.firstName   = self.firstName;
    newUser.lastName    = self.lastName;
    newUser.displayName = self.displayName;
    newUser.about       = self.about;
    newUser.phone       = self.phone;
    newUser.email       = self.email;
    newUser.internalId  = self.internalId;
    newUser.externalId  = self.externalId;
    newUser.dateJoined  = self.dateJoined;
    newUser.profileImageUrl = self.profileImageUrl;

    return newUser;
}


- (id)mutableCopy {

    VENMutableUser *newUser = [[VENMutableUser alloc] init];

    newUser.username    = self.username;
    newUser.firstName   = self.firstName;
    newUser.lastName    = self.lastName;
    newUser.displayName = self.displayName;
    newUser.about       = self.about;
    newUser.phone       = self.phone;
    newUser.email       = self.email;
    newUser.internalId  = self.internalId;
    newUser.externalId  = self.externalId;
    newUser.dateJoined  = self.dateJoined;
    newUser.profileImageUrl = self.profileImageUrl;

    return newUser;
}


- (BOOL)isEqual:(id)object {

    if ([object class] != [self class]) {
        return NO;
    }
    VENUser *comparisonUser = (VENUser *)object;

    return [self.externalId isEqualToString:comparisonUser.externalId];
}


+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return NO;
    }

    NSArray *requiredKeys = @[VENUserKeyExternalId, VENUserKeyUsername];

    for (NSString *key in requiredKeys) {
        if (!dictionary[key] || [dictionary[key] isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}


- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    if (self.username) {
        dictionary[VENUserKeyUsername] = self.username;
    }

    if (self.firstName) {
        dictionary[VENUserKeyFirstName] = self.firstName;
    }

    if (self.lastName) {
        dictionary[VENUserKeyLastName] = self.lastName;
    }

    if (self.displayName) {
        dictionary[VENUserKeyDisplayName] = self.displayName;
    }

    if (self.about) {
        dictionary[VENUserKeyAbout] = self.about;
    }

    if (self.phone) {
        dictionary[VENUserKeyPhone] = self.phone;
    }

    if (self.email) {
        dictionary[VENUserKeyEmail] = self.email;
    }

    if (self.internalId) {
        dictionary[VENUserKeyInternalId] = self.internalId;
    }

    if (self.externalId) {
        dictionary[VENUserKeyExternalId] = self.externalId;
    }

    if (self.profileImageUrl) {
        dictionary[VENUserKeyProfileImageUrl] = self.profileImageUrl;
    }

    if (self.dateJoined) {
        dictionary[VENUserKeyDateJoined] = self.dateJoined;
    }

    return dictionary;
}


@end
