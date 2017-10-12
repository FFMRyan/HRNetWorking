//
//  XXUtils.h
//  HRNetWorking
//
//  Created by iOSGeekOfChina on 2017/10/12.
//  Copyright © 2017年 iOSGeekOfChina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXUtils : NSObject

+ (void) execute:(NSString *)actionWithParams handler:(void(^)(id))handler;
+ (void) execute:(NSString *)actionWithParams silmode:(BOOL)silmode handler:(void(^)(id))handler;
+ (void) execute:(NSString *)actionWithParams params:(NSDictionary *)params silmode:(BOOL)silmode handler:(void(^)(id))handler;


+ (void)POST_execute:(NSString *)url params:(NSDictionary *)params silmode:(BOOL)silmode handler:(void(^)(id json))handler failure:(void (^)(NSError *error))failure;
+ (void)GET_execute:(NSString *)actionWithParams silmode:(BOOL)silmode handler:(void(^)(id json))handler failure:(void (^)(NSError *error))failure;

@end
