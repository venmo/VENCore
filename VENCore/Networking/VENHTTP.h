//
// VENHTTP
// Constructs and sends HTTP requests.
//

#import <Foundation/Foundation.h>

extern NSString *const VENPrivateAPIPathLogin;
extern NSString *const VENPublicAPIPathPayments;
extern NSString *const VENPublicAPIPathUsers;
extern NSString *const VENPrivateAPIPathUsers;

@class AFHTTPRequestOperationManager, AFHTTPRequestOperation, VENHTTPResponse;

@interface VENHTTP : NSObject

@property (strong, nonatomic, readonly) NSString *clientID;
@property (strong, nonatomic, readonly) NSString *clientSecret;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
                         baseURL:(NSURL *)baseURL;

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
completion:(void(^)(VENHTTPResponse *response, NSError *error))completionBlock;

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
completion:(void(^)(VENHTTPResponse *response, NSError *error))completionBlock;

- (VENHTTPResponse *)responseFromOperation:(AFHTTPRequestOperation *)operation;

- (void)setAccessToken:(NSString *)accessToken;

@end
