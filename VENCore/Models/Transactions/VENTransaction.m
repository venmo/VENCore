#import "VENTransaction.h"
#import "VENCore.h"

NSString *const VENErrorDomainTransaction = @"com.venmo.VENCore.ErrorDomain.VENTransaction";
NSString *const VENTransactionTypeStrings[] = {@"unknown", @"pay", @"charge"};
NSString *const VENTransactionStatusStrings[] = {@"not_sent", @"pending", @"settled", @"failed"};
NSString *const VENTransactionAudienceStrings[] = {@"default", @"private", @"friends", @"public"};

@interface VENTransaction ()

@property (copy, nonatomic, readwrite) NSString *transactionID;
@property (strong, nonatomic, readwrite) VENTransactionTarget *target;
@property (copy, nonatomic, readwrite) NSString *note;
@property (copy, nonatomic, readwrite) VENUser *actor;
@property (assign, nonatomic, readwrite) VENTransactionType transactionType;
@property (assign, nonatomic, readwrite) VENTransactionStatus status;
@property (assign, nonatomic, readwrite) VENTransactionAudience audience;

@end

@implementation VENTransaction

#pragma mark - Class Methods

+ (BOOL)canInitWithDictionary:(NSDictionary *)dictionary {
    NSArray *requiredKeys = @[VENTransactionAmountKey, VENTransactionNoteKey, VENTransactionActorKey, VENTransactionIDKey, VENTransactionTargetKey];
    for (NSString *key in requiredKeys) {
        if (!dictionary[key] || [dictionary[key] isKindOfClass:[NSNull class]]
            || ([dictionary[key] respondsToSelector:@selector(isEqualToString:)]
                && [dictionary[key] isEqualToString:@""])) {
                return NO;
            }
    }
    return YES;
}

#pragma mark - Public Instance Methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    
    if (self) {
        if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        NSDictionary *cleanDictionary = [dictionary dictionaryByCleansingResponseDictionary];
        
        // Main Transaction Body
        self.transactionID      = cleanDictionary[VENTransactionIDKey];
        self.note               = cleanDictionary[VENTransactionNoteKey];
        
        NSString *transactionType       = cleanDictionary[VENTransactionTypeKey];
        NSString *transactionStatus     = cleanDictionary[VENTransactionStatusKey];
        NSString *transactionAudience   = cleanDictionary[VENTransactionAudienceKey];
        

        // Set transaction type enumeration
        if ([transactionType isEqualToString:VENTransactionTypeStrings[VENTransactionTypeCharge]]) {
            self.transactionType = VENTransactionTypeCharge;
        }
        else if ([transactionType isEqualToString:VENTransactionTypeStrings[VENTransactionTypePay]]) {
            self.transactionType = VENTransactionTypePay;
        }
        else {
            self.transactionType = VENTransactionTypeUnknown;
        }
        
        
        // Set status enumeration
        if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusPending]]) {
            self.status = VENTransactionStatusPending;
        }
        else if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusSettled]]) {
            self.status = VENTransactionStatusSettled;
        }
        else if ([transactionStatus isEqualToString:VENTransactionStatusStrings[VENTransactionStatusFailed]]) {
            self.status = VENTransactionStatusFailed;
        }
        else {
            self.status = VENTransactionStatusUnknown;
        }
        
        
        // Set audience enumeration
        if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudiencePublic]]) {
            self.audience = VENTransactionAudiencePublic;
        }
        else if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudienceFriends]]) {
            self.audience = VENTransactionAudienceFriends;
        }
        else if ([transactionAudience isEqualToString:VENTransactionAudienceStrings[VENTransactionAudiencePrivate]]) {
            self.audience = VENTransactionAudiencePrivate;
        }
        else {
            self.audience = VENTransactionAudiencePrivate;
        }
        
        
        // Set up VENUser actor
        NSDictionary *userDictionary = cleanDictionary[VENTransactionActorKey];
        if ([VENUser canInitWithDictionary:userDictionary]) {
            VENUser *user = [[VENUser alloc] initWithDictionary:userDictionary];
            self.actor = user;
        }
        
        
        // Set up VENTransactionTargets
        NSMutableDictionary *targetDictionary = [cleanDictionary[VENTransactionTargetKey] mutableCopy];
        if (cleanDictionary[VENTransactionAmountKey]) {
            targetDictionary[VENTransactionAmountKey] = cleanDictionary[VENTransactionAmountKey];
        }
        if ([VENTransactionTarget canInitWithDictionary:targetDictionary]) {
            VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithDictionary:targetDictionary];
            self.target = target;
        }
    }
    return self;
}


#pragma mark - Private Instance Methods

- (BOOL)isEqual:(id)object {
    VENTransaction *otherObject = (VENTransaction *)object;

    if (![otherObject.transactionID isEqualToString:self.transactionID]
        || otherObject.transactionType != self.transactionType) {
        return NO;
    }

    return YES;
}

@end
