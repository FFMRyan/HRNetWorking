//
//  XXUtils.m
//  HRNetWorking
//
//  Created by iOSGeekOfChina on 2017/10/12.
//  Copyright © 2017年 iOSGeekOfChina. All rights reserved.
//

#import "XXUtils.h"
#import "AFAppDotNetAPIClient.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <CommonCrypto/CommonDigest.h>

NSString *const APISYSKEY = @"5w1ke2ycdkzuq4yqgk45ta7rroox1i3u7q1n43t4lcg89ymc56y1soqskpjhw4lp";
NSString *const APISERVER = @"https://www.xxwolo.com/ccsrv";
NSString *const WEBSERVER = @"https://www.xxwolo.com";

NSString *const SAPSERVER = @"https://www.xxwolo.com";

@implementation XXUtils
//网络状态变换
+ (NSString *)getNetWorkingWithStr:(NSString *)str{
    
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"NetWWW2Or"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"NetWWW2Or"] isEqualToString:@"NetWWW2Or"]) {
        
        return str;
    }else{
        return [str stringByReplacingOccurrencesOfString:@"https://www" withString:@"http://www6"];
    }
    return str;
    
}
+ (void) execute:(NSString *)actionWithParams handler:(void(^)(id))handler{
    [XXUtils execute:actionWithParams silmode:YES handler:handler];
}

+ (void) execute:(NSString *)actionWithParams silmode:(BOOL)silmode handler:(void(^)(id))handler{
    if(actionWithParams==nil){
        NSLog(@"url not provided.");
    }else{
        NSString *apikey=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"apikey"];
        NSString *secret=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"secret"];
        if(apikey==nil || secret==nil || (secret && secret.length < 15)){
            if(silmode==NO){
                [XXUtils alert:@"您当前网络不佳，请稍后尝试或更换网络后重新启动App。"];
            }else{
                NSLog(@"您当前网络不佳，请保持联网或更换网络后重新启动App。");
            }
        }else{
            if(silmode==NO){
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                
            }
            long long seed = [XXUtils getSeed];
            NSString *hash=[XXUtils md5:[NSString stringWithFormat:@"%@::%lld::%@",apikey,seed,secret]];
            NSString *concate=@"&";
            NSString * versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            if([actionWithParams rangeOfString:@"?"].location == NSNotFound){
                concate=@"?";
            }
            NSString *urlstr= nil;
            if ([actionWithParams hasPrefix:@"/"]) {
                urlstr=[NSString stringWithFormat:@"%@%@%@apikey=%@&seed=%lld&hash=%@&vs=%@&userDevice=%@",APISERVER,actionWithParams,concate,apikey,seed,hash,versionStr,[[UIDevice currentDevice] systemVersion]];
            }else{
                urlstr=[NSString stringWithFormat:@"%@",actionWithParams];
            }
            
            
            urlstr=[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            urlstr = [XXUtils getNetWorkingWithStr:urlstr];
            
            __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
            
            
            [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil]];
            
            [manager GET:urlstr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [XXUtils handleResult:responseObject silmode:silmode handler:handler];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Failure: %@", error);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(silmode==NO){
                    [SVProgressHUD showErrorWithStatus:@"[10005]网络错误。"];
                }
            }];
            
            
        }
    }
}

//带参数
+ (void) execute:(NSString *)actionWithParams params:(NSDictionary *)params silmode:(BOOL)silmode handler:(void(^)(id))handler{
    if(actionWithParams==nil){
        NSLog(@"url not provided.");
    }else{
        NSString *apikey=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"apikey"];
        NSString *secret=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"secret"];
        if(apikey==nil || secret==nil  || (secret && secret.length < 15) ){
            if(silmode==NO){
                [XXUtils alert:@"您当前网络不佳，请稍后尝试或更换网络后重新启动App。"];
            }else{
                NSLog(@"您当前网络不佳，请保持联网或更换网络后重新启动App。");
            }
        }else{
            if(silmode==NO){
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                
            }
            long long seed = [XXUtils getSeed];
            NSString *hash=[XXUtils md5:[NSString stringWithFormat:@"%@::%lld::%@",apikey,seed,secret]];
            NSString *concate=@"&";
            NSString * versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            if([actionWithParams rangeOfString:@"?"].location == NSNotFound){
                concate=@"?";
            }
            NSString *urlstr= nil;
            
            NSMutableDictionary * tempParamsM = [NSMutableDictionary dictionaryWithDictionary:params];
            
            if ([actionWithParams hasPrefix:@"/"]) {
                urlstr=[NSString stringWithFormat:@"%@%@%@apikey=%@&seed=%lld&hash=%@&vs=%@&userDevice=%@",APISERVER,actionWithParams,concate,apikey,seed,hash,versionStr,[[UIDevice currentDevice] systemVersion]];
                
            }else{
                urlstr=[NSString stringWithFormat:@"%@",actionWithParams];
            }
            
#pragma mark - 上线前删除
            urlstr = [XXUtils getNetWorkingWithStr:urlstr];
            
            [tempParamsM setObject:apikey forKey:@"apikey"];
            [tempParamsM setObject:@(seed) forKey:@"seed"];
            [tempParamsM setObject:hash forKey:@"hash"];
            [tempParamsM setObject:versionStr forKey:@"vs"];
            
            urlstr=[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
            
            manager.requestSerializer.timeoutInterval = 20; // colin_test
            [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil]];
            [manager GET:urlstr parameters:tempParamsM progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [XXUtils handleResult:responseObject silmode:silmode handler:handler];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Failure: %@", error);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(silmode==NO){
                    
                    [SVProgressHUD showErrorWithStatus:@"[10005]网络错误。"];
                }
            }];
            
        }
    }
}



// colin_test
+ (void)GET_execute:(NSString *)actionWithParams silmode:(BOOL)silmode handler:(void(^)(id json))handler failure:(void (^)(NSError *error))failure
{
    if(actionWithParams==nil){
        NSLog(@"url not provided.");
    }else{
        NSString *apikey=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"apikey"];
        NSString *secret=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"secret"];
        if(apikey==nil || secret==nil || (secret && secret.length < 15) ){
            if(silmode==NO){
                [XXUtils alert:@"您当前网络不佳，请稍后尝试或更换网络后重新启动App。"];
            }else{
                NSLog(@"您当前网络不佳，请保持联网或更换网络后重新启动App。");
            }
        }else{
            if(silmode==NO){
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                
            }
            long long seed = [XXUtils getSeed];
            NSString *hash=[XXUtils md5:[NSString stringWithFormat:@"%@::%lld::%@",apikey,seed,secret]];
            NSString *concate=@"&";
            NSString * versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            if([actionWithParams rangeOfString:@"?"].location == NSNotFound){
                concate=@"?";
            }
            NSString *urlstr= nil;
            if ([actionWithParams hasPrefix:@"/"]) {
                urlstr=[NSString stringWithFormat:@"%@%@%@apikey=%@&seed=%lld&hash=%@&vs=%@&userDevice=%@",APISERVER,actionWithParams,concate,apikey,seed,hash,versionStr,[[UIDevice currentDevice] systemVersion]];
            }else{
                urlstr=[NSString stringWithFormat:@"%@",actionWithParams];
            }
            
            
            urlstr=[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
#pragma mark - 上线前删除
            urlstr = [XXUtils getNetWorkingWithStr:urlstr];
            
            __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
            
            //            AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
            //            securityPolicy.allowInvalidCertificates = YES;
            //            securityPolicy.validatesDomainName = YES;
            //            manager.securityPolicy = securityPolicy;
            
            manager.requestSerializer.timeoutInterval = 10; // colin_test
            [manager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil]];
            [manager GET:urlstr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [XXUtils develop_handleResult:responseObject silmode:silmode handler:handler];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure)   failure(error);
            }];
        }
    }
}


+ (void)POST_execute:(NSString *)url params:(NSDictionary *)params silmode:(BOOL)silmode handler:(void(^)(id json))handler failure:(void (^)(NSError *error))failure
{
    if(url == nil)
    {
        NSLog(@"url not provided.");
    }
    else
    {
        NSString *apikey=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"apikey"];
        NSString *secret=[[NSUserDefaults standardUserDefaults]
                          stringForKey:@"secret"];
        if(apikey == nil || secret == nil || (secret && secret.length < 15) )
        {
            if(silmode == NO)
            {
                [XXUtils alert:@"您当前网络不佳，请稍后尝试或更换网络后重新启动App。"];
            }
            else
            {
                NSLog(@"您当前网络不佳，请保持联网或更换网络后重新启动App。");
            }
        }
        else
        {
            if(silmode == NO)   [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            
            long long seed = [XXUtils getSeed];
            NSString *hash=[XXUtils md5:[NSString stringWithFormat:@"%@::%lld::%@",apikey,seed,secret]];
            NSString * versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *urlstr= nil;
            NSMutableDictionary *tempParamsM = [NSMutableDictionary dictionaryWithDictionary:params];
            
            if ([url hasPrefix:@"/"])
            {
                urlstr = [NSString stringWithFormat:@"%@%@",APISERVER,url];
                
                [tempParamsM setObject:apikey forKey:@"apikey"];
                [tempParamsM setObject:@(seed) forKey:@"seed"];
                [tempParamsM setObject:hash forKey:@"hash"];
                [tempParamsM setObject:versionStr forKey:@"vs"];
            }
            else
            {
                urlstr = [NSString stringWithFormat:@"%@", url];
            }
            
            
            urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
#pragma mark - 上线前删除
            urlstr = [XXUtils getNetWorkingWithStr:urlstr];
            
            __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
            
            //            AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
            //            securityPolicy.allowInvalidCertificates = YES;
            //            securityPolicy.validatesDomainName = YES;
            //            manager.securityPolicy = securityPolicy;
            manager.requestSerializer.timeoutInterval = 20; // colin_test
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
            [manager POST:urlstr parameters:tempParamsM progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [XXUtils develop_handleResult:responseObject silmode:silmode handler:handler];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure)
                    failure(error);
                NSLog(@"~~~~~~~~~~~%@",error);
            }];
            
        }
    }
}
// colin_test
+ (void)develop_handleResult:(id)json silmode:(BOOL)silmode handler:(void(^)(id))handler
{
    if(json==nil)
    {
        if(silmode==NO)
        {
            [SVProgressHUD showErrorWithStatus:@"[10001]未获得数据。"];
        }
    }
    else
    {
        int error=0;
        
        if ([json valueForKey:@"error"]) {
            error=[[json valueForKey:@"error"] intValue];
        }
        NSString *msg = @"";
        if ([json valueForKey:@"message"]) {
            msg = [json valueForKey:@"message"];
        }
        if ([json valueForKey:@"msg"]) {
            msg = [json valueForKey:@"msg"];
        }
        
        if(error>0 && error<3){
            if(silmode==NO)
            {
                if(msg==nil)
                {
                    [SVProgressHUD showErrorWithStatus:@"[10002]系统错误。"];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
            else
            {
                if (handler)
                {
                    handler(json);
                }
            }
        }
        else
        {
            if(silmode==NO)
            {
                if(error==3 && msg!=nil)
                {
                    [SVProgressHUD showSuccessWithStatus:msg];
                }
            }
            if (silmode == NO)
            {
                [SVProgressHUD dismiss];
            }
            if (handler)
            {
                handler(json);
            }
        }
    }
}

+ (void)handleResult:(id)json silmode:(BOOL)silmode handler:(void(^)(id))handler{
    if(json==nil||([json isKindOfClass:[NSArray class]] && [json count]<1)){
        if(silmode==NO){
            [SVProgressHUD showErrorWithStatus:@"[10001]未获得数据。"];
        }
    }else{
        int error=0;
        error=[[json valueForKey:@"error"] intValue];
        NSString *msg = [json valueForKey:@"message"];
        if(error>0 && error<3){
            if(silmode==NO){
                if(msg==nil){
                    [SVProgressHUD showErrorWithStatus:@"[10002]系统错误。"];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
        }else{
            if(silmode==NO){
                if(error==3 && msg!=nil){
                    [SVProgressHUD showSuccessWithStatus:msg];
                }
            }
            if (silmode == NO) {
                [SVProgressHUD dismiss];
            }
            if (handler) {
                handler(json);
            }
        }
    }
}


+(void)alert:(NSString *)msg withTitle:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)alert:(NSString *)msg{
    [XXUtils alert:msg withTitle:@"提示"];
}

+(long long)getSeed{
    double s=CACurrentMediaTime();
    //    NSLog(@"seed=%f",s);
    return  s*1000000;
}
+ (NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
