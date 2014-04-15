#import "VENMutableTransaction+Internal.h"
#import "VENCore.h"
#import "VENHTTPResponse.h"
#import "NSDictionary+VENCore.h"

@interface VENMutableTransaction ()

@property (copy, nonatomic, readwrite) NSString *transactionID;
@property (copy, nonatomic, readwrite) NSString *fromUserID;
@property (copy, nonatomic, readwrite) NSString *toUserID;
@property (assign, nonatomic, readwrite) VENTransactionStatus status;

@end

@implementation VENMutableTransaction

@synthesize type = _type,
amount           = _amount,
note             = _note,
fromUserID       = _fromUserID,
transactionID    = _transactionID,
recipientType    = _recipientType,
toUserID         = _toUserID,
status           = _status,
audience         = _audience,
recipientHandle  = _recipientHandle;


+ (instancetype)transactionWithType:(VENTransactionType)type
                             amount:(NSUInteger)amount
                               note:(NSString *)note
                           audience:(VENTransactionAudience)audience
                      recipientType:(VENTargetType)recipientType
                    recipientString:(NSString *)recipientString {

    VENMutableTransaction *transaction = [[[self class] alloc] init];
    transaction.type                   = type;
    transaction.amount                 = amount;
    transaction.note                   = note;
    transaction.audience               = audience;
    transaction.recipientType          = recipientType;
    transaction.recipientHandle        = recipientString;
    transaction.status                 = VENTransactionStatusNotSent;

    return transaction;
}


- (instancetype)initWithTransactionID:(NSString *)transactionID
                                 type:(VENTransactionType)type
                               amount:(NSUInteger)amount
                                 note:(NSString *)note
                           fromUserID:(NSString *)fromUserID
                        recipientType:(VENTargetType)recipientType
                             toUserID:(NSString *)toUserID
                      recipientHandle:(NSString *)recipientHandle
                             audience:(VENTransactionAudience)audience {
    self = [super init];
    if (self) {
        self.transactionID = transactionID;
        self.type = type;
        self.amount = amount;
        self.note = note;
        self.fromUserID = fromUserID;
        self.recipientType = recipientType;
        self.toUserID = toUserID;
        self.recipientHandle = recipientHandle;
        self.audience = audience;
    }
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = VENTransactionStatusNotSent;
    }
    return self;
}


+ (instancetype)transactionWithType:(VENTransactionType)type
                             amount:(NSUInteger)amount
                               note:(NSString *)note
                           audience:(VENTransactionAudience)audience
                      recipientType:(VENRecipientType)recipientType
                    recipientString:(NSString *)recipientString {

    VENMutableTransaction *transaction = [[[self class] alloc] init];
    transaction.type                   = type;
    transaction.amount                 = amount;
    transaction.note                   = note;
    transaction.audience               = audience;
    transaction.recipientType          = recipientType;
    transaction.recipientHandle        = recipientString;
    transaction.status                 = VENTransactionStatusNotSent;

    return transaction;
}


- (void)sendWithSuccess:(void(^)(VENTransaction *transaction, VENHTTPResponse *response))success
                failure:(void(^)(VENHTTPResponse *reponse, NSError *error))failure {

    VENCore *defaultCore = [VENCore defaultCore];
    if (!defaultCore) {
        NSError *error = [NSError noDefaultCoreError];
        if (failure) {
            failure(nil, error);
        }
        return;
    }

    [defaultCore.httpClient POST:VENAPIPathPayments
                      parameters:[self parameters]
                         success:^(VENHTTPResponse *response) {
                             NSDictionary *data = [response.object objectOrNilForKey:@"data"];
                             NSDictionary *payment = [data objectOrNilForKey:@"payment"];
                             if (payment) {
//                                 VENTransaction *transaction = [VENTransaction transactionWithPaymentObject:payment];
                                 if (success) {
//                                     success(transaction, response);
                                 }
                             }
    } failure:^(VENHTTPResponse *response, NSError *error) {
        NSError *responseError;
        if ([response didError]){
            responseError = [response error];
        }
        if (failure) {
            failure(response, responseError ?: error);
        }
    }];
}


- (NSDictionary *)parameters {
    NSString *recipientTypeKey = [self recipientTypeString];
#warning Make this type-safe for nils
    NSDictionary *parameters;
    if ([self readyToSend]) {
        parameters = @{recipientTypeKey : self.recipientHandle,
                      @"note" : self.note,
                      @"amount" : self.type == VENTransactionTypePay ? [self amountString] : [NSString stringWithFormat:@"-%@", [self amountString]],
                      @"audience" : [self audienceString]};
    }
    return parameters;
}


- (NSString *)recipientTypeString {
    switch (self.recipientType) {
        case VENTargetTypeEmail:
            return @"email";
            break;

        case VENTargetTypePhone:
            return @"phone";
            break;

        case VENTargetTypeUserId:
            return @"user_id";
            break;
        default:
            return nil;
            break;
    }
    return nil;
}


- (BOOL)readyToSend {
    if (!self.recipientHandle) {
        return NO;
    }
    if (!self.note) {
        return NO;
    }
    if (![self audienceString]) {
        return NO;
    }
    return YES;
}


- (NSString *)audienceString {
    switch (self.audience) {
        case VENTransactionAudiencePrivate:
            return @"private";
            break;

        case VENTransactionAudienceFriends:
            return @"friends";
            break;

        case VENTransactionAudiencePublic:
            return @"public";
            break;

        default:
            break;
    }
}


- (NSString *)amountString {
    if (self.amount < 1) {
        return @"";
    }
    CGFloat amount = self.amount / 100.0f;
    NSString *amountStr = [NSString stringWithFormat:@"%.2f", amount];
    return amountStr;
}

@end
