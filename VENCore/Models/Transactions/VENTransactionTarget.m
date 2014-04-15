#import "VENTransactionTarget.h"
#import "NSString+VENCore.h"
#import "VENUser.h"

@implementation VENTransactionTarget

- (instancetype)initWithHandle:(NSString *)phoneEmailOrUserID amount:(NSUInteger)amount {
    self = [super init];
    if (self) {
        self.handle = phoneEmailOrUserID;
        self.targetType = [phoneEmailOrUserID targetType];
    }
    return self;
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

@end
