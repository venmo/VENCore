#import "VENTransactionTarget.h"
#import "VENCore.h"

@implementation VENTransactionTarget

#pragma mark - Class Methods

+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary {

    NSArray *requiredKeys = @[VENTransactionAmountKey, VENTransactionTargetTypeKey];

    for (NSString *key in requiredKeys) {
        if (!dictionary[key] || [dictionary[key] isKindOfClass:[NSNull class]]) {
            return NO;
        }
    }

    NSArray *validTargetTypes = @[VENTransactionTargetPhoneKey, VENTransactionTargetEmailKey, VENTransactionTargetUserKey];

    NSString *targetType = dictionary[VENTransactionTargetTypeKey];
    if (![validTargetTypes containsObject:targetType]) {
        return NO;
    }

    id amount = dictionary[VENTransactionAmountKey];

    if ([amount isKindOfClass:[NSString class]] && ![amount intValue]) {
        return NO;
    }
    else if ([amount respondsToSelector:@selector(doubleValue)]) {
        amount = @([amount doubleValue] * 100.);
    }
    else {
        return NO;
    }

    return YES;
}


#pragma mark - Public Instance Methods

- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSInteger)amount {
    if (amount < 0) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.handle = phoneEmailOrUserID;
        self.amount = amount;
        self.targetType = [phoneEmailOrUserID targetType];
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        NSDictionary *cleanDictionary = [dictionary dictionaryByCleansingResponseDictionary];

        NSString *targetType = cleanDictionary[VENTransactionTargetTypeKey];
        
        if ([targetType isEqualToString:VENTransactionTargetEmailKey]) {
            self.targetType = VENTargetTypeEmail;
        }
        else if ([targetType isEqualToString:VENTransactionTargetUserKey]) {
            self.targetType = VENTargetTypeUserId;
        }
        else if ([targetType isEqualToString:VENTransactionTargetPhoneKey]) {
            self.targetType = VENTargetTypePhone;
        }
        else {
            self.targetType = VENTargetTypeUnknown;
        }
        
        self.handle = cleanDictionary[targetType];
        self.amount = (NSUInteger)([cleanDictionary[VENTransactionAmountKey] doubleValue] * (double)100);
    }
    return self;
}


- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (self.handle) {
        //dictionary[VENTransactionTargetTypeKey] =
        VENTargetType targetType = [self.handle targetType];
        switch (targetType) {
            case VENTargetTypeEmail:
                dictionary[VENTransactionTargetTypeKey]  = VENTransactionTargetEmailKey;
                dictionary[VENTransactionTargetEmailKey] = self.handle;
                break;
            case VENTargetTypePhone:
                dictionary[VENTransactionTargetTypeKey]  = VENTransactionTargetPhoneKey;
                dictionary[VENTransactionTargetPhoneKey] = self.handle;
                break;
            case VENTargetTypeUserId:
                dictionary[VENTransactionTargetTypeKey]  = VENTransactionTargetUserKey;
                dictionary[VENTransactionTargetUserKey]  = self.handle;
                break;
            default:
                break;
        }
    }

    if (self.amount) {
        dictionary[VENTransactionAmountKey] = @((CGFloat)self.amount/100.);
    }
    
    return dictionary;
}


- (BOOL)isValid {
    BOOL hasValidHandle = [self.handle isUserId] || [self.handle isUSPhone] || [self.handle isEmail];
    return hasValidHandle && self.targetType != VENTargetTypeUnknown && self.amount > 0;
}


#pragma mark - Other Methods

- (void)setUser:(VENUser *)user {
    _user = user;
    self.handle = user.externalId;
    self.targetType = [self.handle targetType];
}


- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    VENTransactionTarget *otherTarget = (VENTransactionTarget *)object;
    
    if ((otherTarget.handle || self.handle) && ![otherTarget.handle isEqualToString:self.handle]) {
        return NO;
    }
    if (otherTarget.amount != self.amount) {
        return NO;
    }
    
    return YES;
}

@end
