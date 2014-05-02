//
// VENHTTP
// Constructs and sends HTTP requests.
//

#import <Foundation/Foundation.h>

extern NSString *const VENAPIPathPayments;
extern NSString *const VENAPIPathUsers;

@class AFHTTPRequestOperationManager, AFHTTPRequestOperation, VENHTTPResponse;

@interface VENHTTP : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

- (instancetype)initWithBaseURL:(NSURL *)baseURL;

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
    failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
     failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
    failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters
     success:(void(^)(VENHTTPResponse *response))successBlock
     failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)setAccessToken:(NSString *)accessToken;

- (NSDictionary *)defaultHeaders;;

@end
