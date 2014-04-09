#import "VENHTTPResponse.h"

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


- (NSString *)description {
    return [NSString stringWithFormat:@"<VENHTTPResponse statusCode:%d body:%@>", (int)self.statusCode, self.object];
}

@end
