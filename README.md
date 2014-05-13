VENCore [![Build Status](https://travis-ci.org/venmo/VENCore.svg?branch=v1.0.0)](https://travis-ci.org/venmo/VENCore) 
=======

VENCore is the core Objective-C client library for the Venmo API. If you're looking for a simple way to send Venmo payments & charges from your iOS app, you should use the [Venmo iOS SDK](https://github.com/venmo/venmo-ios-sdk).

## Usage

### Initialization
```objective-c
// Create a VENCore instance
VENCore *core = [[VENCore alloc] init];

// Give it an access token
[core setAccessToken:accessToken];

// Set the default core
[VENCore setDefaultCore:core];
```

### Sending a transaction
```objective-c
// Create a request
VENCreateTransactionRequest *transactionService = [[VENCreateTransactionRequest alloc] init];

// Add a note
transactionService.note = @"hi";

// Add a target
VENTransactionTarget *target = [[VENTransactionTarget alloc] initWithHandle:@"name@example.com" amount:30];
[transactionService addTransactionTarget:target];

// Send the request
[transactionService sendWithSuccess:^(NSArray *sentTransactions, VENHTTPResponse *response) {
    // :)
} failure:^(NSArray *sentTransactions, VENHTTPResponse *response, NSError *error) {
    // :(
}];
```

