//
//  AppDelegate.m
//  ShareExtensionDemo
//
//  Created by 陆永安 on 16/9/5.
//  Copyright © 2016年 陆永安. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //获取共享的UserDefaults
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ShareExtensions"];
    if ([userDefaults boolForKey:@"has-new-share"])
    {
        NSLog(
              @"\n  public.image-->>%@,\n  public.url-->>%@"
              ,[userDefaults valueForKey:@"public.image"]
              ,[userDefaults valueForKey:@"public.url"]);
        
        NSString *string = @"";
        
        if ([userDefaults valueForKey:@"public.image"])
        {
            string = [userDefaults valueForKey:@"public.image"];
        }
        else if ([userDefaults valueForKey:@"public.url"])
        {
            string = [userDefaults valueForKey:@"public.url"];
        }
        
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"share-public-notification" object:self userInfo:jsonDict];
        
        
        //重置分享标识
        [userDefaults setBool:NO forKey:@"has-new-share"];
        
        //清除数据
//        [userDefaults removeObjectForKey:@"group.com.ShareExtensions"];
        if ([userDefaults valueForKey:@"public.image"])
        {
            [userDefaults setValue:nil forKey:@"public.image"];
        }
        if ([userDefaults valueForKey:@"public.url"])
        {
            [userDefaults setValue:nil forKey:@"public.url"];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
