//
// VENHTTPResponse
// HTTP response wrapper.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

NSString *const VENErrorDomainHTTPResponse;

NS_ENUM(NSInteger, VEErrorCodeHTTPResponse) {
    VENErrorCodeHTTPResponseUnauthorizedRequest,
    VENErrorCodeHTTPResponseBadResponse
};

@interface VENHTTPResponse : NSObject

@property (nonatomic, readonly, strong) NSDictionary *object;
@property (nonatomic, readonly, assign) NSInteger statusCode;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(NSDictionary *)object;


/**
 * Initializes a response object with an AFHTTPRequestOperation.
 */
- (instancetype)initWithOperation:(AFHTTPRequestOperation *)operation;


/**
 * Returns YES if the response represents an error state.
 */
- (BOOL)didError;


/**
 * Returns an NSError object or nil if the response does not represent an error state.
 */
- (NSError *)error;

@end
