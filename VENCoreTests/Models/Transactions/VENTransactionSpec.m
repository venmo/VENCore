#import "VENTransaction+Internal.h"
#import "VENMutableTransaction.h"
#import "VENTestUtilities.h"

VENTransaction *transaction;

SpecBegin(VENTransaction)

before(^{
    NSDictionary *paymentResponse = [VENTestUtilities objectFromJSONResource:@"paymentToEmail"];
    NSDictionary *paymentObject = paymentResponse[@"data"][@"payment"];
    transaction = [VENTransaction transactionWithPaymentObject:paymentObject];
});



SpecEnd