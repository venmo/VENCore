#import "VENTransactionTarget.h"
#import "NSString+VENCore.h"
#import "VENUser.h"
#import "VENTransactionPayloadKeys.h"
#import "NSDictionary+VENCore.h"

@implementation VENTransactionTarget

- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSUInteger)amount {
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


+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary {
    NSString *targetType = dictionary[VENTransactionTargetTypeKey];
    NSInteger amount = (NSUInteger)[dictionary[VENTransactionAmountKey] doubleValue] * (double)100;
    
    if (!targetType || !dictionary[targetType] || !amount) {
        return NO;
    }

    return YES;
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
        dictionary[VENTransactionAmountKey] = @((double)self.amount / (double)100);
    }
    
    return dictionary;
}

- (BOOL)isValid {
    BOOL hasValidHandle = [self.handle isUserId] || [self.handle isUserId] || [self.handle isEmail];
    return hasValidHandle && self.targetType != VENTargetTypeUnknown;
}


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
