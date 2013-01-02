//
//  FPAppDelegate.m
//  ParcoaJSONExample
//
//  Created by James Brotchie on 30/12/12.
//  Copyright (c) 2012 Factorial Products Pty. Ltd. All rights reserved.
//

#import "FPAppDelegate.h"
#import "ParcoaJSON.h"
#import "ParcoaRFC2616.h"

@implementation FPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ParcoaResult *result = [Parcoa runParserWithTraceback:[ParcoaJSON parser] input:json];
    if (result.isOK) {
        NSLog(@"%@", result.value);
    }
    /*[Parcoa runParserWithTraceback:[ParcoaRFC2616 requestParser] input:@"GET /index.html HTTP/1.0\r\nUser-agent: test\r\ncookies: testing 1234\r\n\r\n"];
    NSLog(@"%@", [ParcoaRFC2616 responseParser](@"HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\n"));*/
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
