#import "VENHTTPResponse.h"
#import "NSError+VENCore.h"
#import "NSDictionary+VENCore.h"

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface VENHTTPResponse ()

@property (nonatomic, readwrite, strong) NSDictionary *object;
@property (nonatomic, readwrite, assign) NSInteger statusCode;

@end

@implementation VENHTTPResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)object {
    self = [self init];
    if (self) {
        self.statusCode = statusCode;
        self.object = object;
    }
    return self;
}


- (instancetype)initWithOperation:(AFHTTPRequestOperation *)operation {
    return [[VENHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseObject:operation.responseObject];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<VENHTTPResponse statusCode:%d body:%@>", (int)self.statusCode, self.object];
}


- (BOOL)didError {
    return self.statusCode > 299;
}


- (NSError *)error {
    if (![self didError]) {
        return nil;
    }

    NSDictionary *errorObject = [self.object objectOrNilForKey:@"error"];
    NSString *message = [errorObject stringForKey:@"message"];
    NSError *error;
    if (message) {
        NSInteger code = [[errorObject objectOrNilForKey:@"code"] integerValue];
        error = [NSError errorWithCode:code description:message recoverySuggestion:nil];
    }

    return error;
}

@end
