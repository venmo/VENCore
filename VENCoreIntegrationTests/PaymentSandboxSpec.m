//
// To run these tests, you'll need to add a "config.plist" file to the VENCoreIntegrationTests target.
// This plist should contain an "access_token" key with your Venmo access token as the value.
//

SpecBegin(PaymentSandbox)

NSString *plistPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"config" ofType:@"plist"];
NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
NSString *accessToken = config[@"access_token"];

describe(@"Settled Payment", ^{

});

describe(@"Failed Payment", ^{

});

describe(@"Pending Payment", ^{

});

describe(@"Settled Charge", ^{

});

describe(@"Pending Charge", ^{

});


SpecEnd
