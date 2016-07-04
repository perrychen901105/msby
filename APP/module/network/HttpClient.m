
#import "SystemMacro.h"
#import "HttpClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "Constant.h"
#import "SBJson.h"
#import "NSString+MD5HexDigest.h"
#import "MBProgressHUD.h"
#import "QWFileManager.h"
#import "QWGlobalManager.h"
#import "SVProgressHUD.h"

#import "uploadFile.h"
@interface HttpException()
@end

@implementation HttpException
{
    
}
@end

@interface HttpClient()<QWLoadingDelegate>
{
//    MBProgressHUD *HUD;
}
@property (nonatomic, readwrite) NSString * baseUrl;
@property (nonatomic, readwrite) NSString * cookie;
@property (nonatomic, strong, readwrite) AFHTTPRequestOperationManager * http;
@property (nonatomic,assign)BOOL   touchCancle;
@end

@implementation HttpClient

+ (instancetype)sharedInstance {
    static HttpClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HttpClient alloc]init];
        _sharedInstance.baseUrl = [[NSString alloc] init];
        _sharedInstance.cookie = [[NSString alloc] init];
    });
  
    return _sharedInstance;
}

-(id)init
{
    if (self == [super init]) {
        self.progressEnabled=YES;
        _touchCancle = YES;
        [QWLoading instanceWithDelegate:self];
        
        return self;
    }
    return nil;
}

- (void)dealloc
{
    self.cookie = nil;
    self.baseUrl = nil;
    [QWLoading instanceWithDelegate:nil];
}

- (NSDictionary *)secretBuild:(NSDictionary *)dataSource
{
    NSMutableDictionary *build = [dataSource mutableCopy];
    if(build == nil) {
        build = [NSMutableDictionary dictionary];
    }
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeZone *localTime = [NSTimeZone localTimeZone];
//    DDLogVerbose(@"localTime:%@",localTime);
    //和格林尼治时间差
    NSInteger timeOff = [localTime secondsFromGMT];
    //视察转化
    if(build[@"timestamp"] == nil) {
        NSNumber *offset = [QWUserDefault getNumberBy:SERVER_TIME];
        if(offset && ![offset isEqualToNumber:[NSNumber numberWithLong:0]]) {
            //把当前系统时间加上之前计算的差值,纠正本地时间和服务保持同步
            NSTimeInterval current = [[NSDate date] timeIntervalSince1970] * 1000ll;
            long long rightTime = current + [offset longLongValue];
            [build setValue:[NSString stringWithFormat:@"%lld",rightTime] forKey:@"timestamp"];
        }else{
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970]*1000;
            NSString *timeString = [NSString stringWithFormat:@"%lld", (long long)a];
            [build setValue:timeString forKey:@"timestamp"];
        }
    }
    build[@"version"] = APP_VERSION;
    build[@"deviceType"] = @"2";
    build[@"deviceCode"] = DEVICE_ID;
    build[@"token"] = QWGLOBALMANAGER.configure.userToken;
    build[@"pushDeviceCode"] = QWGLOBALMANAGER.deviceToken;
    //渠道统计,作区分
    build[@"buildChannel"] = @"AppStore";
    
    MapInfoModel *mapInfoModel = [QWUserDefault getModelBy:APP_MAPINFOMODEL];
    if(mapInfoModel)
    {
        if(mapInfoModel.city) {
            build[@"_cityName"] = mapInfoModel.city;
        }
        if(mapInfoModel.location) {
            build[@"lng"] = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.longitude];
            build[@"lat"] = [NSString stringWithFormat:@"%f",mapInfoModel.location.coordinate.latitude];
        }
    }
    
    NSArray *keys = [build allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *sign = [NSMutableString string];
    for(NSString *key in sortedArray)
    {
        [sign appendString:key];
        if([build[key] isKindOfClass:[NSArray class]] || [build[key] isKindOfClass:[NSMutableArray class]])
        {
            NSArray *array = build[key];
            [sign appendString:[array JSONRepresentation]];
        }else{
            [sign appendString:[NSString stringWithFormat:@"%@",build[key]]];
        }
    }
    sign = [NSMutableString stringWithFormat:@"%@%@%@",@"quanwei",sign,@"quanwei"];
    build[@"sign"] = [sign md5HexDigest];
    
    return build;
}

- (void)process
{
    if (_http) {
        
        _http = nil;
    }
    _http = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:_baseUrl]];
    [_http.requestSerializer setValue:_cookie forHTTPHeaderField:@"Cookie"];
    _http.requestSerializer = [AFJSONRequestSerializer serializer];
    _http.responseSerializer = [AFJSONResponseSerializer serializer];
    _http.responseSerializer.acceptableContentTypes = [_http.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    [_http.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_http.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    _http.securityPolicy = securityPolicy;
}

- (void)setBaseUrl:(NSString *)baseUrl
{
    _baseUrl = baseUrl;
    
    [self process];
}

- (void)setCookie:(NSString *)cookie
{
    _cookie = cookie;

    [self process];
}
- (void)myTask {
    // Do something usefull in here instead of sleeping ...
    sleep(3);
}
- (void)requestWithPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method progressEnabled:(BOOL)pEnabled success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    if (pEnabled) {
        [[QWLoading instance] showLoading];
//        DebugLog(@"\n////////////////// %@: %@",method,path);
    }
//     DDLogVerbose(@"##### the path is: %@. paras is %@",path, params);
    NSMutableURLRequest *request = nil;
    NSData *postData = nil;
    if([method isEqualToString:@"GET"])
    {
        request = [self.http.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString] parameters:params error:nil];
              [request setTimeoutInterval:30.0f];
    }
    else
    {
        request = [self.http.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString] parameters:nil error:nil];
        
        [request setTimeoutInterval:30.0f];
        
        //拼接
        NSString* putValue = @"";
        for (NSString *key in params) {
            putValue = [NSString stringWithFormat:@"%@=%@&%@",key, [self escape:[NSString stringWithFormat:@"%@",params[key]]],putValue];
        }
        
        //转％号
        //NSString* bStr = [self escape:putValue];

        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //sethttpbody
        [request setHTTPBody:[putValue dataUsingEncoding:NSUTF8StringEncoding]];
        postData = [putValue dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    //// success block
    void (^responseSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        DDLogVerbose(@"allHeaderFields===>%@",operation.response.allHeaderFields);
//        DDLogVerbose(@"MIMEType=====>%@",operation.response.MIMEType);
        NSDictionary *fields= [operation.response allHeaderFields];
        NSArray *cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:[NSURL URLWithString:_baseUrl]];
        NSDictionary* requestFields=[NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        if([requestFields objectForKey:@"Cookie"]){
            // Cookie  code
        }
        if (responseObject == nil) {
            if (failure) {  
                failure(nil);
            }
        }
        else if ([[responseObject objectForKey:@"result" ]isEqualToString:@"FAIL"]) {
            HttpException *qwError = [[HttpException alloc] init];
            qwError.errorCode = [[responseObject objectForKey:@"errorCode" ]integerValue];
            qwError.Edescription =[responseObject objectForKey:@"errorDescription"];
            qwError.UUID = operation.UUID;
            if (failure) {
                failure(qwError);
            }
            
        }
        else
        {
            NSMutableDictionary *bodyDict = [responseObject objectForKey:@"body"];
            if(bodyDict && [bodyDict isKindOfClass:[NSDictionary class]] && bodyDict[@"apiStatus"] && [bodyDict[@"apiStatus"] integerValue] == 1001003) {
                if(!QWGLOBALMANAGER.isKickOff) {
                    [QWGLOBALMANAGER postNotif:NotifKickOff data:nil object:nil];
                    QWGLOBALMANAGER.isKickOff = YES;
                }
            }
            
            if (success) {
                if ([[responseObject objectForKey:@"result" ] isEqualToString:@"OK"]) {
                    NSMutableDictionary *bodyDict = [[responseObject objectForKey:@"body"] mutableCopy];
                    
                    if(operation.UUID)
                    {
                        bodyDict[@"UUID"] = operation.UUID;
                    }
                    success(bodyDict);
                }
            }
        }
        

        if (pEnabled) [[QWLoading instance] removeLoading];//[HUD hide:YES];
    };
    
    /// failure block
    void (^failureResponse)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSInteger code = operation.response.statusCode;
            //DebugLog(@"code ===>%ld",(long)code);
        
        HttpException * e = [HttpException new];
        e.UUID = operation.UUID;
        e.errorCode = code;
        DDLogError(@"%@ %@",[e description],[error description]);
//        if (code == 200) {
//            if (success) {
//                if ([[responseObject objectForKey:@"result" ] isEqualToString:@"OK"]) {
//                    NSMutableDictionary *bodyDict = [[responseObject objectForKey:@"body"] mutableCopy];
//                    if(operation.UUID)
//                    {
//                        bodyDict[@"UUID"] = operation.UUID;
//                    }
//                    success(bodyDict);
//                }
//            }
//        }
//        e.description = error.description;
        if (error.code == -1001) {
            e.errorCode = -1001;
        }
        else  if (error.code == -999) {
              e.errorCode = -999;
        }
      else   if (code == 401) {
     
        }else if (code == 400){
 
        }else if (code == 500){
   
        }else{
  
        }
        
        if (failure) {
            failure(e);
        }
        //暂时注释掉 －－jxb
        if (pEnabled) [[QWLoading instance] removeLoading];//[HUD hide:YES];
    };

    AFHTTPRequestOperation *operation = [self.http HTTPRequestOperationWithRequest:request success:responseSuccess failure:failureResponse];
    operation.postData = postData;
    if(params[@"UUID"]) {
        operation.UUID = params[@"UUID"];
    }
    [self.http.operationQueue addOperation:operation];
}

-(NSString *)escape:(NSString *)text
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)text,
                                                                                 NULL,
                                                                                 CFSTR("!*’();:@&=+$,/?%#[]"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

-(void)cancleLastRequest
{
    AFHTTPRequestOperation *current =  [self.http.operationQueue.operations lastObject] ;
    [current cancel];

    current = nil;
    
}
-(void)cancleAllRequest
{
     [self.http.operationQueue cancelAllOperations];
}

- (void)getWithNoPreFix:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    params = [self secretBuild:params];
    [self requestWithPath:url params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
    //    [self get:url params:params progressEnabled:YES success:success failure:failure];
}

- (void)CutomGet:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    self.progressEnabled=false;
    params = [self secretBuild:params];
    [self requestWithPath:[self CutomUrlWithPath:url] params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}

- (void)CutomTwiceGet:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    self.progressEnabled=false;
    params = [self secretBuild:params];
    [self requestWithPath:[self CutomUrlTwiceWithPath:url] params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}

- (void)getWithSecretWithUrl:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    [self requestWithPath:[self urlWithPath:url] params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
}

- (void)get:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    params = [self secretBuild:params];
    [self requestWithPath:[self urlWithPath:url] params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
//    [self get:url params:params progressEnabled:YES success:success failure:failure];
}

- (void)getRaw:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    params = [self secretBuild:params];
    [self requestWithPath:url params:params method:@"GET" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
    //    [self get:url params:params progressEnabled:YES success:success failure:failure];
}

- (void)getRawWithoutProgress:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    params = [self secretBuild:params];
    [self requestWithPath:url params:params method:@"GET" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
    //    [self get:url params:params progressEnabled:YES success:success failure:failure];
}

- (void)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure
{
    DDLogVerbose(@"%@",[self urlWithPath:url]);
    params = [self secretBuild:params];

    [self requestWithPath:[self urlWithPath:url] params:params method:@"POST" progressEnabled:self.progressEnabled  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
//    [self post:url params:params progressEnabled:YES success:success failure:failure];
}

//add by qingyang
- (void)getWithoutProgress:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    params = [self secretBuild:params];
    self.progressEnabled=false;
    [self requestWithPath:[self urlWithPath:url] params:params method:@"GET" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}
- (void)postWithoutProgress:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    
    self.progressEnabled=false;
    params = [self secretBuild:params];
    [self requestWithPath:[self urlWithPath:url] params:params method:@"POST"  progressEnabled:NO success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}

//- (void)get:(NSString *)url params:(NSDictionary *)params progressEnabled:(BOOL)pEnabled success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
//    [self requestWithPath:[self urlWithPath:url] params:params method:@"GET"   success:^(id responseObj) {
//        success (responseObj);
//    } failure:^(HttpException *e) {
//        failure(e);
//    }];
//}
//
//- (void)post:(NSString *)url params:(NSDictionary *)params progressEnabled:(BOOL)pEnabled success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
//    [self requestWithPath:[self urlWithPath:url] params:params method:@"POST"   success:^(id responseObj) {
//        success (responseObj);
//    } failure:^(HttpException *e) {
//        failure(e);
//    }];
//}



//add end


- (void)put:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    params = [self secretBuild:params];
    [self requestWithPath:[self urlWithPath:url] params:params method:@"PUT" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    
    self.progressEnabled=YES;
}

- (void)deleteR:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{

    [self requestWithPath:[self urlWithPath:url] params:params method:@"DELETE" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
    self.progressEnabled=YES;
}

- (void)putWithoutProgress:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    
    self.progressEnabled=false;
    params = [self secretBuild:params];
    [self requestWithPath:[self urlWithPath:url] params:params method:@"PUT" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}

- (void)deleteRWithoutProgress:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    
    self.progressEnabled=false;
    [self requestWithPath:[self urlWithPath:url] params:params method:@"DELETE" progressEnabled:NO  success:^(id responseObj) {
        success (responseObj);
    } failure:^(HttpException *e) {
        failure(e);
    }];
}


-(void)patch:(NSString *)URLString parameters:(id)parameters   success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure{
    
    [self.http PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            DDLogVerbose(@"%@",error.description);
            NSInteger code = operation.response.statusCode;
            DDLogVerbose(@"code ===>%ld",(long)code);
            DDLogVerbose(@"%@",operation.response.allHeaderFields);
            DDLogVerbose(@"%@",operation.response.MIMEType);
            DDLogVerbose(@"%@",operation.response.URL);
            //           failure(error);
        }
    }];
}
#pragma mark - URL schema

- (NSString *)urlWithPath:(NSString *)path
{
    if ([_requestType isEqualToString:@"https"]) {
        if ([self.baseUrl hasPrefix:@"http://"]) {
          self.baseUrl =  [self.baseUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        }
     
    }
    NSString * urlString;
    NSRange range = [path rangeOfString:@"h5/"];
    if(range.length > 0){//包含h5字段
        urlString = [NSString stringWithFormat:@"%@%@", H5_DOMAIN_URL, path];
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", self.baseUrl, path];
    }
    
    return urlString;
}

//检查域名的
- (NSString *)CutomUrlWithPath:(NSString *)path
{
    NSString *once=[NSString stringWithFormat:@"%@/",DE_ONCE_URL];
    if ([_requestType isEqualToString:@"https"]) {
        if ([once hasPrefix:@"http://"]) {
            once =  [once stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        }
        
    }
    NSString * urlString = [NSString stringWithFormat:@"%@%@", once, path];
    
    return urlString;
}
//检查域名的
- (NSString *)CutomUrlTwiceWithPath:(NSString *)path
{
    NSString *once=[NSString stringWithFormat:@"%@/",DE_TWICE_URL];
    if ([_requestType isEqualToString:@"https"]) {
        if ([once hasPrefix:@"http://"]) {
            once =  [once stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        }
        
    }
    NSString * urlString = [NSString stringWithFormat:@"%@%@", once, path];
    
    return urlString;
}


#pragma mark - QWLoadingDelegate
- (void)hudStopByTouch:(id)hud{
    //打断所有请求
    [self cancleAllRequest];
}

//- (void)hudWasHidden:(MBProgressHUD *)hud {
//    // Remove HUD from screen when the HUD was hidded
//    [HUD removeFromSuperview];
// 
//    HUD = nil;
//}

#pragma mark -
-(void)uploaderImg:(NSMutableArray *)imageDataArr  params:(NSDictionary *)params withUrl:(NSString *)imagUrl success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure  uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgressBlock
{
    if (imageDataArr.count >0) {
        for (int i = 0; i < (int)imageDataArr.count; i++) {
            
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg",i]];
            NSData *mediaDatas = [imageDataArr objectAtIndex:i ];
//            [mediaDatas writeToFile:filePath atomically:YES];
            params = [self secretBuild:params];
            void (^responseSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
//                DDLogVerbose(@"allHeaderFields===>%@",operation.response.allHeaderFields);
//                DDLogVerbose(@"MIMEType=====>%@",responseObject);
             
                NSDictionary *fields= [operation.response allHeaderFields];
                NSArray *cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:[NSURL URLWithString:_baseUrl]];
                NSDictionary* requestFields=[NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                if([requestFields objectForKey:@"Cookie"]){
                    // Cookie  code
                }
                
                if (success) {
                    if ([[responseObject objectForKey:@"result" ]isEqualToString:@"OK"]) {
                        //                  DebugLog(@"request ====>%@",[responseObject objectForKey:@"body" ]);
                        success(responseObject[@"body"]);
                    }
                    else
                    {
                        
                    }
                    
                }
                if ([[responseObject objectForKey:@"result" ]isEqualToString:@"FAIL"]) {
                    HttpException *qwError = [[HttpException alloc]init];
                    qwError.errorCode = [[responseObject objectForKey:@"errorCode" ]integerValue];
                    qwError.Edescription =[responseObject objectForKey:@"apiMessage" ];
                    
                    if (failure) {
                        failure(qwError);
                    }
                    
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            /// failure block
            void (^failureResponse)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
//                 DDLogVerbose(@"request=======url====>%@",operation.request.URL);
                NSInteger code = operation.response.statusCode;
            
                HttpException * e = [HttpException new];
                e.errorCode = code;
                if (code == 401) {
                    
                }else if (code == 400){
                    
                }else if (code == 500){
                    
                }else{
                    
                }
                
                if (failure) {
                    failure(e);
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            NSMutableURLRequest *request = [self.http.requestSerializer multipartFormRequestWithMethod:@"POST"  URLString:[[NSURL URLWithString:imagUrl relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString]  parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                
                // 图片
//                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//                NSString *documentsDirectory = [paths objectAtIndex:0]; //path数组里貌似只有一个元素
//                NSString *filestr =[NSString stringWithFormat:@"/%d.jpg",i] ;
//                NSString *newstr = [documentsDirectory stringByAppendingString:filestr];
//                NSData *dd = [NSData dataWithContentsOfFile:newstr];
                
                
                [formData appendPartWithFileData:mediaDatas name:[NSString stringWithFormat:@"file"] fileName:[NSString stringWithFormat:@"%d.jpg",i] mimeType:@"image/jpeg"];
                
                
            } error:nil];
            
            AFHTTPRequestOperation *operation = [self.http HTTPRequestOperationWithRequest:request success:responseSuccess failure:failureResponse];
            
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                if (uploadProgressBlock) {
                    uploadProgressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
                }
//                DDLogVerbose(@"bytesWritten=%lu, totalBytesWritten=%lld, totalBytesExpectedToWrite=%lld", (unsigned long)bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                
            }];
           
//            DebugLog(@"allHeaderFields======%@",operation.request.allHTTPHeaderFields);
//            DebugLog(@"URL=====>%@",operation.request.URL);
            [self.http.operationQueue addOperation:operation];
        }
        
    }
}


/**
 * 下载文件
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址
 * @param string aFileName 文件名
 * @param String UUID标识
 */
- (void)downloadFileURL:(NSString *)aUrl
               savePath:(NSString *)aSavePath
               fileName:(NSString *)aFileName
                   UUID:(NSString *)UUID
                success:(void(^)(NSString *aSavePath))success
                failure:(void(^)(HttpException * e))failure
    downLoadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))downLoadProgressBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", aSavePath, aFileName];
    //检查附件是否存在
    if ([fileManager fileExistsAtPath:fileName]) {
        NSData *audioData = [NSData dataWithContentsOfFile:fileName];
        success(fileName);
    }else{
        //创建附件存储目录
        if (![fileManager fileExistsAtPath:aSavePath]) {
            [fileManager createDirectoryAtPath:aSavePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //下载附件
        NSURL *url = [[NSURL alloc] initWithString:aUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        //设置输入流,即Url流中的数据
        operation.inputStream   = [NSInputStream inputStreamWithURL:url];
        //输出流为本地文件,NSStream会帮助解决流与文件的中转
        operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:fileName append:NO];
        operation.UUID = UUID;
        //下载进度控制
         [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
             if(downLoadProgressBlock)
                 downLoadProgressBlock(bytesRead,totalBytesRead,totalBytesExpectedToRead);
         }];
         
        
        //已完成下载
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSData *audioData = [NSData dataWithContentsOfFile:fileName];
            success(fileName);
            //设置下载数据到res字典对象中并用代理返回下载数据NSData
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSInteger code = operation.response.statusCode;
            HttpException * e = [HttpException new];
            e.errorCode = code;
            if (code == 401) {
                
            }else if (code == 400){
                
            }else if (code == 500){
                
            }else{
                
            }
            if (failure) {
                failure(e);
            }
            //下载失败
            failure(e);
        }];
        
        [operation start];
    }
}

//上传错误日志文件,支持数组形式上传,MIME-type可能需要再处理一下
-(void)upLogFile:(NSMutableArray *)logDataArr filePaths:(NSMutableArray *)filePaths params:(NSDictionary *)params withUrl:(NSString *)uploadUrl success:(void(^)(NSString *path))success failure:(void(^)(HttpException * e))failure  uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgressBlock
{
    if (logDataArr.count >0) {
        for (int i = 0; i < (int)logDataArr.count; i++) {
            NSData *mediaDatas = [logDataArr objectAtIndex:i ];
            params = [self secretBuild:params];
            void (^responseSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *fields= [operation.response allHeaderFields];
                NSArray *cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:[NSURL URLWithString:_baseUrl]];
                NSDictionary* requestFields=[NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                if([requestFields objectForKey:@"Cookie"]){
                    // Cookie  code
                }
                
                if (success) {
                    if ([[responseObject objectForKey:@"result" ]isEqualToString:@"OK"]) {
                        success(filePaths[i]);
                    }
                    else
                    {
                        
                    }
                    
                }
                if ([[responseObject objectForKey:@"result" ]isEqualToString:@"FAIL"]) {
                    HttpException *qwError = [[HttpException alloc]init];
                    qwError.errorCode = [[responseObject objectForKey:@"errorCode" ]integerValue];
                    qwError.Edescription =[responseObject objectForKey:@"apiMessage" ];
                    
                    if (failure) {
                        failure(qwError);
                    }
                    
                }
            };
            
            /// failure block
            void (^failureResponse)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
                DDLogVerbose(@"request=======url====>%@",operation.request.URL);
                NSInteger code = operation.response.statusCode;
                HttpException * e = [HttpException new];
                e.errorCode = code;
                if (code == 401) {
                    
                }else if (code == 400){
                    
                }else if (code == 500){
                    
                }else{
                    
                }
                
                if (failure) {
                    failure(e);
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            NSMutableURLRequest *request = [self.http.requestSerializer multipartFormRequestWithMethod:@"POST"  URLString:[[NSURL URLWithString:uploadUrl relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString]  parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                
                // 图片
                //                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                //                NSString *documentsDirectory = [paths objectAtIndex:0]; //path数组里貌似只有一个元素
                //                NSString *filestr =[NSString stringWithFormat:@"/%d.jpg",i] ;
                //                NSString *newstr = [documentsDirectory stringByAppendingString:filestr];
                //                NSData *dd = [NSData dataWithContentsOfFile:newstr];
                
                NSString *fileName = filePaths[i];
                [formData appendPartWithFileData:mediaDatas name:[NSString stringWithFormat:@"file"] fileName:fileName mimeType:@"txt"];
                
            } error:nil];
            
            AFHTTPRequestOperation *operation = [self.http HTTPRequestOperationWithRequest:request success:responseSuccess failure:failureResponse];
            
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                if (uploadProgressBlock) {
                    uploadProgressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
                }
            }];
            [self.http.operationQueue addOperation:operation];
        }
    }
}


//上传原始文件,支持数组形式上传,MIME-type可能需要再处理一下
-(void)upRawFile:(NSMutableArray *)imageDataArr  params:(NSDictionary *)params withUrl:(NSString *)uploadUrl success:(void(^)(id responseObj))success failure:(void(^)(HttpException * e))failure  uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgressBlock
{
    if (imageDataArr.count >0) {
        for (int i = 0; i < (int)imageDataArr.count; i++) {
            NSData *mediaDatas = [imageDataArr objectAtIndex:i ];
            params = [self secretBuild:params];
            void (^responseSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *fields= [operation.response allHeaderFields];
                NSArray *cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:[NSURL URLWithString:_baseUrl]];
                NSDictionary* requestFields=[NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                if([requestFields objectForKey:@"Cookie"]){
                    // Cookie  code
                }
                
                if (success) {
                    if ([[responseObject objectForKey:@"result" ]isEqualToString:@"OK"]) {
                        success(responseObject[@"body"]);
                    }
                    else
                    {
                        
                    }
                    
                }
                if ([[responseObject objectForKey:@"result" ]isEqualToString:@"FAIL"]) {
                    HttpException *qwError = [[HttpException alloc]init];
                    qwError.errorCode = [[responseObject objectForKey:@"errorCode" ]integerValue];
                    qwError.Edescription =[responseObject objectForKey:@"apiMessage" ];
                    
                    if (failure) {
                        failure(qwError);
                    }
                    
                }
            };
            
            /// failure block
            void (^failureResponse)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
                DDLogVerbose(@"request=======url====>%@",operation.request.URL);
                NSInteger code = operation.response.statusCode;
                HttpException * e = [HttpException new];
                e.errorCode = code;
                if (code == 401) {
                    
                }else if (code == 400){
                    
                }else if (code == 500){
                    
                }else{
                    
                }
                
                if (failure) {
                    failure(e);
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            NSMutableURLRequest *request = [self.http.requestSerializer multipartFormRequestWithMethod:@"POST"  URLString:[[NSURL URLWithString:uploadUrl relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString]  parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                
                // 图片
                //                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                //                NSString *documentsDirectory = [paths objectAtIndex:0]; //path数组里貌似只有一个元素
                //                NSString *filestr =[NSString stringWithFormat:@"/%d.jpg",i] ;
                //                NSString *newstr = [documentsDirectory stringByAppendingString:filestr];
                //                NSData *dd = [NSData dataWithContentsOfFile:newstr];
                
                
                [formData appendPartWithFileData:mediaDatas name:[NSString stringWithFormat:@"file"] fileName:[NSString stringWithFormat:@"%d.amr",i] mimeType:@"audio"];
                
                
            } error:nil];
            
            AFHTTPRequestOperation *operation = [self.http HTTPRequestOperationWithRequest:request success:responseSuccess failure:failureResponse];
            
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                if (uploadProgressBlock) {
                    uploadProgressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
                }
            }];
            [self.http.operationQueue addOperation:operation];
        }
    }
}




-(void)ma_uploaderImg:(NSMutableArray *)imageDataArr  params:(NSDictionary *)params withUrl:(NSString *)imagUrl success:(void(^)(NSMutableArray* uploadFileArray))success failure:(void(^)(HttpException * e))failure  uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgressBlock
{
    if (imageDataArr.count >0) {
        __block NSInteger imageCount = imageDataArr.count;
        __block NSMutableArray* uploadFileArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        
        for (int i = 0; i < (int)imageDataArr.count; i++) {
            
            NSData *mediaDatas = [imageDataArr objectAtIndex:i ];

            params = [self secretBuild:params];
            void (^responseSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                //                DDLogVerbose(@"allHeaderFields===>%@",operation.response.allHeaderFields);
                //                DDLogVerbose(@"MIMEType=====>%@",responseObject);
                
                NSDictionary *fields= [operation.response allHeaderFields];
                NSArray *cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:[NSURL URLWithString:_baseUrl]];
                NSDictionary* requestFields=[NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                if([requestFields objectForKey:@"Cookie"]){
                    // Cookie  code
                }
                
                if (success) {
                    if ([[responseObject objectForKey:@"result" ]isEqualToString:@"OK"]) {
                        //                  DebugLog(@"request ====>%@",[responseObject objectForKey:@"body" ]);
                        uploadFile* file = [uploadFile parse:responseObject[@"body"]];
                        file.uploadSuccess = YES;
                        file.imageIndex = i;
                        [uploadFileArray addObject:file];
                        if (uploadFileArray.count >= imageCount) {
                            success(uploadFileArray);
                        }
//                        success(responseObject[@"body"]);
                    }
                    else
                    {
                        uploadFile* file = [uploadFile new];
                        file.uploadSuccess = NO;
                        file.imageIndex = i;
                        [uploadFileArray addObject:file];
                        if (uploadFileArray.count >= imageCount) {
                            success(uploadFileArray);
                        }

                    }
                    
                }
                if ([[responseObject objectForKey:@"result" ]isEqualToString:@"FAIL"]) {
                    HttpException *qwError = [[HttpException alloc]init];
                    qwError.errorCode = [[responseObject objectForKey:@"errorCode" ]integerValue];
                    qwError.Edescription =[responseObject objectForKey:@"apiMessage" ];
                    
                    uploadFile* file = [uploadFile new];
                    file.uploadSuccess = NO;
                    file.imageIndex = i;
                    [uploadFileArray addObject:file];
                    if (uploadFileArray.count >= imageCount) {
                        success(uploadFileArray);
                    }

                    if (failure) {
                        failure(qwError);
                    }
                    
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            /// failure block
            void (^failureResponse)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
                //                 DDLogVerbose(@"request=======url====>%@",operation.request.URL);
                NSInteger code = operation.response.statusCode;
                
                HttpException * e = [HttpException new];
                e.errorCode = code;
                if (code == 401) {
                    
                }else if (code == 400){
                    
                }else if (code == 500){
                    
                }else{
                    
                }
                
                uploadFile* file = [uploadFile new];
                file.uploadSuccess = NO;
                file.imageIndex = i;
                [uploadFileArray addObject:file];
                if (uploadFileArray.count >= imageCount) {
                    success(uploadFileArray);
                }

                
                if (failure) {
                    failure(e);
                }
                //暂时注释掉 －－jxb
                //if (pEnabled) [HUD hide:YES];
            };
            
            NSMutableURLRequest *request = [self.http.requestSerializer multipartFormRequestWithMethod:@"POST"  URLString:[[NSURL URLWithString:imagUrl relativeToURL:[NSURL URLWithString:_baseUrl]] absoluteString]  parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                
                // 图片
                //                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                //                NSString *documentsDirectory = [paths objectAtIndex:0]; //path数组里貌似只有一个元素
                //                NSString *filestr =[NSString stringWithFormat:@"/%d.jpg",i] ;
                //                NSString *newstr = [documentsDirectory stringByAppendingString:filestr];
                //                NSData *dd = [NSData dataWithContentsOfFile:newstr];
                
                
                [formData appendPartWithFileData:mediaDatas name:[NSString stringWithFormat:@"file"] fileName:[NSString stringWithFormat:@"%d.jpg",i] mimeType:@"image/jpeg"];
                
                
            } error:nil];
            
            AFHTTPRequestOperation *operation = [self.http HTTPRequestOperationWithRequest:request success:responseSuccess failure:failureResponse];
            
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                if (uploadProgressBlock) {
                    uploadProgressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
                }
                //                DDLogVerbose(@"bytesWritten=%lu, totalBytesWritten=%lld, totalBytesExpectedToWrite=%lld", (unsigned long)bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                
            }];
            
            //            DebugLog(@"allHeaderFields======%@",operation.request.allHTTPHeaderFields);
            //            DebugLog(@"URL=====>%@",operation.request.URL);
            [self.http.operationQueue addOperation:operation];
        }
        
    }
}




@end