//
//  JGAppDelegate.m
//  BenchmarkWeakVsStrong
//
//  Created by Joshua Gross on 10/8/13.
//  Copyright (c) 2013 JGross. All rights reserved.
//

#import "JGAppDelegate.h"

@implementation JGAppDelegate

- (CGFloat)measureBlockExecutionTime:(void (^)(void))block withLabel:(NSString *)label
{
    NSDate *before = [NSDate date];
    block();
    NSDate *apres = [NSDate date];
    CGFloat interval = [apres timeIntervalSinceDate:before];
    NSLog(@"Execution time of %@: %f", label, interval);
    return interval;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSUInteger numExecutions = 10000000;

    [self measureBlockExecutionTime:^(void){
        NSNumber *strongReference = [NSNumber numberWithInt:5];
        __weak NSNumber *weakReference = strongReference;
        for (NSUInteger i = 0; i < numExecutions; i++) {
            [weakReference isEqualToNumber:[NSNumber numberWithInt:6]];
        }
    } withLabel:@"Weak pointer, no freeing"];

    [self measureBlockExecutionTime:^(void){
        NSNumber *strongReference = [NSNumber numberWithInt:5];
        for (NSUInteger i = 0; i < numExecutions; i++) {
            [strongReference isEqualToNumber:[NSNumber numberWithInt:6]];
        }
    } withLabel:@"Strong pointer, no freeing"];

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
