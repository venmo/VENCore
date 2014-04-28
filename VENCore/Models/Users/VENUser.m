#import "VENUser.h"
#import "VENCore.h"

@implementation VENUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        NSDictionary *cleanDictionary = [dictionary dictionaryByCleansingResponseDictionary];

        self.username       = cleanDictionary[VENUserKeyUsername];
        self.firstName      = cleanDictionary[VENUserKeyFirstName];
        self.lastName       = cleanDictionary[VENUserKeyLastName];
        self.displayName    = cleanDictionary[VENUserKeyDisplayName];
        self.about          = cleanDictionary[VENUserKeyAbout];
        self.primaryPhone   = cleanDictionary[VENUserKeyPhone];
        self.internalId     = cleanDictionary[VENUserKeyInternalId];
        self.externalId     = cleanDictionary[VENUserKeyExternalId];
        self.dateJoined     = cleanDictionary[VENUserKeyDateJoined];
        self.primaryEmail   = cleanDictionary[VENUserKeyEmail];
        self.profileImageUrl= cleanDictionary[VENUserKeyProfileImageUrl];
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone {

    VENUser *newUser        = [[[self class] alloc] init];

    newUser.username        = self.username;
    newUser.firstName       = self.firstName;
    newUser.lastName        = self.lastName;
    newUser.displayName     = self.displayName;
    newUser.about           = self.about;
    newUser.primaryPhone    = self.primaryPhone;
    newUser.primaryEmail    = self.primaryEmail;
    newUser.internalId      = self.internalId;
    newUser.externalId      = self.externalId;
    newUser.dateJoined      = self.dateJoined;
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


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ :: %@", [self class], [self dictionaryRepresentation]];
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

    if (self.primaryPhone) {
        dictionary[VENUserKeyPhone] = self.primaryPhone;
    }

    if (self.primaryEmail) {
        dictionary[VENUserKeyEmail] = self.primaryEmail;
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


+ (void)fetchUserWithExternalId:(NSString *)externalId
                        success:(VENUserFetchSuccessBlock)successBlock
                        failure:(VENUserFetchFailureBlock)failureBlock {
    
    if((![externalId isKindOfClass:[NSString class]] || ![externalId length]) && failureBlock) {
        NSError *error = [[NSError alloc] initWithDomain:VENErrorDomainCore
                                                    code:-999
                                                userInfo:@{}];
        failureBlock(error);
        return;
    }
    
    NSDictionary *parameters = @{};
    
    [[[VENCore defaultCore] httpClient] GET:[NSString stringWithFormat:@"users/%@", externalId]
                                 parameters:parameters
                                    success:^(VENHTTPResponse *response) {
                                        
                                        NSDictionary *userPayload = [NSDictionary dictionaryWithDictionary:response.object[@"data"]];
                                        
                                        if ([self canInitWithDictionary:userPayload] && successBlock) {
                                            VENUser *user = [[VENUser alloc] initWithDictionary:userPayload];
                                            successBlock(user);
                                        }
                                        else if (failureBlock) {
                                            failureBlock(response.error);
                                        }
                                    }
                                    failure:^(VENHTTPResponse *response, NSError *error) {
                                        
                                        if ([response error]) {
                                            error = [response error];
                                        }

                                        if (failureBlock) {
                                            failureBlock(error);
                                        }
                                    }];
}

@end
