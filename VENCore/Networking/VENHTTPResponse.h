//
// VENHTTPResponse
// HTTP response wrapper.
//

#import <Foundation/Foundation.h>

@interface VENHTTPResponse : NSObject

@property (nonatomic, readonly, strong) NSDictionary *object;
@property (nonatomic, readonly, assign) NSInteger statusCode;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)object;

@end
