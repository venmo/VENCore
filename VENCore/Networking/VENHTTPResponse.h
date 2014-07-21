//
// VENHTTPResponse
// HTTP response wrapper.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

NSString *const VENErrorDomainHTTPResponse;

NS_ENUM(NSInteger, VEErrorCodeHTTPResponse) {
    VENErrorCodeHTTPResponseUnauthorizedRequest,
    VENErrorCodeHTTPResponseBadResponse,
    VENErrorCodeHTTPResponseInvalidObjectType
};

@interface VENHTTPResponse : NSObject

@property (nonatomic, readonly, strong) id object;
@property (nonatomic, readonly, assign) NSInteger statusCode;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseObject:(id)object;



/**
 * Returns YES if the response represents an error state.
 */
- (BOOL)didError;


/**
 * Returns an NSError object or nil if the response does not represent an error state.
 */
- (NSError *)error;

@end
