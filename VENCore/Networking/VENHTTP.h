//
// VENHTTP
// Constructs and sends HTTP requests.
//

#import <Foundation/Foundation.h>

#warning These should not be in VENHTTP?
extern NSString *const VENPrivateAPIPathLogin;
extern NSString *const VENAPIPathPayments;
extern NSString *const VENAPIPathUsers;

@class AFHTTPRequestOperationManager, AFHTTPRequestOperation, VENHTTPResponse;

@interface VENHTTP : NSObject

@property (strong, nonatomic, readonly) NSString *clientID;
@property (strong, nonatomic, readonly) NSString *clientSecret;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
                         baseURL:(NSURL *)baseURL;

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
    failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void(^)(VENHTTPResponse *response))successBlock
     failure:(void(^)(VENHTTPResponse *response, NSError *error))failureBlock;

- (void)setAccessToken:(NSString *)accessToken;

- (NSDictionary *)defaultHeaders;;

@end
